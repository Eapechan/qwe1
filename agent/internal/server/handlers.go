package server

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"io"
	"log/slog"
	"net/http"
	"net/http/pprof"
	"strconv"
	"strings"
	"time"

	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/certs"
	"github.com/qwe1/qwe1/agent/internal/docker"
	"github.com/qwe1/qwe1/agent/internal/host"
)

func (s *Server) handleStatus(w http.ResponseWriter, r *http.Request) {
	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"name":         s.cfg.ServerName,
		"agentVersion": "1.0.0",
		"apiVersion":   1,
		"caps": map[string]bool{
			"docker":      s.docker != nil,
			"terminal":    true,
			"files":       true,
			"tempSensors": true,
		},
	})
}

func (s *Server) handleEnroll(w http.ResponseWriter, r *http.Request) {
	var req struct {
		EnrollmentToken string `json:"enrollmentToken"`
		Device          struct {
			Name     string `json:"name"`
			Platform string `json:"platform"`
		} `json:"device"`
	}

	if err := s.decodeJSON(r, &req); err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	if req.EnrollmentToken == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Enrollment token is required")
		return
	}

	// Reload the auth store from disk to pick up enrollment tokens
	// added by `qwe1-agent --enroll` while the server was running.
	if err := s.auth.Reload(); err != nil {
		slog.Warn("enroll: failed to reload auth store", "error", err)
	}

	hash := auth.HashToken(req.EnrollmentToken)
	enroll, ok := s.auth.EnrollByHash(hash)
	if !ok || time.Now().After(enroll.ExpiresAt) {
		s.respondError(w, http.StatusUnauthorized, "INVALID_ENROLLMENT", "Invalid or expired enrollment token")
		return
	}

	deviceID := generateID()
	now := time.Now().UTC()
	s.auth.AddDevice(deviceID, req.Device.Name, now)

	// Mark the enrollment token as used so it cannot be reused.
	s.auth.MarkEnrollmentUsed(hash)

	accessTokenTTL := time.Duration(s.cfg.Auth.AccessTokenTTL) * time.Second
	refreshTokenTTL := time.Duration(s.cfg.Auth.RefreshTokenTTL) * time.Second

	accessToken, err := s.signer.GenerateAccessToken(deviceID, accessTokenTTL)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "TOKEN_ERROR", "Failed to generate access token")
		return
	}

	refreshToken, err := auth.GenerateRefreshToken()
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "TOKEN_ERROR", "Failed to generate refresh token")
		return
	}

	s.auth.AddRefresh(auth.HashToken(refreshToken), deviceID, now.Add(refreshTokenTTL))
	if err := s.auth.Persist(); err != nil {
		s.respondError(w, http.StatusInternalServerError, "PERSIST_ERROR", "Failed to save auth state")
		return
	}

	fingerprint := ""
	cm := certs.NewCertManager(s.cfg.TLSCertPath, s.cfg.TLSKeyPath)
	if fp, err := cm.GetFingerprint(); err == nil {
		fingerprint = fp
	} else {
		slog.Warn("enroll: failed to get TLS fingerprint", "error", err)
	}

	s.respondJSON(w, http.StatusCreated, map[string]interface{}{
		"accessToken":       accessToken,
		"refreshToken":      refreshToken,
		"tokenType":         "Bearer",
		"expiresIn":         s.cfg.Auth.AccessTokenTTL,
		"refreshExpiresIn":  s.cfg.Auth.RefreshTokenTTL,
		"serverFingerprint": fingerprint,
	})
}

func (s *Server) handleRefresh(w http.ResponseWriter, r *http.Request) {
	var req struct {
		RefreshToken string `json:"refreshToken"`
	}

	if err := s.decodeJSON(r, &req); err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	if req.RefreshToken == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Refresh token is required")
		return
	}

	hash := auth.HashToken(req.RefreshToken)

	accessTokenTTL := time.Duration(s.cfg.Auth.AccessTokenTTL) * time.Second
	refreshTokenTTL := time.Duration(s.cfg.Auth.RefreshTokenTTL) * time.Second

	// Generate the new refresh token early (may fail without holding locks).
	newRefreshToken, err := auth.GenerateRefreshToken()
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "TOKEN_ERROR", "Failed to generate refresh token")
		return
	}

	// Atomic rotate: lookup + validate + mark old used + add new record +
	// touch device — all under a single lock. Returns deviceID directly.
	now := time.Now().UTC()
	deviceID, ok := s.auth.RotateRefreshAtomic(hash, auth.HashToken(newRefreshToken), now.Add(refreshTokenTTL))
	if !ok {
		// Reuse or expired — revoke the device to be safe.
		refresh, lookupOK := s.auth.RefreshByHash(hash)
		if lookupOK {
			s.auth.RevokeDevice(refresh.DeviceID)
		}
		_ = s.auth.Persist()
		s.respondError(w, http.StatusUnauthorized, "TOKEN_REUSE", "Refresh token reuse detected or expired, device revoked")
		return
	}

	accessToken, err := s.signer.GenerateAccessToken(deviceID, accessTokenTTL)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "TOKEN_ERROR", "Failed to generate access token")
		return
	}

	if err := s.auth.Persist(); err != nil {
		s.respondError(w, http.StatusInternalServerError, "PERSIST_ERROR", "Failed to save auth state")
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"accessToken":      accessToken,
		"refreshToken":     newRefreshToken,
		"tokenType":        "Bearer",
		"expiresIn":        s.cfg.Auth.AccessTokenTTL,
		"refreshExpiresIn": s.cfg.Auth.RefreshTokenTTL,
	})
}

