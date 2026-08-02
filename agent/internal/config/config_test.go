package config

import (
	"os"
	"path/filepath"
	"testing"
)

func TestDefaults(t *testing.T) {
	c := Default()
	if c.ServerName != "qwe1-agent" {
		t.Fatalf("serverName = %q, want qwe1-agent", c.ServerName)
	}
	if c.ListenHost != "0.0.0.0" {
		t.Fatalf("listenHost = %q, want 0.0.0.0", c.ListenHost)
	}
	if c.ListenPort != 9443 {
		t.Fatalf("listenPort = %d, want 9443", c.ListenPort)
	}
	if c.Auth.AccessTokenTTL != 900 {
		t.Fatalf("accessTokenTTL = %d, want 900", c.Auth.AccessTokenTTL)
	}
	if c.Auth.RefreshTokenTTL != 2592000 {
		t.Fatalf("refreshTokenTTL = %d, want 2592000", c.Auth.RefreshTokenTTL)
	}
	if !c.Docker.Enabled {
		t.Fatal("docker should be enabled by default")
	}
	if c.Files.MaxUpload != 524288000 {
		t.Fatalf("maxUpload = %d, want 524288000", c.Files.MaxUpload)
	}
}

func TestLoadMissingFileReturnsDefaults(t *testing.T) {
	c, err := Load(filepath.Join(t.TempDir(), "does-not-exist.yaml"))
	if err != nil {
		t.Fatal(err)
	}
	if c.ListenPort != 9443 || c.ServerName != "qwe1-agent" {
		t.Fatalf("expected defaults, got %+v", c)
	}
}

func TestLoadFromFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	content := `
serverName: my-server
listenHost: "127.0.0.1"
listenPort: 9999
auth:
  accessTokenTTL: 120
  refreshTokenTTL: 604800
files:
  maxUpload: 1048576
`
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	c, err := Load(path)
	if err != nil {
		t.Fatal(err)
	}
	if c.ServerName != "my-server" {
		t.Fatalf("serverName = %q", c.ServerName)
	}
	if c.ListenHost != "127.0.0.1" {
		t.Fatalf("listenHost = %q", c.ListenHost)
	}
	if c.ListenPort != 9999 {
		t.Fatalf("listenPort = %d", c.ListenPort)
	}
	if c.Auth.AccessTokenTTL != 120 {
		t.Fatalf("accessTokenTTL = %d", c.Auth.AccessTokenTTL)
	}
	if c.Auth.RefreshTokenTTL != 604800 {
		t.Fatalf("refreshTokenTTL = %d", c.Auth.RefreshTokenTTL)
	}
	if c.Files.MaxUpload != 1048576 {
		t.Fatalf("maxUpload = %d", c.Files.MaxUpload)
	}
	// Unspecified fields fall back to defaults.
	if !c.Alerts.Enabled {
		t.Fatal("alerts should default to enabled")
	}
}

func TestLoadInvalidYAML(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.yaml")
	// listenPort expects int; string will fail unmarshal
	if err := os.WriteFile(path, []byte("listenPort: notanumber\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := Load(path); err == nil {
		t.Fatal("expected error for invalid YAML")
	}
}

func TestDefaultIsIsolated(t *testing.T) {
	base := Default()
	base.ServerName = "mutated"
	if conn := Default().ServerName; conn != "qwe1-agent" {
		t.Fatalf("Default() not isolated, got %q", conn)
	}
}
