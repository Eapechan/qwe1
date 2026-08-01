package files

import (
	"errors"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func newTestManager(t *testing.T) (*Manager, string) {
	t.Helper()
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "a.txt"), []byte("hello"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(filepath.Join(root, "sub"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(root, "sub", "b.txt"), []byte("world"), 0o644); err != nil {
		t.Fatal(err)
	}
	m, err := New([]string{root}, false, 1<<20, 1<<20)
	if err != nil {
		t.Fatal(err)
	}
	return m, root
}

func TestList(t *testing.T) {
	m, _ := newTestManager(t)
	entries, err := m.List("")
	if err != nil {
		t.Fatal(err)
	}
	var names []string
	for _, e := range entries {
		names = append(names, e.Name)
	}
	if strings.Join(names, ",") != "sub,a.txt" {
		t.Fatalf("listing = %v", names)
	}
}

func TestHiddenFiltered(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, ".secret"), []byte("x"), 0o644); err != nil {
		t.Fatal(err)
	}
	m, err := New([]string{root}, false, 1<<20, 1<<20)
	if err != nil {
		t.Fatal(err)
	}
	entries, err := m.List("")
	if err != nil {
		t.Fatal(err)
	}
	if len(entries) != 0 {
		t.Fatalf("hidden file listed: %v", entries)
	}
	m2, err := New([]string{root}, true, 1<<20, 1<<20)
	if err != nil {
		t.Fatal(err)
	}
	entries, err = m2.List("")
	if err != nil {
		t.Fatal(err)
	}
	if len(entries) != 1 {
		t.Fatalf("hidden file not listed with hidden=true: %v", entries)
	}
}

func TestTraversalRejected(t *testing.T) {
	m, root := newTestManager(t)
	// Symlink pointing outside the root.
	outside := t.TempDir()
	if err := os.WriteFile(filepath.Join(outside, "secret.txt"), []byte("s"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(outside, filepath.Join(root, "escape")); err != nil {
		t.Fatal(err)
	}

	for _, p := range []string{
		"../outside",
		"escape",
		"escape/secret.txt",
		filepath.Join(root, "..", "..", "etc"),
	} {
		if _, err := m.List(p); !errors.Is(err, ErrForbidden) {
			t.Fatalf("List(%q) = %v, want ErrForbidden", p, err)
		}
		if _, err := m.Stat(p); !errors.Is(err, ErrForbidden) {
			t.Fatalf("Stat(%q) = %v, want ErrForbidden", p, err)
		}
	}
}

func TestSymlinkInsideAllowed(t *testing.T) {
	m, root := newTestManager(t)
	if err := os.Symlink(filepath.Join(root, "sub"), filepath.Join(root, "link")); err != nil {
		t.Fatal(err)
	}
	entries, err := m.List("link")
	if err != nil {
		t.Fatalf("list via symlink: %v", err)
	}
	if len(entries) != 1 || entries[0].Name != "b.txt" {
		t.Fatalf("symlink listing = %v", entries)
	}
}

func TestReadWrite(t *testing.T) {
	m, _ := newTestManager(t)
	if err := m.Write("new.txt", strings.NewReader("data")); err != nil {
		t.Fatal(err)
	}
	rc, entry, err := m.Open("new.txt")
	if err != nil {
		t.Fatal(err)
	}
	defer rc.Close()
	if entry.Name != "new.txt" || entry.Size != 4 {
		t.Fatalf("entry = %+v", entry)
	}
	got, err := io.ReadAll(rc)
	if err != nil {
		t.Fatal(err)
	}
	if string(got) != "data" {
		t.Fatalf("read = %q", got)
	}
}

func TestOpenTooLarge(t *testing.T) {
	root := t.TempDir()
	big := strings.Repeat("x", 10)
	if err := os.WriteFile(filepath.Join(root, "big.txt"), []byte(big), 0o644); err != nil {
		t.Fatal(err)
	}
	m, err := New([]string{root}, false, 5, 100)
	if err != nil {
		t.Fatal(err)
	}
	if _, _, err := m.Open("big.txt"); !errors.Is(err, ErrTooLarge) {
		t.Fatalf("open big = %v, want ErrTooLarge", err)
	}
}

func TestDelete(t *testing.T) {
	m, root := newTestManager(t)
	if err := m.Delete("a.txt", false); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(root, "a.txt")); !os.IsNotExist(err) {
		t.Fatal("file not deleted")
	}
	if err := m.Delete("sub", false); err == nil {
		t.Fatal("dir delete without recursive should fail")
	}
	if err := m.Delete("sub", true); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(root, "sub")); !os.IsNotExist(err) {
		t.Fatal("dir not deleted")
	}
}

func TestRename(t *testing.T) {
	m, root := newTestManager(t)
	if err := m.Rename("a.txt", "renamed.txt"); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(root, "renamed.txt")); err != nil {
		t.Fatal("rename failed")
	}
	// Renaming outside a root is rejected.
	if err := m.Rename("renamed.txt", "../renamed.txt"); !errors.Is(err, ErrForbidden) {
		t.Fatalf("rename escape = %v, want ErrForbidden", err)
	}
}

func TestNoRoots(t *testing.T) {
	if _, err := New(nil, false, 1<<20, 1<<20); err == nil {
		t.Fatal("expected error with no roots")
	}
}

func TestResolveDefaultsToFirstRoot(t *testing.T) {
	m, _ := newTestManager(t)
	p, err := m.Resolve("")
	if err != nil {
		t.Fatal(err)
	}
	if p != m.Roots()[0] {
		t.Fatalf("resolve = %q, want %q", p, m.Roots()[0])
	}
}
