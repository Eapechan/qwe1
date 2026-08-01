//go:build linux

package terminal

import "syscall"

// sysProcAttr places the child in its own process group/session so Kill can
// tear down the whole tree (docs/10 §4.3).
func sysProcAttr() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{Setsid: true, Setpgid: true}
}
