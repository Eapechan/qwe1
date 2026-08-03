package alerts

import (
	"testing"
	"time"

	"github.com/qwe1/qwe1/agent/internal/host"
)

func TestNewEngine(t *testing.T) {
	e := New(Rules{}, 100, nil)
	if e == nil {
		t.Fatal("New() returned nil")
	}
}

func TestEvaluateHost(t *testing.T) {
	e := New(Rules{
		CPUPercent:  Threshold{Value: 90, ForSeconds: 0},
		MemPercent:  Threshold{Value: 90, ForSeconds: 0},
		DiskPercent: Threshold{Value: 85, ForSeconds: 0},
	}, 100, nil)

	m := &host.Metrics{
		Timestamp: time.Now().UTC(),
		CPU: host.CPUInfo{
			Percent: 95.0,
		},
		Memory: host.MemoryInfo{
			Percent: 50.0,
		},
		Disk: []host.DiskInfo{
			{Mount: "/", Percent: 90.0},
		},
	}

	e.EvaluateHost(m)

	alerts := e.List("", 10)
	if len(alerts) == 0 {
		t.Error("Expected alerts after threshold breach")
	}
}

func TestEvaluateHostNoBreach(t *testing.T) {
	e := New(Rules{
		CPUPercent: Threshold{Value: 90, ForSeconds: 0},
	}, 100, nil)

	m := &host.Metrics{
		Timestamp: time.Now().UTC(),
		CPU: host.CPUInfo{
			Percent: 50.0,
		},
	}

	e.EvaluateHost(m)

	alerts := e.List("", 10)
	if len(alerts) != 0 {
		t.Errorf("Expected no alerts, got %d", len(alerts))
	}
}

func TestContainerDown(t *testing.T) {
	e := New(Rules{}, 100, nil)

	e.ContainerDown("plex")

	alerts := e.List("", 10)
	if len(alerts) == 0 {
		t.Error("Expected alert after container down")
	}
	if alerts[0].Type != "container.down" {
		t.Errorf("alert type = %q, want container.down", alerts[0].Type)
	}
}

func TestContainerUpClearsAlert(t *testing.T) {
	e := New(Rules{}, 100, nil)

	e.ContainerDown("plex")
	e.ContainerUp("plex")

	alerts := e.List("", 10)
	for _, a := range alerts {
		if a.Type == "container.down" && !a.Acked {
			t.Error("container.down alert should be auto-acked on ContainerUp")
		}
	}
}

func TestAck(t *testing.T) {
	e := New(Rules{}, 100, nil)

	e.ContainerDown("plex")
	alerts := e.List("", 10)
	if len(alerts) == 0 {
		t.Fatal("Expected alert before ack")
	}

	e.Ack(alerts[0].ID)

	alerts = e.List("", 10)
	if len(alerts) == 0 {
		t.Fatal("Expected alert after ack")
	}
	if !alerts[0].Acked {
		t.Error("Alert should be acked")
	}
}

func TestListSeverityFilter(t *testing.T) {
	e := New(Rules{}, 100, nil)

	e.emit(Alert{Severity: SevCritical, Type: "test.critical"})
	e.emit(Alert{Severity: SevWarning, Type: "test.warning"})
	e.emit(Alert{Severity: SevInfo, Type: "test.info"})

	critical := e.List(SevCritical, 10)
	if len(critical) != 1 {
		t.Errorf("Expected 1 critical alert, got %d", len(critical))
	}
	if critical[0].Severity != SevCritical {
		t.Errorf("alert severity = %q, want critical", critical[0].Severity)
	}

	warnings := e.List(SevWarning, 10)
	if len(warnings) != 1 {
		t.Errorf("Expected 1 warning alert, got %d", len(warnings))
	}
}

func TestListLimit(t *testing.T) {
	e := New(Rules{}, 100, nil)

	for i := 0; i < 10; i++ {
		e.emit(Alert{Severity: SevInfo, Type: "test"})
	}

	alerts := e.List("", 5)
	if len(alerts) != 5 {
		t.Errorf("Expected 5 alerts with limit, got %d", len(alerts))
	}
}

func TestSetClock(t *testing.T) {
	now := time.Now().UTC()
	e := New(Rules{
		CPUPercent: Threshold{Value: 90, ForSeconds: 0},
	}, 100, nil)
	e.SetClock(func() time.Time { return now })

	m := &host.Metrics{
		Timestamp: now,
		CPU: host.CPUInfo{
			Percent: 95.0,
		},
	}

	e.EvaluateHost(m)
	alerts := e.List("", 10)
	if len(alerts) == 0 {
		t.Error("Expected alerts after threshold breach with fixed clock")
	}
}