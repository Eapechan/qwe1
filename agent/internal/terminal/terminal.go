// Package terminal manages interactive PTY shell sessions over the agent's
// WebSocket channel (docs/10 §4.3, docs/11 §6).
package terminal

import (
	"errors"
	"os"
	"os/exec"
	"sync"
	"time"

	"github.com/creack/pty"
	"github.com/google/uuid"
)

// Errors.
var (
	ErrNotFound = errors.New("terminal: session not found")
	ErrFull     = errors.New("terminal: too many sessions")
	ErrClosed   = errors.New("terminal: session closed")
)

// Session is a single PTY shell session.
type Session struct {
	ID      string
	cmd     *exec.Cmd
	pty     *os.File
	out     chan []byte
	done    chan struct{}
	closeMu sync.Once

	mu          sync.Mutex
	attached    bool
	discardStop chan struct{}
	lastActive  time.Time
}

// Out returns the buffered output channel for forwarding to a WS client.
func (s *Session) Out() <-chan []byte { return s.out }

// Done is closed when the session ends.
func (s *Session) Done() <-chan struct{} { return s.done }

// Attach marks the session as attached and stops output discarding.
func (s *Session) Attach() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.attached = true
	if s.discardStop != nil {
		close(s.discardStop)
		s.discardStop = nil
	}
}

// Detach marks the session as detached and discards output so a busy shell
// cannot block while nobody is listening.
func (s *Session) Detach() {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.attached {
		return
	}
	s.attached = false
	stop := make(chan struct{})
	s.discardStop = stop
	go func() {
		for {
			select {
			case <-s.out:
			case <-stop:
				return
			}
		}
	}()
}

// Input writes raw bytes into the PTY (client keyboard input).
func (s *Session) Input(data []byte) error {
	select {
	case <-s.done:
		return ErrClosed
	default:
	}
	s.touch()
	_, err := s.pty.Write(data)
	return err
}

// Resize updates the PTY window size.
func (s *Session) Resize(cols, rows int) error {
	s.touch()
	return pty.Setsize(s.pty, &pty.Winsize{Cols: uint16(cols), Rows: uint16(rows)})
}

// Kill force-closes the session and its process group.
func (s *Session) Kill() {
	s.closeMu.Do(func() { close(s.done) })
	s.pty.Close()
	if s.cmd.Process != nil {
		_ = s.cmd.Process.Kill()
	}
}

func (s *Session) touch() {
	s.mu.Lock()
	s.lastActive = time.Now()
	s.mu.Unlock()
}

// LastActive returns the last activity timestamp.
func (s *Session) LastActive() time.Time {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.lastActive
}

// Manager owns the session registry.
type Manager struct {
	mu        sync.Mutex
	sessions  map[string]*Session
	max       int
	idleTTL   time.Duration
	defaultSh string
}

// NewManager creates a Manager with the given concurrency and idle limits.
func NewManager(max int, idleTTL time.Duration, defaultShell string) *Manager {
	if defaultShell == "" {
		defaultShell = "/bin/sh"
	}
	if idleTTL <= 0 {
		idleTTL = 60 * time.Second
	}
	if max <= 0 {
		max = 4
	}
	return &Manager{
		sessions:  map[string]*Session{},
		max:       max,
		idleTTL:   idleTTL,
		defaultSh: defaultShell,
	}
}

// Create spawns a new PTY session with the given window size.
func (m *Manager) Create(cols, rows int, shell string) (*Session, error) {
	if shell == "" {
		shell = m.defaultSh
	}
	m.mu.Lock()
	if len(m.sessions) >= m.max {
		m.mu.Unlock()
		return nil, ErrFull
	}
	m.mu.Unlock()

	cmd := exec.Command(shell)
	cmd.Env = append(os.Environ(), "TERM=xterm-256color")
	cmd.SysProcAttr = sysProcAttr()

	ptmx, err := pty.StartWithSize(cmd, &pty.Winsize{Cols: uint16(cols), Rows: uint16(rows)})
	if err != nil {
		return nil, err
	}
	s := &Session{
		ID:         "term_" + uuid.NewString()[:12],
		cmd:        cmd,
		pty:        ptmx,
		out:        make(chan []byte, 256),
		done:       make(chan struct{}),
		lastActive: time.Now(),
	}

	// Pump PTY output.
	go func() {
		buf := make([]byte, 4096)
		for {
			n, err := ptmx.Read(buf)
			if n > 0 {
				chunk := make([]byte, n)
				copy(chunk, buf[:n])
				s.touch()
				select {
				case s.out <- chunk:
				case <-s.done:
					return
				}
			}
			if err != nil {
				s.Kill()
				return
			}
		}
	}()

	m.mu.Lock()
	m.sessions[s.ID] = s
	m.mu.Unlock()
	return s, nil
}

// Get returns a session by ID.
func (m *Manager) Get(id string) (*Session, bool) {
	m.mu.Lock()
	defer m.mu.Unlock()
	s, ok := m.sessions[id]
	return s, ok
}

// Kill terminates and removes a session.
func (m *Manager) Kill(id string) error {
	m.mu.Lock()
	s, ok := m.sessions[id]
	if !ok {
		m.mu.Unlock()
		return ErrNotFound
	}
	delete(m.sessions, id)
	m.mu.Unlock()
	s.Kill()
	return nil
}

// KillAll terminates every session (server shutdown).
func (m *Manager) KillAll() {
	m.mu.Lock()
	sessions := make([]*Session, 0, len(m.sessions))
	for _, s := range m.sessions {
		sessions = append(sessions, s)
	}
	m.sessions = map[string]*Session{}
	m.mu.Unlock()
	for _, s := range sessions {
		s.Kill()
	}
}

// Sweep closes sessions idle beyond the TTL. Call periodically.
func (m *Manager) Sweep() {
	m.mu.Lock()
	var expired []*Session
	for _, s := range m.sessions {
		if time.Since(s.LastActive()) > m.idleTTL {
			expired = append(expired, s)
		}
	}
	for _, s := range expired {
		delete(m.sessions, s.ID)
	}
	m.mu.Unlock()
	for _, s := range expired {
		s.Kill()
	}
}
