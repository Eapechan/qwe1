package main

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"flag"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/certs"
	"github.com/qwe1/qwe1/agent/internal/server"
	"github.com/qwe1/qwe1/agent/config"
	qrcode "github.com/skip2/go-qrcode"
)

func main() {
	var (
		configPath  string
		enroll      bool
		enrollHours int
	)

	flag.StringVar(&configPath, "config", "config.yaml", "Path to configuration file")
	flag.BoolVar(&enroll, "enroll", false, "Generate enrollment token and QR code")
	flag.IntVar(&enrollHours, "enroll-hours", 0, "Enrollment token expiry in hours (default from config)")
	flag.Parse()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	cfg, err := config.Load(configPath)
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	if enroll {
		if enrollHours == 0 {
			enrollHours = cfg.Auth.EnrollmentTTL / 3600
			if enrollHours == 0 {
				enrollHours = 8760
			}
		}
		runEnroll(cfg, enrollHours)
		return
	}

	runServer(cfg)
}

func runEnroll(cfg *config.Config, hours int) {
	storePath := filepath.Join(cfg.ServerName + ".auth.json")
	store, err := auth.NewStore(storePath)
	if err != nil {
		slog.Error("failed to open auth store", "error", err)
		os.Exit(1)
	}

	rawToken, err := generateToken(32)
	if err != nil {
		slog.Error("failed to generate token", "error", err)
		os.Exit(1)
	}

	hash := auth.HashToken(rawToken)
	expiresAt := time.Now().UTC().Add(time.Duration(hours) * time.Hour)
	store.AddEnrollment(hash, expiresAt)
	if err := store.Persist(); err != nil {
		slog.Error("failed to persist auth store", "error", err)
		os.Exit(1)
	}

	fingerprint := ""
	if cfg.TLSCertPath != "" {
		cm := certs.NewCertManager(cfg.TLSCertPath, cfg.TLSKeyPath)
		if cm.EnsureCerts() == nil {
			if fp, err := cm.GetFingerprint(); err == nil {
				fingerprint = fp
			}
		}
	}

	lanURL := cfg.AdvertiseURL
	if lanURL == "" {
		lanURL = detectLanIP(cfg)
	}
	tailscaleURL := cfg.AdvertiseTailscaleURL
	if tailscaleURL == "" {
		tailscaleURL = detectTailscaleIP(cfg)
	}

	qrPayload := fmt.Sprintf("qwe1://enroll?agentUrl=%s&tsUrl=%s&name=%s&token=%s&fp=%s",
		lanURL, tailscaleURL, cfg.ServerName, rawToken, fingerprint)

	qrFile := "enroll-qr.png"
	if err := qrcode.WriteFile(qrPayload, qrcode.Medium, 512, qrFile); err != nil {
		slog.Warn("failed to generate QR code file", "error", err)
	} else {
		qr, err := qrcode.New(qrPayload, qrcode.Medium)
		if err == nil {
			fmt.Println(qr.ToSmallString(false))
		}
		fmt.Printf("\nQR code saved to %s\n", qrFile)
	}

	fmt.Println()
	fmt.Println("=========================================")
	fmt.Println("  qwe1 Agent Enrollment Token")
	fmt.Println("=========================================")
	fmt.Printf("  Server:          %s\n", cfg.ServerName)
	fmt.Printf("  Enrollment Token: %s\n", rawToken)
	fmt.Printf("  Expires:         %s (%d hours)\n", expiresAt.Format("2006-01-02T15:04:05Z"), hours)
	if fingerprint != "" {
		fmt.Printf("  Fingerprint:     %s\n", fingerprint)
	}
	if lanURL != "" {
		fmt.Printf("  LAN URL:         %s\n", lanURL)
	}
	if tailscaleURL != "" {
		fmt.Printf("  Tailscale URL:   %s\n", tailscaleURL)
	}
	fmt.Println("=========================================")
	fmt.Println()
	fmt.Println("Enter this token in the qwe1 app to pair")
	fmt.Println("with this server, or scan the QR code.")
	fmt.Println()
}

func detectLanIP(cfg *config.Config) string {
	scheme := "http"
	if cfg.TLSCertPath != "" {
		scheme = "https"
	}
	port := fmt.Sprintf(":%d", cfg.ListenPort)

	ifaces, err := net.Interfaces()
	if err != nil {
		return ""
	}
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
			continue
		}
		if strings.Contains(iface.Name, "tailscale") {
			continue
		}
		addrs, err := iface.Addrs()
		if err != nil {
			continue
		}
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			if ip == nil || ip.IsLoopback() {
				continue
			}
			if ip.To4() != nil {
				return scheme + "://" + ip.String() + port
			}
		}
	}
	return ""
}

func detectTailscaleIP(cfg *config.Config) string {
	scheme := "http"
	if cfg.TLSCertPath != "" {
		scheme = "https"
	}
	port := fmt.Sprintf(":%d", cfg.ListenPort)

	ifaces, err := net.Interfaces()
	if err != nil {
		return ""
	}
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp == 0 {
			continue
		}
		if !strings.Contains(iface.Name, "tailscale") {
			continue
		}
		addrs, err := iface.Addrs()
		if err != nil {
			continue
		}
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			if ip == nil {
				continue
			}
			if ip.To4() != nil {
				return scheme + "://" + ip.String() + port
			}
		}
	}
	// Fallback: scan all interfaces for 100.64.0.0/10
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp == 0 {
			continue
		}
		addrs, err := iface.Addrs()
		if err != nil {
			continue
		}
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			if ip == nil || ip.To4() == nil {
				continue
			}
			if ip4 := ip.To4(); ip4 != nil && ip4[0] == 100 && (ip4[1]&0xc0) == 64 {
				return scheme + "://" + ip.String() + port
			}
		}
	}
	return ""
}

func runServer(cfg *config.Config) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		sig := <-sigCh
		slog.Info("received shutdown signal", "signal", sig)
		cancel()
	}()

	srv, err := server.New(cfg)
	if err != nil {
		slog.Error("failed to create server", "error", err)
		os.Exit(1)
	}

	slog.Info("starting qwe1 agent",
		"name", cfg.ServerName,
		"host", cfg.ListenHost,
		"port", cfg.ListenPort,
	)

	if err := srv.Run(ctx); err != nil {
		slog.Error("server error", "error", err)
		os.Exit(1)
	}

	slog.Info("agent stopped")
}

func generateToken(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return "qwe1-" + base64.RawURLEncoding.EncodeToString(b), nil
}
