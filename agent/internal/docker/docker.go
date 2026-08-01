// Package docker wraps the Docker Engine API for container management
// (docs/11 §5). All interactions go through the official Docker client.
package docker

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/client"
	"github.com/docker/docker/pkg/stdcopy"
)

// Container is the summary shape returned to the app (docs/11 §5).
type Container struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Image       string    `json:"image"`
	State       string    `json:"state"`
	Status      string    `json:"status"`
	Health      string    `json:"health"`
	Ports       []PortMap `json:"ports"`
	CPUPercent  float64   `json:"cpuPercent"`
	MemoryBytes uint64    `json:"memoryBytes"`
	CreatedAt   time.Time `json:"createdAt"`
}

// PortMap is a single published port.
type PortMap struct {
	Host      string `json:"host"`
	Container string `json:"container"`
	Protocol  string `json:"protocol"`
}

// Manager wraps the Docker client.
type Manager struct {
	cli *client.Client
}

// New creates a Manager from the Docker environment (defaults to the local
// unix socket). It returns nil, nil if Docker is not reachable so the agent
// can report the capability as absent.
func New() (*Manager, error) {
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if _, err := cli.Ping(ctx); err != nil {
		return nil, err
	}
	return &Manager{cli: cli}, nil
}

// Available reports whether Docker was reachable at construction.
func (m *Manager) Available() bool { return m != nil }

// ListContainers returns all containers, optionally annotated with resource
// usage via `docker stats` snapshots.
func (m *Manager) ListContainers(ctx context.Context, withStats bool) ([]Container, error) {
	cs, err := m.cli.ContainerList(ctx, container.ListOptions{All: true})
	if err != nil {
		return nil, err
	}
	out := make([]Container, 0, len(cs))
	for _, c := range cs {
		name := strings.TrimPrefix(c.Names[0], "/")
		ct := Container{
			ID:        c.ID,
			Name:      name,
			Image:     c.Image,
			State:     c.State,
			Status:    c.Status,
			CreatedAt: time.Unix(c.Created, 0).UTC(),
		}
		ct.Health = healthFromStatus(c.Status)
		for _, p := range c.Ports {
			port := PortMap{Protocol: p.Type}
			if p.PublicPort != 0 {
				port.Host = fmt.Sprintf("%d", p.PublicPort)
			}
			if p.PrivatePort != 0 {
				port.Container = fmt.Sprintf("%d", p.PrivatePort)
			}
			ct.Ports = append(ct.Ports, port)
		}
		out = append(out, ct)
	}
	if withStats {
		m.annotateStats(ctx, out)
	}
	return out, nil
}

// healthFromStatus derives health from the docker "Status" display string
// (e.g. "Up 3 days (healthy)").
func healthFromStatus(status string) string {
	switch {
	case strings.Contains(status, "(healthy)"):
		return "healthy"
	case strings.Contains(status, "(unhealthy)"):
		return "unhealthy"
	case strings.Contains(status, "(health: starting)"):
		return "starting"
	default:
		return ""
	}
}

func (m *Manager) annotateStats(ctx context.Context, list []Container) {
	sem := make(chan struct{}, 8) // bounded concurrency
	done := make(chan struct{})
	for i := range list {
		sem <- struct{}{}
		go func(i int) {
			defer func() { <-sem; done <- struct{}{} }()
			s, err := m.cli.ContainerStatsOneShot(ctx, list[i].ID)
			if err != nil {
				return
			}
			defer s.Body.Close()
			var v types.StatsJSON
			if err := json.NewDecoder(s.Body).Decode(&v); err != nil {
				return
			}
			list[i].CPUPercent = cpuPercent(&v)
			list[i].MemoryBytes = v.MemoryStats.Usage
		}(i)
	}
	for range list {
		<-done
	}
}

// cpuPercent computes container CPU % from a stats snapshot.
func cpuPercent(v *types.StatsJSON) float64 {
	if v.CPUStats.CPUUsage.TotalUsage == 0 {
		return 0
	}
	cpuDelta := float64(v.CPUStats.CPUUsage.TotalUsage) - float64(v.PreCPUStats.CPUUsage.TotalUsage)
	sysDelta := float64(v.CPUStats.SystemUsage) - float64(v.PreCPUStats.SystemUsage)
	if sysDelta <= 0 || cpuDelta <= 0 {
		return 0
	}
	online := float64(len(v.CPUStats.CPUUsage.PercpuUsage))
	if online == 0 {
		online = 1
	}
	return (cpuDelta / sysDelta) * online * 100.0
}

// Inspect returns the raw inspect JSON with secret-pattern env keys masked
// (docs/14 §13).
func (m *Manager) Inspect(ctx context.Context, id string) (json.RawMessage, error) {
	raw, _, err := m.cli.ContainerInspectWithRaw(ctx, id, false)
	if err != nil {
		return nil, err
	}
	b, err := json.Marshal(raw)
	if err != nil {
		return nil, err
	}
	return maskSecrets(b), nil
}

