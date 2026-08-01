package ratelimit

import (
	"testing"
	"time"
)

func TestBurst(t *testing.T) {
	l := New(1, 3)
	for i := 0; i < 3; i++ {
		if !l.Allow("ip") {
			t.Fatalf("allow %d failed within burst", i)
		}
	}
	if l.Allow("ip") {
		t.Fatal("allowed beyond burst")
	}
}

func TestRefill(t *testing.T) {
	l := New(100, 1)
	if !l.Allow("k") {
		t.Fatal("first should be allowed")
	}
	if l.Allow("k") {
		t.Fatal("second within window should fail")
	}
	time.Sleep(30 * time.Millisecond)
	if !l.Allow("k") {
		t.Fatal("refill should allow after time")
	}
}

func TestIndependentKeys(t *testing.T) {
	l := New(0, 1)
	if !l.Allow("a") {
		t.Fatal("a should be allowed")
	}
	if !l.Allow("b") {
		t.Fatal("b should be independent")
	}
	if l.Allow("a") {
		t.Fatal("a exhausted")
	}
}

func TestTakeMultiple(t *testing.T) {
	l := New(1, 10)
	if !l.Take("k", 5) {
		t.Fatal("should take 5")
	}
	if !l.Take("k", 5) {
		t.Fatal("should take remaining 5")
	}
	if l.Take("k", 1) {
		t.Fatal("no tokens left")
	}
}

func TestCleanup(t *testing.T) {
	l := New(1, 1)
	l.Allow("old")
	l.Allow("fresh")
	// Age the "old" bucket.
	l.mu.Lock()
	l.buckets["old"].last = time.Now().Add(-time.Hour)
	l.mu.Unlock()
	l.Cleanup(10 * time.Minute)
	if _, ok := l.buckets["old"]; ok {
		t.Fatal("old bucket not cleaned")
	}
	if _, ok := l.buckets["fresh"]; !ok {
		t.Fatal("fresh bucket should remain")
	}
}
