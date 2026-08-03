package server

import (
	"context"
	"crypto/tls"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"path/filepath"

	"github.com/qwe1/qwe1/agent/internal/alerts"
	"github.com/qwe1/qwe1/agent/internal/audit"
	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/config"
	"github.com/qwe1/qwe1/agent/internal/docker"
	"github.com/qwe1/qwe1/agent/internal/files"
	"github.com/qwe1/qwe1/agent/internal/host"
	"github.com/qwe1/qwe1/agent/internal/ratelimit"
	"github.com/qwe1/qwe1/agent/internal/terminal"
)

type Server struct {
	cfg          *config.Config
	httpServer   *http.Server
	auth         *auth.Store
	signer       *auth.Signer
	host         *host.Collector
	docker       *docker.Manager
	terminal     *terminal.Manager
	files        *files.Manager
	alerts       *alerts.Engine
	rateLimit    *ratelimit.Limiter
	limiterToken *ratelimit.Limiter
	limiterIP    *ratelimit.Limiter
	auditLog     *audit.Log
	readOnly     bool
	wsHub        *WSHub
}

func New(cfg *config.Config) (*Server, error) {
	authStore, err := auth.NewStore(filepath.Join(cfg.ServerName + ".auth.json"))
	if err != nil {
		return nil, fmt.Errorf("failed to create auth store: %w", err)
	}

	signer, err := auth.NewSigner("")
	if err != nil {
		return nil, fmt.Errorf("failed to create token signer: %w", err)
	}

	hostCollector := host.NewCollector(time.Duration(cfg.Host.MetricsInterval) * time.Second)

	var dockerClient *docker.Manager
	if cfg.Docker.Enabled {
		dockerClient, err = docker.New()
		if err != nil {
			slog.Warn("failed to connect to docker", "error", err)
		}
	}

	terminalMgr := terminal.NewManager(cfg.Terminal.MaxSessions, time.Duration(cfg.Terminal.IdleTimeout)*time.Second, "/bin/sh")
	filesMgr, err := files.New(cfg.Files.AllowedRoots, false, 0, cfg.Files.MaxUpload)
	if err != nil {
		return nil, fmt.Errorf("failed to create files manager: %w", err)
	}
	alertsEngine := alerts.New(alerts.Rules{}, cfg.Alerts.BufferSize, nil)
	rateLimit := ratelimit.New(300.0/60.0, 10)
	wsHub := NewWSHub()
	auditLog := audit.New(1000)
	limiterToken := ratelimit.New(10.0/60.0, 20)
	limiterIP := ratelimit.New(60.0/60.0, 30)

	return &Server{
		cfg:          cfg,
		auth:         authStore,
		signer:       signer,
		host:         hostCollector,
		docker:       dockerClient,
		terminal:     terminalMgr,
		files:        filesMgr,
		alerts:       alertsEngine,
		rateLimit:    rateLimit,
		limiterToken: limiterToken,
		limiterIP:    limiterIP,
		auditLog:     auditLog,
		wsHub:        wsHub,
	}, nil
}

