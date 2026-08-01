package main

import (
	"context"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/qwe1/qwe1/agent/internal/config"
	"github.com/qwe1/qwe1/agent/internal/server"
)

func main() {
	var (
		configPath string
		enroll     bool
	)

	flag.StringVar(&configPath, "config", "config.yaml", "Path to configuration file")
	flag.BoolVar(&enroll, "enroll", false, "Generate enrollment token and QR code")
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
		runEnroll(cfg)
		return
	}

	runServer(cfg)
}

func runEnroll(cfg *config.Config) {
	token, fingerprint, err := generateEnrollmentToken(cfg)
	if err != nil {
		slog.Error("failed to generate enrollment token", "error", err)
		os.Exit(1)
	}

	fmt.Println("\n=== qwe1 Agent Enrollment ===")
	fmt.Printf("Server: %s\n", cfg.ServerName)
	fmt.Printf("Token: %s\n", token)
	fmt.Printf("Fingerprint: %s\n", fingerprint)
	fmt.Println("\nScan the QR code below with the qwe1 app:")
	fmt.Println()

	// Generate QR code
	qrPath := "/tmp/qwe1-enroll-qr.png"
	if err := generateQRCode(token, qrPath); err != nil {
		slog.Error("failed to generate QR code", "error", err)
	} else {
		fmt.Printf("QR code saved to: %s\n", qrPath)
	}

	fmt.Println("\nOr manually enter the token in the app.")
	fmt.Println("=============================\n")
}

func runServer(cfg *config.Config) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle shutdown signals
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

func generateEnrollmentToken(cfg *config.Config) (string, string, error) {
	// TODO: Implement token generation
	return "qwe1-example-token-1234567890", "aa:bb:cc:dd:ee:ff", nil
}

func generateQRCode(token, path string) error {
	// TODO: Implement QR code generation
	return nil
}
