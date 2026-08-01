// Package files implements allow-listed filesystem operations for the file
// browser (docs/10 §4.4, docs/11 §7). All paths are normalized and confined
// to the configured roots; symlink escapes are rejected.
package files

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// Errors.
var (
	ErrForbidden     = errors.New("files: path outside allowed roots")
	ErrNotFound      = errors.New("files: not found")
	ErrIsDir         = errors.New("files: is a directory")
	ErrTooLarge      = errors.New("files: exceeds size limit")
	ErrInvalidName   = errors.New("files: invalid name")
)

// Entry is a directory listing item.
type Entry struct {
	Name     string    `json:"name"`
	IsDir    bool      `json:"isDir"`
	Size     int64     `json:"size"`
	Mode     string    `json:"mode"`
	Modified time.Time `json:"modified"`
}

// Manager confines operations to the allow-listed roots.
type Manager struct {
	roots       []string
	hidden      bool
	maxRead     int64
	maxUpload   int64
}

// New validates the roots (expanding ~ and $HOME) and returns a Manager.
func New(roots []string, hidden bool, maxRead, maxUpload int64) (*Manager, error) {
	if len(roots) == 0 {
		return nil, errors.New("files: at least one root is required")
	}
	if maxRead <= 0 {
		maxRead = 2 << 20
	}
	if maxUpload <= 0 {
		maxUpload = 500 << 20
	}
	m := &Manager{hidden: hidden, maxRead: maxRead, maxUpload: maxUpload}
	for _, r := range roots {
		exp := expandHome(r)
		if !filepath.IsAbs(exp) {
			return nil, fmt.Errorf("files: root must be absolute: %q", r)
		}
		clean := filepath.Clean(exp)
		info, err := os.Stat(clean)
		if err != nil || !info.IsDir() {
			return nil, fmt.Errorf("files: root not a directory: %q", clean)
		}
		// Resolve symlinks (e.g. /var -> /private/var on macOS) so later
		// containment checks compare like with like.
		if resolved, err := filepath.EvalSymlinks(clean); err == nil {
			clean = resolved
		}
		m.roots = append(m.roots, clean)
	}
	return m, nil
}

// Roots returns the configured roots (displayed to the app).
func (m *Manager) Roots() []string { return m.roots }

// List returns a sorted directory listing (directories first, then files).
func (m *Manager) List(p string) ([]Entry, error) {
	path, err := m.Resolve(p)
	if err != nil {
		return nil, err
	}
	entries, err := os.ReadDir(path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	out := make([]Entry, 0, len(entries))
	for _, e := range entries {
		name := e.Name()
		if !m.hidden && strings.HasPrefix(name, ".") {
			continue
		}
		info, err := e.Info()
		if err != nil {
			continue
		}
		out = append(out, Entry{
			Name:     name,
			IsDir:    e.IsDir(),
			Size:     info.Size(),
			Mode:     info.Mode().String(),
			Modified: info.ModTime().UTC(),
		})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].IsDir != out[j].IsDir {
			return out[i].IsDir
		}
		return out[i].Name < out[j].Name
	})
	return out, nil
}

// Stat returns metadata for a path.
func (m *Manager) Stat(p string) (Entry, error) {
	path, err := m.Resolve(p)
	if err != nil {
		return Entry{}, err
	}
	info, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return Entry{}, ErrNotFound
		}
		return Entry{}, err
	}
	return Entry{
		Name:     filepath.Base(path),
		IsDir:    info.IsDir(),
		Size:     info.Size(),
		Mode:     info.Mode().String(),
		Modified: info.ModTime().UTC(),
	}, nil
}

// Open opens a file for reading with a size cap (text default, images larger).
func (m *Manager) Open(p string) (io.ReadCloser, Entry, error) {
	path, err := m.Resolve(p)
	if err != nil {
		return nil, Entry{}, err
	}
	info, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, Entry{}, ErrNotFound
		}
		return nil, Entry{}, err
	}
	if info.IsDir() {
		return nil, Entry{}, ErrIsDir
	}
	f, err := os.Open(path)
	if err != nil {
		return nil, Entry{}, err
	}
	if info.Size() > m.maxRead {
		f.Close()
		return nil, Entry{}, ErrTooLarge
	}
	return f, Entry{
		Name:     filepath.Base(path),
		IsDir:    false,
		Size:     info.Size(),
		Mode:     info.Mode().String(),
		Modified: info.ModTime().UTC(),
	}, nil
}

