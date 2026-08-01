package alerts

import (
	"testing"
	"time"

	"github.com/qwe1/qwe1/agent/internal/host"
)

func threshold(seconds time.Duration) Threshold {
	return Threshold{Value: 90, ForSeconds: seconds}
}

func now(t time.Time) time.Time { return t }

func TestDebounceEmitsAfterFor(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(2 * time.Second)}, 10, nil)
	base := time.Now().Truncate(time.Second)
	e.SetClock(func() time.Time { return base })
	m := &host.Metrics{CPU: host.CPUInfo{Percent: 99.9}}

	// Breach starts; nothing yet.
	e.EvaluateHost(m)
	if len(e.List("", 10)) != 0 {
		t.Fatal("alert emitted before debounce window")
	}
	// Still within window.
	e.SetClock(func() time.Time { return base.Add(time.Second) })
	e.EvaluateHost(m)
	if len(e.List("", 10)) != 0 {
		t.Fatal("alert emitted before debounce window elapsed")
	}
	// Window elapsed.
	e.SetClock(func() time.Time { return base.Add(2*time.Second + 1) })
	e.EvaluateHost(m)
	list := e.List("", 10)
	if len(list) != 1 {
		t.Fatalf("expected 1 alert, got %d", len(list))
	}
	if list[0].Type != "host.cpu" || list[0].Severity != SevCritical {
		t.Fatalf("alert = %+v", list[0])
	}
}

func TestDedupeWhileBreachPersists(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(0)}, 10, nil)
	base := time.Now()
	e.SetClock(func() time.Time { return base })
	m := &host.Metrics{CPU: host.CPUInfo{Percent: 95}}

	e.EvaluateHost(m)
	e.SetClock(func() time.Time { return base.Add(time.Minute) })
	e.EvaluateHost(m)
	if len(e.List("", 10)) != 1 {
		t.Fatalf("expected dedupe to 1 alert, got %d", len(e.List("", 10)))
	}
}

func TestRecoversAndReAlerts(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(0)}, 10, nil)
	base := time.Now()
	e.SetClock(func() time.Time { return base })
	mHigh := &host.Metrics{CPU: host.CPUInfo{Percent: 95}}
	mLow := &host.Metrics{CPU: host.CPUInfo{Percent: 10}}

	e.EvaluateHost(mHigh)
	if len(e.List("", 10)) != 1 {
		t.Fatal("expected first alert")
	}
	e.EvaluateHost(mLow)
	e.SetClock(func() time.Time { return base.Add(time.Minute) })
	e.EvaluateHost(mHigh)
	if len(e.List("", 10)) != 2 {
		t.Fatalf("expected second alert after recovery, got %d", len(e.List("", 10)))
	}
}

func TestThresholdDisabledWhenValueZero(t *testing.T) {
	e := New(Rules{}, 10, nil)
	e.EvaluateHost(&host.Metrics{CPU: host.CPUInfo{Percent: 99}, Memory: host.MemoryInfo{Percent: 99}})
	if len(e.List("", 10)) != 0 {
		t.Fatal("disabled thresholds should not alert")
	}
}

func TestContainerDownUp(t *testing.T) {
	e := New(Rules{ContainerDown: true}, 10, nil)
	base := time.Now()
	e.SetClock(func() time.Time { return base })
	e.ContainerDown("web")
	if len(e.List("", 10)) != 1 {
		t.Fatal("expected container.down alert")
	}
	e.ContainerDown("web") // deduped
	if len(e.List("", 10)) != 1 {
		t.Fatal("container.down should dedupe")
	}
	e.ContainerUp("web")
	alerts := e.List("", 10)
	if len(alerts) != 1 {
		t.Fatal("container.down alert should remain")
	}
	if !alerts[0].Acked {
		t.Fatal("container.down alert should be acked after up")
	}
}

func TestBufferBounded(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(0)}, 5, nil)
	base := time.Now()
	m := &host.Metrics{CPU: host.CPUInfo{Percent: 95}}
	for i := 0; i < 10; i++ {
		e.SetClock(func() time.Time { return base.Add(time.Duration(i) * time.Minute) })
		e.EvaluateHost(m)
		// Force a recovery each round so each produces a new alert.
		e.EvaluateHost(&host.Metrics{CPU: host.CPUInfo{Percent: 5}})
	}
	if got := len(e.List("", 0)); got != 5 {
		t.Fatalf("buffer size = %d, want 5", got)
	}
}

func TestAck(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(0)}, 10, nil)
	m := &host.Metrics{CPU: host.CPUInfo{Percent: 95}}
	e.EvaluateHost(m)
	list := e.List("", 10)
	if len(list) != 1 {
		t.Fatal("expected one alert")
	}
	id := list[0].ID
	e.Ack(id)
	list = e.List("", 10)
	if !list[0].Acked {
		t.Fatal("alert not acked")
	}
}

func TestListFilter(t *testing.T) {
	e := New(Rules{CPUPercent: threshold(0), MemPercent: threshold(0)}, 10, nil)
	m := &host.Metrics{CPU: host.CPUInfo{Percent: 95}, Memory: host.MemoryInfo{Percent: 95}}
	e.EvaluateHost(m)
	if got := len(e.List(SevWarning, 10)); got != 0 {
		t.Fatalf("warning-only list = %d, want 0", got)
	}
	if got := len(e.List(SevCritical, 10)); got != 2 {
		t.Fatalf("critical list = %d, want 2", got)
	}
}

func TestOnAlertCallback(t *testing.T) {
	var got []Alert
	e := New(Rules{CPUPercent: threshold(0)}, 10, func(a Alert) { got = append(got, a) })
	e.EvaluateHost(&host.Metrics{CPU: host.CPUInfo{Percent: 95}})
	if len(got) != 1 {
		t.Fatalf("callback count = %d, want 1", len(got))
	}
}
