//go:build darwin

package terminal

import "syscall"

// sysProcAttr places the child in its own session on macOS.
func sysProcAttr() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{Setsid: true}
}