func (s *Server) handleRevoke(w http.ResponseWriter, r *http.Request) {
	deviceID := r.Context().Value(ctxDeviceID)
	if deviceID == nil {
		s.respondError(w, http.StatusUnauthorized, "UNAUTHORIZED", "No device context")
		return
	}

	s.auth.RevokeDevice(deviceID.(string))
	if err := s.auth.Persist(); err != nil {
		s.respondError(w, http.StatusInternalServerError, "PERSIST_ERROR", "Failed to save auth state")
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleMe(w http.ResponseWriter, r *http.Request) {
	deviceID := r.Context().Value(ctxDeviceID)
	if deviceID == nil {
		s.respondError(w, http.StatusUnauthorized, "UNAUTHORIZED", "No device context")
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"deviceId":     deviceID,
		"serverName":   s.cfg.ServerName,
		"agentVersion": "1.0.0",
		"capabilities": map[string]bool{
			"docker":      s.docker != nil,
			"terminal":    true,
			"files":       true,
			"tempSensors": true,
		},
		"readOnly": s.readOnly,
	})
}

func generateID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return hex.EncodeToString(b)
}

// metricEnvelope wraps the raw host.Metrics in the {timestamp, host:{...}}
// envelope that the Flutter app's MetricsDto.fromJson expects.
func metricEnvelope(m *host.Metrics) map[string]interface{} {
	return map[string]interface{}{
		"timestamp": m.Timestamp,
		"host":      m,
	}
}

func (s *Server) handleMetricsLatest(w http.ResponseWriter, r *http.Request) {
	metrics := s.host.Latest()
	s.respondJSON(w, http.StatusOK, metricEnvelope(metrics))
}

func (s *Server) handleMetricsHistory(w http.ResponseWriter, r *http.Request) {
	// TODO: Get history from ring buffer

	s.respondJSON(w, http.StatusOK, []interface{}{})
}

func (s *Server) handleDockerContainers(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	containers, err := s.docker.ListContainers(r.Context(), false)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items":      containers,
		"nextCursor": nil,
		"total":      len(containers),
	})
}

func (s *Server) handleDockerStart(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	if err := s.docker.Start(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerStop(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	if err := s.docker.Stop(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerRestart(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	if err := s.docker.Restart(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerPause(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	if err := s.docker.Pause(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerUnpause(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	if err := s.docker.Unpause(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerKill(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	var req struct {
		Signal string `json:"signal"`
	}
	s.decodeJSON(r, &req)

	signal := req.Signal
	if signal == "" {
		signal = r.URL.Query().Get("signal")
	}

	if err := s.docker.KillSignal(r.Context(), id, signal); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerRemove(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	force := r.URL.Query().Get("force") == "true"

	if err := s.docker.Remove(r.Context(), id, force, false); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerInspect(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	info, err := s.docker.Inspect(r.Context(), id)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusOK, info)
}

func (s *Server) handleDockerLogs(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}
	id := r.PathValue("id")
	tail := 200
	if t := r.URL.Query().Get("tail"); t != "" {
		if parsed, err := strconv.Atoi(t); err == nil {
			tail = parsed
		}
	}
	if tail > 10000 {
		tail = 10000
	}

	var logs []docker.LogLine
	err := s.docker.StreamLogs(r.Context(), id, tail, false, func(line docker.LogLine) {
		logs = append(logs, line)
	})
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": logs,
	})
}

func (s *Server) handleDockerImages(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	images, err := s.docker.ListImages(r.Context())
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": images,
		"total": len(images),
	})
}

func (s *Server) handleDockerImageInspect(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	id := r.PathValue("id")
	info, err := s.docker.InspectImage(r.Context(), id)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, info)
}

func (s *Server) handleDockerImagePull(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	id := r.PathValue("id")
	if err := s.docker.PullImage(r.Context(), id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerImageDelete(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	id := r.PathValue("id")
	force := r.URL.Query().Get("force") == "true"

	if err := s.docker.DeleteImage(r.Context(), id, force); err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleDockerVolumes(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	volumes, err := s.docker.ListVolumes(r.Context())
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": volumes,
		"total": len(volumes),
	})
}

func (s *Server) handleDockerVolumeInspect(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	name := r.PathValue("name")
	info, err := s.docker.InspectVolume(r.Context(), name)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, info)
}

func (s *Server) handleDockerNetworks(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	networks, err := s.docker.ListNetworks(r.Context())
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": networks,
		"total": len(networks),
	})
}

func (s *Server) handleDockerNetworkInspect(w http.ResponseWriter, r *http.Request) {
	if s.docker == nil {
		s.respondError(w, http.StatusServiceUnavailable, "DOCKER_UNAVAILABLE", "Docker socket not reachable")
		return
	}

	id := r.PathValue("id")
	info, err := s.docker.InspectNetwork(r.Context(), id)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "DOCKER_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, info)
}

func (s *Server) handleTerminalCreate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Cols int `json:"cols"`
		Rows int `json:"rows"`
	}
	s.decodeJSON(r, &req)

	if req.Cols == 0 {
		req.Cols = 80
	}
	if req.Rows == 0 {
		req.Rows = 24
	}

	session, err := s.terminal.Create(req.Cols, req.Rows, "/bin/sh")
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "TERMINAL_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusCreated, map[string]interface{}{
		"sessionId": session.ID,
		"wsUrl":     "/ws?channels=terminal:" + session.ID,
	})
}

