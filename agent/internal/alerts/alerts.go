// Package alerts implements threshold evaluation with debounce and the alert
// buffer (docs/10 §4.5, docs/11 §8).
package alerts

import (
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/qwe1/qwe1/agent/internal/host"
)

// Severities.
const (
	SevCritical = "critical"
	SevWarning  = "warning"
	SevInfo     = "info"
)

// Alert is a single alert record.
type Alert struct {
	ID       string         `json:"id"`
	Severity string         `json:"severity"`
	Type     string         `json:"type"`
	Message  string         `json:"message"`
	At       time.Time      `json:"at"`
	Acked    bool           `json:"acked"`
	Context  map[string]any `json:"context"`
}

// Threshold is a value+duration rule (debounced).
type Threshold struct {
	Value      float64
	ForSeconds time.Duration
}

// Rules bundles all threshold rules.
type Rules struct {
	CPUPercent    Threshold
	MemPercent    Threshold
	SwapPercent   Threshold
	DiskPercent   Threshold
	TempCelsius   Threshold
	ContainerDown bool
}

// Engine evaluates metrics and docker events against rules.
type Engine struct {
	mu        sync.Mutex
	rules     Rules
	buffer    []Alert
	maxBuffer int
	breachAt  map[string]time.Time
	active    map[string]bool
	downCtrs  map[string]bool
	now       func() time.Time
	onAlert   func(Alert)
}

// New creates an Engine. onAlert (may be nil) is invoked synchronously for
// every new alert so the server can push to WS clients.
func New(rules Rules, maxBuffer int, onAlert func(Alert)) *Engine {
	if maxBuffer <= 0 {
		maxBuffer = 200
	}
	return &Engine{
		rules:     rules,
		buffer:    []Alert{},
		maxBuffer: maxBuffer,
		breachAt:  map[string]time.Time{},
		active:    map[string]bool{},
		downCtrs:  map[string]bool{},
		now:       time.Now,
		onAlert:   onAlert,
	}
}

// SetClock overrides the clock (tests).
func (e *Engine) SetClock(now func() time.Time) { e.now = now }

// Rules returns a copy of the current rules.
func (e *Engine) Rules() Rules {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.rules
}

// UpdateRules replaces the threshold rules.
func (e *Engine) UpdateRules(r Rules) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.rules = r
}

// EvaluateHost runs threshold checks against a metrics snapshot. Called on
// every collected sample.
func (e *Engine) EvaluateHost(m *host.Metrics) {
	now := e.now()
	e.check(now, "host.cpu", SevCritical, "CPU above %.0f%% for %s",
		m.CPU.Percent, e.rules.CPUPercent, map[string]any{"percent": m.CPU.Percent})
	e.check(now, "host.mem", SevCritical, "Memory above %.0f%% for %s",
		m.Memory.Percent, e.rules.MemPercent, map[string]any{"percent": m.Memory.Percent})
	e.check(now, "host.swap", SevWarning, "Swap above %.0f%% for %s",
		m.Memory.SwapPercent, e.rules.SwapPercent, map[string]any{"percent": m.Memory.SwapPercent})
	for _, d := range m.Disk {
		e.check(now, "host.disk:"+d.Mount, SevCritical, "Disk %s above %.0f%% for %s",
			d.Percent, e.rules.DiskPercent, map[string]any{"mount": d.Mount, "percent": d.Percent})
	}
	for _, t := range m.Temp.Sensors {
		e.check(now, "host.temp:"+t.Name, SevCritical, "Temperature %s at %.1f°C for %s",
			t.Celsius, e.rules.TempCelsius, map[string]any{"sensor": t.Name, "celsius": t.Celsius})
	}
}

// ContainerDown reports a container as down (from a docker event).
func (e *Engine) ContainerDown(name string) {
	e.mu.Lock()
	if e.downCtrs[name] {
		e.mu.Unlock()
		return
	}
	e.downCtrs[name] = true
	e.mu.Unlock()
	e.emit(Alert{
		Severity: SevCritical,
		Type:     "container.down",
		Message:  "Container " + name + " stopped",
		At:       e.now(),
		Context:  map[string]any{"container": name},
	})
}

// ContainerUp clears a container-down alert.
func (e *Engine) ContainerUp(name string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	delete(e.downCtrs, name)
	for i := range e.buffer {
		if e.buffer[i].Type == "container.down" && e.buffer[i].Context["container"] == name {
			e.buffer[i].Acked = true
		}
	}
}

// List returns buffered alerts newest-first, optionally filtered.
func (e *Engine) List(severity string, limit int) []Alert {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := []Alert{}
	for i := len(e.buffer) - 1; i >= 0; i-- {
		a := e.buffer[i]
		if severity != "" && a.Severity != severity {
			continue
		}
		out = append(out, a)
		if limit > 0 && len(out) >= limit {
			break
		}
	}
	return out
}

// Ack marks an alert acknowledged.
func (e *Engine) Ack(id string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	for i := range e.buffer {
		if e.buffer[i].ID == id {
			e.buffer[i].Acked = true
			return
		}
	}
}

// check evaluates a single threshold rule with debounce + dedupe.
func (e *Engine) check(now time.Time, typ, sev, format string, value float64, t Threshold, ctx map[string]any) {
	if t.Value <= 0 {
		return
	}
	e.mu.Lock()
	defer e.mu.Unlock()
	if value >= t.Value {
		if _, ok := e.breachAt[typ]; !ok {
			e.breachAt[typ] = now
		}
		if e.active[typ] {
			return // already alerted for this breach
		}
		if now.Sub(e.breachAt[typ]) >= t.ForSeconds {
			e.active[typ] = true
			e.emitLocked(Alert{
				Severity: sev,
				Type:     typ,
				Message:  fmt.Sprintf(format, value, durHuman(t.ForSeconds)),
				At:       now,
				Context:  ctx,
			})
		}
		return
	}
	delete(e.breachAt, typ)
	delete(e.active, typ)
}

func (e *Engine) emit(a Alert) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.emitLocked(a)
}

func (e *Engine) emitLocked(a Alert) {
	if a.ID == "" {
		a.ID = "al_" + uuid.NewString()[:12]
	}
	if a.At.IsZero() {
		a.At = e.now()
	}
	e.buffer = append(e.buffer, a)
	if len(e.buffer) > e.maxBuffer {
		e.buffer = e.buffer[len(e.buffer)-e.maxBuffer:]
	}
	if e.onAlert != nil {
		e.onAlert(a)
	}
}

func durHuman(d time.Duration) string {
	switch {
	case d >= time.Minute:
		return fmt.Sprintf("%dm", int(d.Minutes()))
	case d >= time.Second:
		return fmt.Sprintf("%ds", int(d.Seconds()))
	default:
		return "0s"
	}
}
