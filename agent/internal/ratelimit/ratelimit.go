// Package ratelimit implements a token-bucket limiter used by the server
// middleware (docs/14 §11).
package ratelimit

import (
	"sync"
	"time"
)

// Limiter is a token-bucket rate limiter keyed by string (IP or token ID).
type Limiter struct {
	mu       sync.Mutex
	rate     float64 // tokens per second
	burst    int
	buckets  map[string]*bucket
	lastSeen time.Time
}

type bucket struct {
	tokens float64
	last   time.Time
}

// New creates a limiter refilling at rate tokens/sec up to burst.
func New(rate float64, burst int) *Limiter {
	return &Limiter{
		rate:    rate,
		burst:   burst,
		buckets: map[string]*bucket{},
		lastSeen: time.Now(),
	}
}

// Allow reports whether key may take one token.
func (l *Limiter) Allow(key string) bool {
	return l.Take(key, 1)
}

// Take reports whether key may take n tokens.
func (l *Limiter) Take(key string, n int) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	now := time.Now()
	b, ok := l.buckets[key]
	if !ok {
		b = &bucket{tokens: float64(l.burst), last: now}
		l.buckets[key] = b
	}
	// Refill.
	elapsed := now.Sub(b.last).Seconds()
	b.tokens += elapsed * l.rate
	if b.tokens > float64(l.burst) {
		b.tokens = float64(l.burst)
	}
	b.last = now
	if b.tokens >= float64(n) {
		b.tokens -= float64(n)
		return true
	}
	return false
}

// Cleanup prunes buckets idle for longer than maxAge. Call periodically.
func (l *Limiter) Cleanup(maxAge time.Duration) {
	l.mu.Lock()
	defer l.mu.Unlock()
	cutoff := time.Now().Add(-maxAge)
	for k, b := range l.buckets {
		if b.last.Before(cutoff) {
			delete(l.buckets, k)
		}
	}
}
