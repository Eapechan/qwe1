package config

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestDefault(t *testing.T) {
	c := Default()
	if c.Listen != DefaultListen {
		t.Fatalf("listen = %q", c.Listen)
	}
	if c.Auth.TokenTTL != 15*time.Minute {
		t.Fatalf("token ttl = %v", c.Auth.TokenTTL)
	}
	if c.Auth.MaxDevices != 8 {
		t.Fatalf("max devices = %d", c.Auth.MaxDevices)
	}
	if c.Alert.Host.CPUPercent.Value != 90 {
		t.Fatalf("cpu threshold = %v", c.Alert.Host.CPUPercent.Value)
	}
	if c.Config.Dir != DefaultConfigDir {
		t.Fatalf("config dir = %q", c.Config.Dir)
	}
}

func TestLoadFromFile(t *testing.T) {
	dir := t.TempDir()
	cfgDir := filepath.Join(dir, "etc", "qwe1-agent")
	if err := os.MkdirAll(cfgDir, 0o755); err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(cfgDir, "config.yaml")
	content := `
listen: "127.0.0.1:9999"
read_only: true
auth:
  max_devices: 3
  token_ttl: 10m
files:
  max_read_bytes: 1048576
`
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	c, err := Load(path, nil)
	if err != nil {
		t.Fatal(err)
	}
	if c.Listen != "127.0.0.1:9999" {
		t.Fatalf("listen = %q", c.Listen)
	}
	if !c.ReadOnly {
		t.Fatal("read_only not set")
	}
	if c.Auth.MaxDevices != 3 {
		t.Fatalf("max devices = %d", c.Auth.MaxDevices)
	}
	if c.Auth.TokenTTL != 10*time.Minute {
		t.Fatalf("token ttl = %v", c.Auth.TokenTTL)
	}
	if c.Files.MaxReadBytes != 1048576 {
		t.Fatalf("max read = %d", c.Files.MaxReadBytes)
	}
	// Defaults survive partial files.
	if c.Alert.Host.MemPercent.Value != 90 {
		t.Fatalf("mem threshold = %v", c.Alert.Host.MemPercent.Value)
	}
}

func TestFlagsOverrideFile(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "config.yaml")
	if err := os.WriteFile(path, []byte("listen: 127.0.0.1:1111\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	c, err := Load(path, []string{"-listen", "0.0.0.0:2222", "-log-level", "debug"})
	if err != nil {
		t.Fatal(err)
	}
	if c.Listen != "0.0.0.0:2222" {
		t.Fatalf("listen = %q", c.Listen)
	}
	if c.Log.Level != "debug" {
		t.Fatalf("log level = %q", c.Log.Level)
	}
}

func TestEnvOverrides(t *testing.T) {
	t.Setenv("QWE1_LISTEN", "10.0.0.1:9443")
	t.Setenv("QWE1_READ_ONLY", "1")
	t.Setenv("QWE1_LOG_LEVEL", "error")
	c, err := Load("", []string{})
	if err != nil {
		t.Fatal(err)
	}
	if c.Listen != "10.0.0.1:9443" {
		t.Fatalf("listen = %q", c.Listen)
	}
	if !c.ReadOnly {
		t.Fatal("read_only not set from env")
	}
	if c.Log.Level != "error" {
		t.Fatalf("log level = %q", c.Log.Level)
	}
}

func TestValidateErrors(t *testing.T) {
	cases := []struct {
		name string
		mut  func(*Config)
	}{
		{"listen empty", func(c *Config) { c.Listen = "" }},
		{"token ttl zero", func(c *Config) { c.Auth.TokenTTL = 0 }},
		{"token ttl too long", func(c *Config) { c.Auth.TokenTTL = 2 * time.Hour }},
		{"enrollment ttl zero", func(c *Config) { c.Auth.EnrollmentTTL = 0 }},
		{"max devices zero", func(c *Config) { c.Auth.MaxDevices = 0 }},
		{"max devices too big", func(c *Config) { c.Auth.MaxDevices = 100 }},
		{"brute force zero", func(c *Config) { c.Auth.BruteForce.MaxAttempts = 0 }},
		{"max read zero", func(c *Config) { c.Files.MaxReadBytes = 0 }},
		{"audit size zero", func(c *Config) { c.Audit.Size = 0 }},
		{"bad log level", func(c *Config) { c.Log.Level = "verbose" }},
		{"empty config dir", func(c *Config) { c.Config.Dir = "" }},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			c := Default()
			tc.mut(c)
			if err := c.Validate(); err == nil {
				t.Fatal("expected validation error")
			}
		})
	}
}

func TestKeyPaths(t *testing.T) {
	c := Default()
	c.Config.Dir = "/tmp/qwe1-test"
	signing, data, cert, key := c.KeyPaths()
	if signing != "/tmp/qwe1-test/signing.pem" {
		t.Fatalf("signing = %q", signing)
	}
	if data != "/tmp/qwe1-test/data.json" {
		t.Fatalf("data = %q", data)
	}
	if cert != "/tmp/qwe1-test/certs/server.crt" {
		t.Fatalf("cert = %q", cert)
	}
	if key != "/tmp/qwe1-test/certs/server.key" {
		t.Fatalf("key = %q", key)
	}
}