// routes builds the HTTP handler for the agent. It is extracted from Run so it
// can be exercised directly by httptest.
func (s *Server) routes() http.Handler {
	mux := http.NewServeMux()

	// Public routes
	mux.HandleFunc("GET /status", s.handleStatus)

	// Auth routes
	mux.HandleFunc("POST /auth/enroll", s.handleEnroll)
	mux.HandleFunc("POST /auth/refresh", s.handleRefresh)
	mux.HandleFunc("POST /auth/revoke", s.authMiddleware(s.handleRevoke))
	mux.HandleFunc("GET /auth/me", s.authMiddleware(s.handleMe))

	// Protected routes
	mux.HandleFunc("GET /metrics/latest", s.authMiddleware(s.handleMetricsLatest))
	mux.HandleFunc("GET /metrics/history", s.authMiddleware(s.handleMetricsHistory))

	// Docker routes
	mux.HandleFunc("GET /docker/containers", s.authMiddleware(s.handleDockerContainers))
	mux.HandleFunc("POST /docker/containers/{id}/start", s.authMiddleware(s.handleDockerStart))
	mux.HandleFunc("POST /docker/containers/{id}/stop", s.authMiddleware(s.handleDockerStop))
	mux.HandleFunc("POST /docker/containers/{id}/restart", s.authMiddleware(s.handleDockerRestart))
	mux.HandleFunc("POST /docker/containers/{id}/pause", s.authMiddleware(s.handleDockerPause))
	mux.HandleFunc("POST /docker/containers/{id}/unpause", s.authMiddleware(s.handleDockerUnpause))
	mux.HandleFunc("POST /docker/containers/{id}/kill", s.authMiddleware(s.handleDockerKill))
	mux.HandleFunc("DELETE /docker/containers/{id}", s.authMiddleware(s.handleDockerRemove))
	mux.HandleFunc("GET /docker/containers/{id}/inspect", s.authMiddleware(s.handleDockerInspect))
	mux.HandleFunc("GET /docker/containers/{id}/logs", s.authMiddleware(s.handleDockerLogs))

	// Docker images
	mux.HandleFunc("GET /docker/images", s.authMiddleware(s.handleDockerImages))
	mux.HandleFunc("GET /docker/images/{id}/inspect", s.authMiddleware(s.handleDockerImageInspect))
	mux.HandleFunc("POST /docker/images/{id}/pull", s.authMiddleware(s.handleDockerImagePull))
	mux.HandleFunc("DELETE /docker/images/{id}", s.authMiddleware(s.handleDockerImageDelete))

	// Docker volumes
	mux.HandleFunc("GET /docker/volumes", s.authMiddleware(s.handleDockerVolumes))
	mux.HandleFunc("GET /docker/volumes/{name}/inspect", s.authMiddleware(s.handleDockerVolumeInspect))

	// Docker networks
	mux.HandleFunc("GET /docker/networks", s.authMiddleware(s.handleDockerNetworks))
	mux.HandleFunc("GET /docker/networks/{id}/inspect", s.authMiddleware(s.handleDockerNetworkInspect))

	// Terminal routes
	mux.HandleFunc("POST /terminal", s.authMiddleware(s.handleTerminalCreate))
	mux.HandleFunc("DELETE /terminal/{id}", s.authMiddleware(s.handleTerminalDelete))

	// File routes
	mux.HandleFunc("GET /fs/list", s.authMiddleware(s.handleFsList))
	mux.HandleFunc("GET /fs/read", s.authMiddleware(s.handleFsRead))
	mux.HandleFunc("POST /fs/upload", s.authMiddleware(s.handleFsUpload))
	mux.HandleFunc("POST /fs/mkdir", s.authMiddleware(s.handleFsMkdir))
	mux.HandleFunc("POST /fs/write", s.authMiddleware(s.handleFsWrite))
	mux.HandleFunc("PATCH /fs/rename", s.authMiddleware(s.handleFsRename))
	mux.HandleFunc("DELETE /fs", s.authMiddleware(s.handleFsDelete))
	mux.HandleFunc("POST /fs/copy", s.authMiddleware(s.handleFsCopy))
	mux.HandleFunc("GET /fs/search", s.authMiddleware(s.handleFsSearch))

	// Alert routes
	mux.HandleFunc("GET /alerts", s.authMiddleware(s.handleAlerts))
	mux.HandleFunc("PUT /alerts/{id}/ack", s.authMiddleware(s.handleAlertAck))
	mux.HandleFunc("GET /alerts/thresholds", s.authMiddleware(s.handleAlertThresholds))
	mux.HandleFunc("PUT /alerts/thresholds", s.authMiddleware(s.handleAlertThresholdsUpdate))

	// WebSocket
	mux.HandleFunc("GET /ws", s.authMiddleware(s.handleWebSocket))

	// Audit
	mux.HandleFunc("GET /audit", s.authMiddleware(s.handleAudit))

	// Profiling (debug only)
	mux.HandleFunc("GET /debug/pprof/", s.authMiddleware(s.handlePprof))
	mux.HandleFunc("GET /debug/pprof/profile", s.authMiddleware(s.handlePprofProfile))

	return s.corsMiddleware(s.loggingMiddleware(s.recoveryMiddleware(mux)))
}

func (s *Server) Run(ctx context.Context) error {
	// Create TLS config
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	s.httpServer = &http.Server{
		Addr:         fmt.Sprintf("%s:%d", s.cfg.ListenHost, s.cfg.ListenPort),
		Handler:      s.routes(),
		TLSConfig:    tlsConfig,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Start metrics collection
	go s.host.Run(ctx)

	// Start alerts evaluation via host metrics
	go func() {
		ticker := time.NewTicker(time.Duration(s.cfg.Host.MetricsInterval) * time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				metrics := s.host.Latest()
				if metrics != nil {
					s.alerts.EvaluateHost(metrics)
				}
			}
		}
	}()

	// Start metrics broadcast
	go s.broadcastMetrics(ctx)

	// Start WebSocket hub
	go s.wsHub.Run(ctx)

	slog.Info("server listening", "addr", s.httpServer.Addr)

	// Start HTTP server
	errCh := make(chan error, 1)
	go func() {
		if s.cfg.TLSCertPath != "" && s.cfg.TLSKeyPath != "" {
			errCh <- s.httpServer.ListenAndServeTLS(s.cfg.TLSCertPath, s.cfg.TLSKeyPath)
		} else {
			errCh <- s.httpServer.ListenAndServe()
		}
	}()

	// Wait for shutdown
	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		slog.Info("shutting down server")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return s.httpServer.Shutdown(shutdownCtx)
	}
}