// Write creates/overwrites a file from r.
func (m *Manager) Write(p string, r io.Reader) error {
	path, err := m.Resolve(p)
	if err != nil {
		return err
	}
	if err := m.checkNotDir(path); err != nil {
		return err
	}
	return writeAtomic(path, r, m.maxUpload)
}

// Mkdir creates a directory (and parents).
func (m *Manager) Mkdir(p string) error {
	path, err := m.Resolve(p)
	if err != nil {
		return err
	}
	return os.MkdirAll(path, 0o755)
}

// Rename moves from → to within the allowed roots.
func (m *Manager) Rename(from, to string) error {
	src, err := m.Resolve(from)
	if err != nil {
		return err
	}
	dst, err := m.Resolve(to)
	if err != nil {
		return err
	}
	if err := m.checkNotDir(dst); err != nil {
		return err
	}
	return os.Rename(src, dst)
}

// Delete removes a file, or a directory when recursive is set.
func (m *Manager) Delete(p string, recursive bool) error {
	path, err := m.Resolve(p)
	if err != nil {
		return err
	}
	info, err := os.Lstat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return ErrNotFound
		}
		return err
	}
	if info.IsDir() && !recursive {
		return errors.New("files: directory requires recursive delete")
	}
	if info.IsDir() {
		return os.RemoveAll(path)
	}
	return os.Remove(path)
}

// Resolve normalizes p and confines it to the allowed roots. The final path
// must exist's ancestor is resolved through symlinks to prevent escapes.
func (m *Manager) Resolve(p string) (string, error) {
	path := p
	if path == "" {
		path = m.roots[0]
	}
	if !filepath.IsAbs(path) {
		path = filepath.Join(m.roots[0], path)
	}
	path = filepath.Clean(path)

	// Cheap containment check first (catches most traversal attempts).
	if !m.withinRoots(path) {
		return "", ErrForbidden
	}
	if !m.hidden {
		base := filepath.Base(path)
		if strings.HasPrefix(base, ".") && base != "." && base != ".." {
			return "", ErrForbidden
		}
	}

	// Symlink-aware: resolve the nearest existing ancestor.
	resolved, rest, err := resolveAncestor(path)
	if err != nil {
		return "", err
	}
	full := filepath.Join(resolved, rest)
	if !m.withinRoots(full) {
		return "", ErrForbidden
	}
	return full, nil
}

func (m *Manager) withinRoots(path string) bool {
	clean := filepath.Clean(path)
	for _, r := range m.roots {
		if clean == r || strings.HasPrefix(clean, r+string(filepath.Separator)) {
			return true
		}
	}
	return false
}

func (m *Manager) checkNotDir(path string) error {
	if info, err := os.Stat(path); err == nil && info.IsDir() {
		return ErrIsDir
	}
	return nil
}

func resolveAncestor(p string) (resolved, rest string, err error) {
	eval := p
	for {
		r, err := filepath.EvalSymlinks(eval)
		if err == nil {
			return r, rest, nil
		}
		if !os.IsNotExist(err) {
			return "", "", err
		}
		parent := filepath.Dir(eval)
		if parent == eval {
			return "", "", err
		}
		rest = filepath.Join(filepath.Base(eval), rest)
		eval = parent
	}
}

// writeAtomic streams to a temp file in the same directory then renames.
func writeAtomic(path string, r io.Reader, max int64) error {
	dir := filepath.Dir(path)
	tmp, err := os.CreateTemp(dir, ".qwe1-upload-*")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())
	n, err := io.Copy(tmp, io.LimitReader(r, max+1))
	if err != nil {
		tmp.Close()
		return err
	}
	if n > max {
		tmp.Close()
		return ErrTooLarge
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(tmp.Name(), path)
}

func expandHome(p string) string {
	if p == "~" {
		if h, err := os.UserHomeDir(); err == nil {
			return h
		}
	}
	if strings.HasPrefix(p, "~/") {
		if h, err := os.UserHomeDir(); err == nil {
			return filepath.Join(h, p[2:])
		}
	}
	return os.ExpandEnv(p)
}