func (s *Server) handleTerminalDelete(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := s.terminal.Kill(id); err != nil {
		s.respondError(w, http.StatusInternalServerError, "TERMINAL_ERROR", err.Error())
		return
	}
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleFsList(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	// Empty path defaults to first root in Resolve(); do not convert to "/"

	items, err := s.files.List(path)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": items,
	})
}

func (s *Server) handleFsRead(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	if path == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Path is required")
		return
	}

	reader, _, err := s.files.Open(path)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}
	defer reader.Close()

	w.Header().Set("Content-Type", "application/octet-stream")
	io.Copy(w, reader)
}

func (s *Server) handleFsUpload(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_UPLOAD", err.Error())
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_UPLOAD", "missing file field")
		return
	}
	defer file.Close()

	destPath := r.FormValue("path")
	if destPath == "" {
		destPath = header.Filename
	}

	if err := s.files.Write(destPath, file); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusCreated, map[string]interface{}{
		"path": destPath,
		"name": header.Filename,
		"size": header.Size,
	})
}

func (s *Server) handleFsMkdir(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Path string `json:"path"`
	}
	s.decodeJSON(r, &req)

	if err := s.files.Mkdir(req.Path); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusCreated, nil)
}

func (s *Server) handleFsWrite(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Path    string `json:"path"`
		Content string `json:"content"`
	}

	if err := s.decodeJSON(r, &req); err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	if req.Path == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Path is required")
		return
	}

	if err := s.files.Write(req.Path, strings.NewReader(req.Content)); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"path": req.Path,
	})
}

func (s *Server) handleFsRename(w http.ResponseWriter, r *http.Request) {
	var req struct {
		From string `json:"from"`
		To   string `json:"to"`
	}
	s.decodeJSON(r, &req)

	if err := s.files.Rename(req.From, req.To); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleFsDelete(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	recursive := r.URL.Query().Get("recursive") == "true"

	if err := s.files.Delete(path, recursive); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleFsCopy(w http.ResponseWriter, r *http.Request) {
	var req struct {
		From string `json:"from"`
		To   string `json:"to"`
	}
	if err := s.decodeJSON(r, &req); err != nil {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	if req.From == "" || req.To == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "From and To are required")
		return
	}

	if err := s.files.Copy(req.From, req.To); err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusCreated, nil)
}

func (s *Server) handleFsSearch(w http.ResponseWriter, r *http.Request) {
	pattern := r.URL.Query().Get("q")
	if pattern == "" {
		s.respondError(w, http.StatusBadRequest, "INVALID_REQUEST", "Search query is required")
		return
	}

	results, err := s.files.Search(pattern)
	if err != nil {
		s.respondError(w, http.StatusInternalServerError, "FS_ERROR", err.Error())
		return
	}

	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": results,
		"total": len(results),
	})
}

func (s *Server) handlePprof(w http.ResponseWriter, r *http.Request) {
	pprof.Index(w, r)
}

func (s *Server) handlePprofProfile(w http.ResponseWriter, r *http.Request) {
	pprof.Profile(w, r)
}

func (s *Server) handleAlerts(w http.ResponseWriter, r *http.Request) {
	severity := r.URL.Query().Get("severity")
	alertList := s.alerts.List(severity, 100)
	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": alertList,
	})
}

func (s *Server) handleAlertAck(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	s.alerts.Ack(id)
	s.respondJSON(w, http.StatusNoContent, nil)
}

func (s *Server) handleAlertThresholds(w http.ResponseWriter, r *http.Request) {
	// TODO: Get thresholds
	s.respondJSON(w, http.StatusOK, map[string]interface{}{})
}

func (s *Server) handleAlertThresholdsUpdate(w http.ResponseWriter, r *http.Request) {
	// TODO: Update thresholds
	s.respondJSON(w, http.StatusOK, nil)
}

func (s *Server) handleAudit(w http.ResponseWriter, r *http.Request) {
	// TODO: Get audit log
	s.respondJSON(w, http.StatusOK, map[string]interface{}{
		"items": []interface{}{},
	})
}

func (s *Server) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	s.wsHub.HandleWebSocket(w, r)
}

func (s *Server) broadcastMetrics(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			metrics := s.host.Latest()
			s.wsHub.Broadcast("metrics", metricEnvelope(metrics))
		}
	}
}
