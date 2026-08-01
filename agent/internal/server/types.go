package server

import (
	"time"

	"github.com/qwe1/qwe1/agent/internal/alerts"
	"github.com/qwe1/qwe1/agent/internal/docker"
	"github.com/qwe1/qwe1/agent/internal/host"
)

// hostMetricsJSON is the metrics payload shape (docs/11 §4).
type hostMetricsJSON = host.Metrics

// dockerLogLineJSON is the container log line shape (docs/11 §5).
type dockerLogLineJSON = docker.LogLine

// alertsThreshold is the threshold JSON shape (docs/11 §8).
type alertsThreshold struct {
	Value      float64 `json:"value"`
	ForSeconds int64   `json:"forSeconds"`
}

func thresholdJSON(t alerts.Threshold) alertsThreshold {
	return alertsThreshold{Value: t.Value, ForSeconds: int64(t.ForSeconds / time.Second)}
}
