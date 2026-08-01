package auth

import (
	"sync"
	"time"
)

// AttemptTracker implements in-memory brute-force protection: failed attempts
// per key (e.g. client IP) within a window trigger a lockout. It is advisory —
// the definitive rate limiting lives in the middleware (docs/14 §11).
type AttemptTracker struct {
	mu         sync.Mutex
	window     time.Duration
	lockout    time.Duration
	maxAttempts int
	failures   map[string][]time.Time
	lockedUntil map[string]time.Time
}

func NewAttemptTracker(maxAttempts int, window, lockout time.Duration) *AttemptTracker {
	return &AttemptTracker{
		window:      window,
		lockout:     lockout,
		maxAttempts: maxAttempts,
		failures:    map[string][]time.Time{},
		lockedUntil: map[string]time.Time{},
	}
}

// Locked reports whether the key is currently locked out.
func (t *AttemptTracker) Locked(key string) bool {
	t.mu.Lock()
	defer t.mu.Unlock()
	until, ok := t.lockedUntil[key]
	if ok && time.Now().Before(until) {
		return true
	}
	if ok {
		delete(t.lockedUntil, key)
	}
	return false
}

// Fail records a failed attempt; returns true if this attempt triggers lockout.
func (t *AttemptTracker) Fail(key string) bool {
	t.mu.Lock()
	defer t.mu.Unlock()
	now := time.Now()
	fails := t.failures[key]
	cutoff := now.Add(-t.window)
	kept := fails[:0]
	for _, f := range fails {
		if f.After(cutoff) {
			kept = append(kept, f)
		}
	}
	kept = append(kept, now)
	t.failures[key] = kept
	if len(kept) >= t.maxAttempts {
		t.lockedUntil[key] = now.Add(t.lockout)
		t.failures[key] = nil
		return true
	}
	return false
}

// Success clears recorded failures for the key.
func (t *AttemptTracker) Success(key string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	delete(t.failures, key)
	delete(t.lockedUntil, key)
}