var secretEnvRe = regexp.MustCompile(`(?i)"((?:MYSQL|POSTGRES|REDIS|MONGO)_?[A-Z0-9_]*|PASSWORD|SECRET|TOKEN|APIKEY|ACCESSKEY|PRIVATEKEY|[A-Z0-9_]*KEY[A-Z0-9_]*|AUTH[A-Z0-9_]*)=[^"]*"`)

// maskSecrets rewrites env entries whose keys look secret to "********".
func maskSecrets(in []byte) []byte {
	return secretEnvRe.ReplaceAll(in, []byte(`"$1=********"`))
}

// LogLine is a single log frame.
type LogLine struct {
	Stream string `json:"stream"` // stdout | stderr
	Line   string `json:"line"`
	Seq    uint64 `json:"seq"`
}

// lineWriter buffers stream data and emits complete lines to cb.
type lineWriter struct {
	stream string
	cb     func(LogLine)
	seq    *uint64
	buf    bytes.Buffer
}

func (w *lineWriter) Write(p []byte) (int, error) {
	w.buf.Write(p)
	for {
		idx := bytes.IndexByte(w.buf.Bytes(), '\n')
		if idx < 0 {
			break
		}
		line := strings.TrimRight(w.buf.String()[:idx], "\r")
		w.buf.Next(idx + 1)
		*w.seq++
		w.cb(LogLine{Stream: w.stream, Line: line, Seq: *w.seq})
	}
	return len(p), nil
}

// StreamLogs tails (and optionally follows) container logs, invoking cb per
// complete line. Errors after streaming starts abort the stream.
func (m *Manager) StreamLogs(ctx context.Context, id string, tail int, follow bool, cb func(LogLine)) error {
	if tail <= 0 {
		tail = 200
	}
	opts := container.LogsOptions{
		ShowStdout: true,
		ShowStderr: true,
		Follow:     follow,
		Tail:       fmt.Sprint(tail),
	}
	rd, err := m.cli.ContainerLogs(ctx, id, opts)
	if err != nil {
		return err
	}
	defer rd.Close()

	var seq uint64
	outW := &lineWriter{stream: "stdout", cb: cb, seq: &seq}
	errW := &lineWriter{stream: "stderr", cb: cb, seq: &seq}
	_, err = stdcopy.StdCopy(outW, errW, rd)
	if err != nil && ctx.Err() == nil {
		return err
	}
	return nil
}

// Event is a docker event forwarded to WS clients.
type Event struct {
	Action string `json:"action"`
	Name   string `json:"name"`
	Time   int64  `json:"time"`
}

// StreamEvents forwards container state-change events until ctx cancels.
func (m *Manager) StreamEvents(ctx context.Context, cb func(Event)) error {
	f := filters.NewArgs()
	f.Add("type", "container")
	msgs, errs := m.cli.Events(ctx, types.EventsOptions{Filters: f})
	for {
		select {
		case err, ok := <-errs:
			if !ok {
				return nil
			}
			return err
		case msg, ok := <-msgs:
			if !ok {
				return nil
			}
			name := ""
			if n, ok := msg.Actor.Attributes["name"]; ok {
				name = n
			}
			cb(Event{Action: string(msg.Action), Name: name, Time: msg.Time})
		}
	}
}

// Start starts a container.
func (m *Manager) Start(ctx context.Context, id string) error {
	return m.cli.ContainerStart(ctx, id, container.StartOptions{})
}

// Stop stops a container (default 10s timeout).
func (m *Manager) Stop(ctx context.Context, id string) error {
	timeout := 10
	return m.cli.ContainerStop(ctx, id, container.StopOptions{Timeout: &timeout})
}

// Restart restarts a container (default 10s timeout).
func (m *Manager) Restart(ctx context.Context, id string) error {
	timeout := 10
	return m.cli.ContainerRestart(ctx, id, container.StopOptions{Timeout: &timeout})
}

// Pause pauses a running container.
func (m *Manager) Pause(ctx context.Context, id string) error {
	return m.cli.ContainerPause(ctx, id)
}

// Unpause resumes a paused container.
func (m *Manager) Unpause(ctx context.Context, id string) error {
	return m.cli.ContainerUnpause(ctx, id)
}

// Kill sends SIGKILL to a container.
func (m *Manager) Kill(ctx context.Context, id string) error {
	return m.cli.ContainerKill(ctx, id, "KILL")
}

// Remove deletes a container (optionally force and/or removing volumes).
func (m *Manager) Remove(ctx context.Context, id string, force, removeVolumes bool) error {
	return m.cli.ContainerRemove(ctx, id, container.RemoveOptions{Force: force, RemoveVolumes: removeVolumes})
}

// Close releases the Docker client.
func (m *Manager) Close() error {
	if m != nil && m.cli != nil {
		return m.cli.Close()
	}
	return nil
}
