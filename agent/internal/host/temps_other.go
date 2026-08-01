//go:build !linux

package host

// readTemps returns no sensors on non-Linux platforms (temperature monitoring
// is a Linux feature in v1).
func readTemps() TempInfo {
	return TempInfo{}
}
