package server

import (
	"context"
	"crypto/tls"
	"fmt"
	"log/slog"
	"net/http"
	"sync"
	"time"

	"path/filepath"

	"github.com/qwe1/qwe1/agent/internal/alerts"
	"github.com/qwe1/qwe1/agent/internal/audit"
	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/docker"
	"github.com/qwe1/qwe1/agent/config"
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
	dockerMu     sync.RWMutex
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
	slog.Info("server: initializing",
		"name", cfg.ServerName,
		"listenHost", cfg.ListenHost,
		"listenPort", cfg.ListenPort,
		"tlsCert", cfg.TLSCertPath,
		"tlsKey", cfg.TLSKeyPath,
	)

	authStore, err := auth.NewStore(filepath.Join(cfg.ServerName + ".auth.json"))
	if err != nil {
		return nil, fmt.Errorf("failed to create auth store: %w", err)
	}
	slog.Info("server: auth store loaded",
		"path", cfg.ServerName+".auth.json",
		"devices", authStore.DeviceCount(),
		"hasSignerSecret", authStore.SignerSecret() != "",
	)

	// The signer secret is persisted to disk on the first enroll or refresh
	// request, ensuring it survives process restarts after tokens are issued.

	// Use the persisted signer secret so tokens survive process restarts.
	signer, err := auth.NewSigner(authStore.SignerSecret())
	if err != nil {
		return nil, fmt.Errorf("failed to create token signer: %w", err)
	}

	// Guard against metricsInterval=0 which would panic time.NewTicker.
	metricsInterval := time.Duration(cfg.Host.MetricsInterval) * time.Second
	if metricsInterval <= 0 {
		metricsInterval = 5 * time.Second
	}

	hostCollector := host.NewCollector(metricsInterval)
	slog.Info("server: host metrics collector ready",
		"intervalSec", int(metricsInterval/time.Second),
	)

	var dockerClient *docker.Manager
	if cfg.Docker.Enabled {
		dockerClient, err = docker.New(cfg.Docker.SocketPath)
		if err != nil {
			slog.Warn("server: docker unavailable at startup",
				"socket", cfg.Docker.SocketPath,
				"error", err,
				"note", "agent will retry in background; capability will report true as soon as the daemon becomes reachable",
			)
		} else {
			slog.Info("server: docker ready",
				"socket", dockerClient.Socket(),
			)
		}
	} else {
		slog.Info("server: docker disabled by config")
	}

	terminalMgr := terminal.NewManager(cfg.Terminal.MaxSessions, time.Duration(cfg.Terminal.IdleTimeout)*time.Second, "/bin/sh")
	slog.Info("server: terminal manager ready",
		"maxSessions", cfg.Terminal.MaxSessions,
		"idleTimeoutSec", cfg.Terminal.IdleTimeout,
	)

	filesMgr, err := files.New(cfg.Files.AllowedRoots, false, 0, cfg.Files.MaxUpload)
	if err != nil {
		return nil, fmt.Errorf("failed to create files manager: %w", err)
	}
	slog.Info("server: files manager ready",
		"allowedRoots", cfg.Files.AllowedRoots,
		"maxUploadBytes", cfg.Files.MaxUpload,
	)

	alertsEngine := alerts.New(alerts.Rules{}, cfg.Alerts.BufferSize, nil)
	slog.Info("server: alerts engine ready",
		"enabled", cfg.Alerts.Enabled,
		"bufferSize", cfg.Alerts.BufferSize,
	)

	rateLimit := ratelimit.New(300.0/60.0, 10)
	wsHub := NewWSHub()
	auditLog := audit.New(1000)
	limiterToken := ratelimit.New(10.0/60.0, 20)
	limiterIP := ratelimit.New(60.0/60.0, 30)
	slog.Info("server: rate limiters ready",
		"globalPerMin", 300,
		"tokenPerMin", 10,
		"ipPerMin", 60,
	)

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

	return s.corsMiddleware(s.loggingMiddleware(s.recoveryMiddleware(s.ipRateLimit(s.readOnlyMiddleware(mux)))))
}

