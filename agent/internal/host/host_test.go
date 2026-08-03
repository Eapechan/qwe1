package host

import (
	"testing"
	"time"
)

func TestCollectorSample(t *testing.T) {
	c := NewCollector(1 * time.Second)
	m := c.Sample()

	if m == nil {
		t.Fatal("Sample() returned nil")
	}
	if m.Timestamp.IsZero() {
		t.Error("Timestamp should not be zero")
	}
	if m.Hostname == "" {
		t.Error("Hostname should not be empty")
	}
	if m.CPU.Cores <= 0 {
		t.Error("CPU cores should be > 0")
	}
	if m.Memory.TotalBytes == 0 {
		t.Error("Memory total should be > 0")
	}
	if len(m.Disk) == 0 {
		t.Error("Should have at least one disk mount")
	}
}

func TestCollectorLatest(t *testing.T) {
	c := NewCollector(1 * time.Second)

	m1 := c.Sample()
	if m1 == nil {
		t.Fatal("first Sample() returned nil")
	}

	m2 := c.Latest()
	if m2 == nil {
		t.Fatal("Latest() returned nil after Sample()")
	}
	if m2.Hostname != m1.Hostname {
		t.Error("Latest() should return the same snapshot as last Sample()")
	}
}

func TestMetricsHasTempSensors(t *testing.T) {
	c := NewCollector(1 * time.Second)
	m := c.Sample()

	// HasTempSensors should not panic and should return a bool
	_ = m.HasTempSensors()
}

func TestPseudoFS(t *testing.T) {
	cases := []struct {
		fs     string
		expect bool
	}{
		{"proc", true},
		{"sysfs", true},
		{"devtmpfs", true},
		{"tmpfs", true},
		{"ext4", false},
		{"xfs", false},
		{"", false},
	}
	for _, tc := range cases {
		if got := pseudoFS(tc.fs); got != tc.expect {
			t.Errorf("pseudoFS(%q) = %v, want %v", tc.fs, got, tc.expect)
		}
	}
}