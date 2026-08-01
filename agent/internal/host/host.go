// Package host collects host metrics (CPU, memory, disk, network, temperature,
// uptime, load) for the dashboard and alert engine (docs/11 §4).
package host

import (
	"context"
	"time"

	"github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/disk"
	"github.com/shirou/gopsutil/v4/host"
	"github.com/shirou/gopsutil/v4/load"
	"github.com/shirou/gopsutil/v4/mem"
	"github.com/shirou/gopsutil/v4/net"
)

// Metrics is a point-in-time snapshot of host state.
type Metrics struct {
	Timestamp time.Time  `json:"timestamp"`
	Hostname  string     `json:"hostname"`
	UptimeSec uint64     `json:"uptimeSeconds"`
	Load      []float64  `json:"load"`
	CPU       CPUInfo    `json:"cpu"`
	Memory    MemoryInfo `json:"memory"`
	Disk      []DiskInfo `json:"disk"`
	Network   NetInfo    `json:"network"`
	Temp      TempInfo   `json:"temp"`
}

// CPUInfo holds CPU utilization.
type CPUInfo struct {
	Percent  float64   `json:"percent"`
	PerCore  []float64 `json:"perCore"`
	Cores    int       `json:"cores"`
}

// MemoryInfo holds memory and swap utilization.
type MemoryInfo struct {
	TotalBytes  uint64  `json:"total"`
	UsedBytes   uint64  `json:"used"`
	Percent     float64 `json:"percent"`
	SwapPercent float64 `json:"swapPercent"`
}

// DiskInfo holds per-mount disk utilization.
type DiskInfo struct {
	Mount      string  `json:"mount"`
	TotalBytes uint64  `json:"total"`
	UsedBytes  uint64  `json:"used"`
	Percent    float64 `json:"percent"`
}

// NetInfo holds network throughput rates.
type NetInfo struct {
	RXBytesPerSec uint64 `json:"rxBytesPerSec"`
	TXBytesPerSec uint64 `json:"txBytesPerSec"`
}

// TempInfo holds per-sensor temperatures (empty if none available).
type TempInfo struct {
	Sensors []TempSensor `json:"sensors"`
}

// TempSensor is a single temperature reading.
type TempSensor struct {
	Name    string  `json:"name"`
	Celsius float64 `json:"celsius"`
}

// Collector samples host metrics on a ticker and keeps the latest snapshot.
type Collector struct {
	interval time.Duration
	last     net.IOCountersStat
	lastN    time.Time
	latest   *Metrics
}

// NewCollector creates a collector sampling every interval.
func NewCollector(interval time.Duration) *Collector {
	c := &Collector{interval: interval}
	if c.interval <= 0 {
		c.interval = 5 * time.Second
	}
	return c
}

// Run starts the sampling loop; blocks until ctx is cancelled.
func (c *Collector) Run(ctx context.Context) {
	for {
		if m := c.Sample(); m != nil {
			c.latest = m
		}
		select {
		case <-ctx.Done():
			return
		case <-time.After(c.interval):
		}
	}
}

// Latest returns the most recent snapshot, or a fresh one if never sampled.
func (c *Collector) Latest() *Metrics {
	if c.latest != nil {
		return c.latest
	}
	return c.Sample()
}

// Sample takes an immediate snapshot.
func (c *Collector) Sample() *Metrics {
	m := &Metrics{Timestamp: time.Now().UTC()}

	if hi, err := host.Info(); err == nil {
		m.Hostname = hi.Hostname
		m.UptimeSec = hi.Uptime
	}
	if la, err := load.Avg(); err == nil {
		m.Load = []float64{la.Load1, la.Load5, la.Load15}
	}

	if p, err := cpu.Percent(0, false); err == nil && len(p) > 0 {
		m.CPU.Percent = p[0]
	}
	if pc, err := cpu.Percent(0, true); err == nil {
		m.CPU.PerCore = pc
	}
	if n, err := cpu.Counts(true); err == nil {
		m.CPU.Cores = n
	}

	if vm, err := mem.VirtualMemory(); err == nil {
		m.Memory.TotalBytes = vm.Total
		m.Memory.UsedBytes = vm.Used
		m.Memory.Percent = vm.UsedPercent
		if sm, err := mem.SwapMemory(); err == nil {
			m.Memory.SwapPercent = sm.UsedPercent
		}
	}

	if parts, err := disk.Partitions(false); err == nil {
		for _, p := range parts {
			if pseudoFS(p.Fstype) {
				continue
			}
			if u, err := disk.Usage(p.Mountpoint); err == nil {
				m.Disk = append(m.Disk, DiskInfo{
					Mount:      p.Mountpoint,
					TotalBytes: u.Total,
					UsedBytes:  u.Used,
					Percent:    u.UsedPercent,
				})
			}
		}
	}

	// Network rate via counter diff.
	if n, err := net.IOCounters(false); err == nil && len(n) > 0 {
		now := time.Now()
		if !c.lastN.IsZero() {
			dt := now.Sub(c.lastN).Seconds()
			if dt > 0 {
				m.Network.RXBytesPerSec = uint64(float64(n[0].BytesRecv-c.last.BytesRecv) / dt)
				m.Network.TXBytesPerSec = uint64(float64(n[0].BytesSent-c.last.BytesSent) / dt)
			}
		}
		c.last = n[0]
		c.lastN = now
	}

	m.Temp = readTemps()
	return m
}

func pseudoFS(fs string) bool {
	switch fs {
	case "proc", "sysfs", "devtmpfs", "tmpfs", "cgroup", "cgroup2",
		"devpts", "mqueue", "securityfs", "debugfs", "tracefs", "fusectl",
		"configfs", "binfmt_misc", "pstore", "efivarfs", "autofs", "overlay":
		return true
	}
	return false
}

// HasTempSensors reports whether the last sample found temperature sensors.
func (m *Metrics) HasTempSensors() bool {
	return len(m.Temp.Sensors) > 0
}
