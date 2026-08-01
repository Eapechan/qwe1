package main

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/certs"
	"github.com/qwe1/qwe1/agent/internal/config"
	"github.com/qwe1/qwe1/agent/internal/server"
)

func main() {
	var (
		configPath string
		enroll     bool
		enrollDays int
	)

	flag.StringVar(&configPath, "config", "config.yaml", "Path to configuration file")
	flag.BoolVar(&enroll, "enroll", false, "Generate enrollment token and QR code")
	flag.IntVar(&enrollDays, "enroll-days", 365, "Enrollment token expiry in days")
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
		runEnroll(cfg, enrollDays)
		return
	}

	runServer(cfg)
}

func runEnroll(cfg *config.Config, days int) {
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
	expiresAt := time.Now().UTC().Add(time.Duration(days) * 24 * time.Hour)
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

	fmt.Println()
	fmt.Println("=========================================")
	fmt.Println("  qwe1 Agent Enrollment Token")
	fmt.Println("=========================================")
	fmt.Printf("  Server:          %s\n", cfg.ServerName)
	fmt.Printf("  Enrollment Token: %s\n", rawToken)
	fmt.Printf("  Expires:         %s (%d days)\n", expiresAt.Format("2006-01-02"), days)
	if fingerprint != "" {
		fmt.Printf("  Fingerprint:     %s\n", fingerprint)
	}
	fmt.Println("=========================================")
	fmt.Println()
	fmt.Println("Enter this token in the qwe1 app to pair")
	fmt.Println("with this server.")
	fmt.Println()

	_ = base64.RawURLEncoding // ensure import is used
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
	return base64.RawURLEncoding.EncodeToString(b), nil
}
