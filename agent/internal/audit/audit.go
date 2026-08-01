// Package audit provides a bounded, in-memory audit log of privileged actions
// (docs/14 §10). Entries never contain payload contents.
package audit

import (
	"sync"
	"time"
)

// Entry is a single audit record.
type Entry struct {
	TS     time.Time `json:"ts"`
	Actor  string    `json:"actor"`  // device ID
	Action string    `json:"action"` // e.g. container.restart
	Target string    `json:"target"` // e.g. container name / path
	Result string    `json:"result"` // ok | error
	IP     string    `json:"ip"`
}

// Log is a fixed-size ring buffer of audit entries.
type Log struct {
	mu     sync.RWMutex
	entries []Entry
	size   int
}

// New creates a Log that keeps at most size entries.
func New(size int) *Log {
	if size <= 0 {
		size = 100
	}
	return &Log{entries: make([]Entry, 0, size), size: size}
}

// Record appends an entry, evicting the oldest when full.
func (l *Log) Record(e Entry) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if len(l.entries) == l.size {
		l.entries = append(l.entries[:0], l.entries[1:]...)
	}
	l.entries = append(l.entries, e)
}

// List returns the entries newest-first.
func (l *Log) List(limit int) []Entry {
	l.mu.RLock()
	defer l.mu.RUnlock()
	n := len(l.entries)
	if limit > 0 && limit < n {
		n = limit
	}
	out := make([]Entry, n)
	for i := 0; i < n; i++ {
		out[i] = l.entries[len(l.entries)-1-i]
	}
	return out
}
