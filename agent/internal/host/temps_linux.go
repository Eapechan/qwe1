//go:build linux

package host

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// readTemps reads CPU/core temperatures from the Linux thermal zone sysfs
// interface. Hardware without thermal zones yields an empty list and the
// capability is reported as absent (docs/10 §4.1).
func readTemps() TempInfo {
	out := TempInfo{}
	zones, err := os.ReadDir("/sys/class/thermal")
	if err != nil {
		return out
	}
	for _, z := range zones {
		name := z.Name()
		if !strings.HasPrefix(name, "thermal_zone") {
			continue
		}
		base := filepath.Join("/sys/class/thermal", name)
		traw, err := os.ReadFile(filepath.Join(base, "temp"))
		if err != nil {
			continue
		}
		milli, err := strconv.Atoi(strings.TrimSpace(string(traw)))
		if err != nil {
			continue
		}
		c := float64(milli) / 1000.0
		if c <= 0 {
			continue
		}
		label := name
		if l, err := os.ReadFile(filepath.Join(base, "type")); err == nil {
			label = strings.TrimSpace(string(l))
		}
		out.Sensors = append(out.Sensors, TempSensor{Name: label, Celsius: c})
	}
	return out
}
