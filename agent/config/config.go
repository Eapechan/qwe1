package config

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Config struct {
	ServerName  string `yaml:"serverName"`
	ListenHost  string `yaml:"listenHost"`
	ListenPort            int    `yaml:"listenPort"`
	AdvertiseURL          string `yaml:"advertiseUrl"`
	AdvertiseTailscaleURL string `yaml:"advertiseTailscaleUrl"`
	TLSCertPath           string `yaml:"tlsCertPath"`
	TLSKeyPath  string `yaml:"tlsKeyPath"`

	Auth     AuthConfig     `yaml:"auth"`
	Docker   DockerConfig   `yaml:"docker"`
	Host     HostConfig     `yaml:"host"`
	Terminal TerminalConfig `yaml:"terminal"`
	Files    FilesConfig    `yaml:"files"`
	Alerts   AlertsConfig   `yaml:"alerts"`
}

type AuthConfig struct {
	TokenLength     int `yaml:"tokenLength"`
	AccessTokenTTL  int `yaml:"accessTokenTTL"`
	RefreshTokenTTL int `yaml:"refreshTokenTTL"`
	MaxAttempts     int `yaml:"maxAttempts"`
	LockoutDuration int `yaml:"lockoutDuration"`
	EnrollmentTTL   int `yaml:"enrollmentTTL"`
}

type DockerConfig struct {
	SocketPath string `yaml:"socketPath"`
	Enabled    bool   `yaml:"enabled"`
}

type HostConfig struct {
	MetricsInterval int    `yaml:"metricsInterval"`
	TemperaturePath string `yaml:"temperaturePath"`
}

type TerminalConfig struct {
	MaxSessions int `yaml:"maxSessions"`
	IdleTimeout int `yaml:"idleTimeout"`
}

type FilesConfig struct {
	AllowedRoots []string `yaml:"allowedRoots"`
	MaxUpload    int64    `yaml:"maxUpload"`
}

type AlertsConfig struct {
	Enabled    bool   `yaml:"enabled"`
	BufferSize int    `yaml:"bufferSize"`
	WebhookURL string `yaml:"webhookUrl"`
	NtfyTopic  string `yaml:"ntfyTopic"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return defaultConfig(), nil
		}
		return nil, err
	}

	cfg := defaultConfig()
	if err := yaml.Unmarshal(data, cfg); err != nil {
		return nil, err
	}

	return cfg, nil
}

// Default returns a copy of the built-in default configuration.
func Default() *Config {
	return defaultConfig()
}

func defaultConfig() *Config {
	return &Config{
		ServerName:  "qwe1-agent",
		ListenHost:  "0.0.0.0",
		ListenPort:  9443,
		TLSCertPath: "/etc/qwe1/certs/cert.pem",
		TLSKeyPath:  "/etc/qwe1/certs/key.pem",
		Auth: AuthConfig{
			TokenLength:     16,
			AccessTokenTTL:  900,
			RefreshTokenTTL: 2592000,
			MaxAttempts:     5,
			LockoutDuration: 1800,
			EnrollmentTTL:   3600,
		},
		Docker: DockerConfig{
			SocketPath: "/var/run/docker.sock",
			Enabled:    true,
		},
		Host: HostConfig{
			MetricsInterval: 5,
			TemperaturePath: "/sys/class/thermal",
		},
		Terminal: TerminalConfig{
			MaxSessions: 4,
			IdleTimeout: 300,
		},
		Files: FilesConfig{
			AllowedRoots: []string{"/home", "/var/log"},
			MaxUpload:    524288000,
		},
		Alerts: AlertsConfig{
			Enabled:    true,
			BufferSize: 1000,
		},
	}
}
