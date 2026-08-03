// Package host collects host metrics (CPU, memory, disk, network, temperature,
// uptime, load) for the dashboard and alert engine (docs/11 §4).
package host

import (
	"context"
	"runtime"
	"time"

	"github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/disk"
	"github.com/shirou/gopsutil/v4/host"
	"github.com/shirou/gopsutil/v4/load"
	"github.com/shirou/gopsutil/v4/mem"
	"github.com/shirou/gopsutil/v4/net"
	"github.com/shirou/gopsutil/v4/process"
)

// Metrics is a point-in-time snapshot of host state.
type Metrics struct {
	Timestamp    time.Time   `json:"timestamp"`
	Hostname     string      `json:"hostname"`
	UptimeSec    uint64      `json:"uptimeSeconds"`
	Load         []float64   `json:"load"`
	CPU          CPUInfo     `json:"cpu"`
	Memory       MemoryInfo  `json:"memory"`
	Disk         []DiskInfo  `json:"disk"`
	Network      NetInfo     `json:"network"`
	Temp         TempInfo    `json:"temp"`
	Kernel       string      `json:"kernel"`
	Architecture string      `json:"architecture"`
	OS           string      `json:"os"`
	BootTime     time.Time   `json:"bootTime"`
	Users        int         `json:"users"`
	Processes    int         `json:"processes"`
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
	CacheBytes  uint64  `json:"cache"`
	BuffersBytes uint64 `json:"buffers"`
}

// DiskInfo holds per-mount disk utilization.
type DiskInfo struct {
	Mount      string      `json:"mount"`
	TotalBytes uint64      `json:"total"`
	UsedBytes  uint64      `json:"used"`
	Percent    float64     `json:"percent"`
	IO         DiskIOInfo  `json:"io"`
}

// DiskIOInfo holds per-mount disk I/O counters.
type DiskIOInfo struct {
	ReadBytes  uint64 `json:"readBytes"`
	WriteBytes uint64 `json:"writeBytes"`
	ReadCount  uint64 `json:"readCount"`
	WriteCount uint64 `json:"writeCount"`
}

// NetInfo holds network throughput rates.
type NetInfo struct {
	RXBytesPerSec uint64            `json:"rxBytesPerSec"`
	TXBytesPerSec uint64            `json:"txBytesPerSec"`
	Interfaces    []NetInterface    `json:"interfaces"`
}

// NetInterface holds per-interface network counters.
type NetInterface struct {
	Name      string  `json:"name"`
	RXBytes   uint64  `json:"rxBytes"`
	TXBytes   uint64  `json:"txBytes"`
	RXPackets uint64  `json:"rxPackets"`
	TXPackets uint64  `json:"txPackets"`
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
		m.Kernel = hi.KernelVersion
		m.Architecture = runtime.GOARCH
		m.OS = hi.Platform
		if hi.BootTime > 0 {
			m.BootTime = time.Unix(int64(hi.BootTime), 0).UTC()
		}
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
		m.Memory.CacheBytes = vm.Cached
		m.Memory.BuffersBytes = vm.Buffers
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

	// Disk IO counters (aggregate across all devices).
	if ioCounters, err := disk.IOCounters(); err == nil {
		var totalReadBytes, totalWriteBytes, totalReadCount, totalWriteCount uint64
		for _, io := range ioCounters {
			totalReadBytes += io.ReadBytes
			totalWriteBytes += io.WriteBytes
			totalReadCount += io.ReadCount
			totalWriteCount += io.WriteCount
		}
		for i := range m.Disk {
			m.Disk[i].IO = DiskIOInfo{
				ReadBytes:  totalReadBytes,
				WriteBytes: totalWriteBytes,
				ReadCount:  totalReadCount,
				WriteCount: totalWriteCount,
			}
		}
	}

	// Network rate via counter diff (aggregate).
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

	// Per-interface network counters.
	if ifaces, err := net.IOCounters(true); err == nil {
		for _, iface := range ifaces {
			m.Network.Interfaces = append(m.Network.Interfaces, NetInterface{
				Name:      iface.Name,
				RXBytes:   iface.BytesRecv,
				TXBytes:   iface.BytesSent,
				RXPackets: iface.PacketsRecv,
				TXPackets: iface.PacketsSent,
			})
		}
	}

	// System info.
	if hi, err := host.Info(); err == nil {
		m.Users = int(hi.Procs)
	}
	if pids, err := process.Pids(); err == nil {
		m.Processes = len(pids)
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
