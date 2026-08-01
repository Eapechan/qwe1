package terminal

import (
	"testing"
	"time"
)

func newManager(t *testing.T) *Manager {
	t.Helper()
	return NewManager(4, 60*time.Second, "/bin/sh")
}

func TestCreateAndOutput(t *testing.T) {
	m := newManager(t)
	s, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	defer m.Kill(s.ID)
	if s.ID == "" {
		t.Fatal("empty session id")
	}

	// Send a command that produces known output.
	if err := s.Input([]byte("echo termtest\n")); err != nil {
		t.Fatal(err)
	}
	deadline := time.After(3 * time.Second)
	got := ""
	for got == "" {
		select {
		case chunk := <-s.Out():
			got += string(chunk)
			if contains(got, "termtest") {
				return
			}
		case <-deadline:
			t.Fatalf("no output within deadline; got %q", got)
		}
	}
}

func contains(haystack, needle string) bool {
	for i := 0; i+len(needle) <= len(haystack); i++ {
		if haystack[i:i+len(needle)] == needle {
			return true
		}
	}
	return false
}

func TestSessionLimit(t *testing.T) {
	m := NewManager(1, time.Minute, "/bin/sh")
	s1, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	defer m.Kill(s1.ID)
	if _, err := m.Create(80, 24, ""); err != ErrFull {
		t.Fatalf("second create = %v, want ErrFull", err)
	}
}

func TestGetAndKill(t *testing.T) {
	m := newManager(t)
	s, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	if _, ok := m.Get(s.ID); !ok {
		t.Fatal("session not found")
	}
	if err := m.Kill(s.ID); err != nil {
		t.Fatal(err)
	}
	if _, ok := m.Get(s.ID); ok {
		t.Fatal("session still present after kill")
	}
	if err := m.Kill(s.ID); err != ErrNotFound {
		t.Fatalf("double kill = %v, want ErrNotFound", err)
	}
}

func TestInputClosedSession(t *testing.T) {
	m := newManager(t)
	s, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	m.Kill(s.ID)
	if err := s.Input([]byte("x")); err != ErrClosed {
		t.Fatalf("input after kill = %v, want ErrClosed", err)
	}
}

func TestKillAll(t *testing.T) {
	m := newManager(t)
	s1, _ := m.Create(80, 24, "")
	s2, _ := m.Create(80, 24, "")
	m.KillAll()
	if _, ok := m.Get(s1.ID); ok {
		t.Fatal("session 1 survived KillAll")
	}
	if _, ok := m.Get(s2.ID); ok {
		t.Fatal("session 2 survived KillAll")
	}
}

func TestSweep(t *testing.T) {
	m := NewManager(4, 1*time.Second, "/bin/sh")
	s, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	// Age the session beyond the idle TTL.
	s.mu.Lock()
	s.lastActive = time.Now().Add(-10 * time.Second)
	s.mu.Unlock()
	m.Sweep()
	if _, ok := m.Get(s.ID); ok {
		t.Fatal("idle session not swept")
	}
}

func TestAttachDetach(t *testing.T) {
	m := newManager(t)
	s, err := m.Create(80, 24, "")
	if err != nil {
		t.Fatal(err)
	}
	defer m.Kill(s.ID)
	s.Attach()
	s.Detach()
	s.Attach()
	s.Detach()
}