func (s *Server) Run(ctx context.Context) error {
	// Create TLS config
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	listenAddr := fmt.Sprintf("%s:%d", s.cfg.ListenHost, s.cfg.ListenPort)
	s.httpServer = &http.Server{
		Addr:         listenAddr,
		Handler:      s.routes(),
		TLSConfig:    tlsConfig,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	s.logCapabilities()

	// Start metrics collection
	go s.host.Run(ctx)
	slog.Info("server: started host metrics collector goroutine")

	// Start alerts evaluation via host metrics
	go func() {
		ticker := time.NewTicker(time.Duration(s.cfg.Host.MetricsInterval) * time.Second)
		if ticker == nil {
			return // metricsInterval <= 0; should never happen with guard in New
		}
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
	slog.Info("server: started alerts evaluation goroutine")

	// Start metrics broadcast
	go s.broadcastMetrics(ctx)
	slog.Info("server: started metrics broadcast goroutine")

	// Start WebSocket hub
	go s.wsHub.Run(ctx)
	slog.Info("server: started websocket hub goroutine")

	// Retry Docker in the background: the daemon is frequently still starting
	// when systemd launches the agent, so a fast-fail at construction should
	// not permanently disable the capability. Retries a few times, then gives up.
	if s.cfg.Docker.Enabled && !s.dockerAvailable() {
		go s.retryDocker(ctx)
	}

	slog.Info("server listening", "addr", listenAddr,
		"tls", s.cfg.TLSCertPath != "" && s.cfg.TLSKeyPath != "")

	// Start HTTP server
	errCh := make(chan error, 1)
	go func() {
		if s.cfg.TLSCertPath != "" && s.cfg.TLSKeyPath != "" {
			slog.Info("server: starting TLS listener")
			errCh <- s.httpServer.ListenAndServeTLS(s.cfg.TLSCertPath, s.cfg.TLSKeyPath)
		} else {
			slog.Info("server: starting plain HTTP listener")
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

// logCapabilities emits a concise summary of which subsystems are enabled, so
// an operator can confirm the agent is running with the intended feature set.
func (s *Server) logCapabilities() {
	dockerOK := s.dockerAvailable()
	slog.Info("server: capabilities",
		"docker", dockerOK,
		"dockerSocket", s.dockerSocketOrConfig(),
		"terminal", true,
		"files", true,
		"tempSensors", s.cfg.Host.TemperaturePath != "",
		"alerts", s.cfg.Alerts.Enabled,
	)
}

// dockerAvailable returns whether the Docker manager is currently usable.
func (s *Server) dockerAvailable() bool {
	s.dockerMu.RLock()
	defer s.dockerMu.RUnlock()
	return s.docker != nil && s.docker.Available()
}

// dockerManager returns the current Docker manager pointer under the read lock,
// or nil if Docker is unavailable. Callers must not retain the pointer beyond
// the scope of a single request, since the background retry may replace it.
func (s *Server) dockerManager() *docker.Manager {
	s.dockerMu.RLock()
	defer s.dockerMu.RUnlock()
	if s.docker == nil || !s.docker.Available() {
		return nil
	}
	return s.docker
}

// dockerSocketOrConfig exposes the resolved socket for diagnostics.
func (s *Server) dockerSocketOrConfig() string {
	s.dockerMu.RLock()
	defer s.dockerMu.RUnlock()
	if s.docker != nil {
		if s := s.docker.Socket(); s != "" {
			return s
		}
	}
	return s.cfg.Docker.SocketPath
}

// retryDocker attempts to (re)connect to the Docker daemon a few times in the
// background. Success or time expiry updates s.docker under lock.
func (s *Server) retryDocker(ctx context.Context) {
	const attempts = 6
	const wait = 5 * time.Second
	for i := 1; i <= attempts; i++ {
		select {
		case <-ctx.Done():
			return
		case <-time.After(wait):
		}
		slog.Info("server: retrying docker connection",
			"attempt", i,
			"maxAttempts", attempts,
			"socket", s.cfg.Docker.SocketPath,
		)
		m, err := docker.New(s.cfg.Docker.SocketPath)
		if err != nil {
			slog.Warn("server: docker retry failed",
				"attempt", i,
				"socket", s.cfg.Docker.SocketPath,
				"error", err,
			)
			continue
		}
		s.dockerMu.Lock()
		s.docker = m
		s.dockerMu.Unlock()
		slog.Info("server: docker connected after retry",
			"attempt", i,
			"socket", m.Socket(),
		)
		return
	}
	slog.Warn("server: giving up on docker after retries",
		"attempts", attempts,
		"socket", s.cfg.Docker.SocketPath,
	)
}
