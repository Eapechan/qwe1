package server

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/qwe1/qwe1/agent/internal/audit"
	"github.com/qwe1/qwe1/agent/internal/auth"
)

type contextKey string

const ctxDeviceID contextKey = "deviceID"

func writeErr(w http.ResponseWriter, r *http.Request, status int, code, msg string, extra map[string]any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	resp := map[string]any{
		"error": map[string]any{
			"code":    code,
			"message": msg,
		},
	}
	for k, v := range extra {
		resp[k] = v
	}
	json.NewEncoder(w).Encode(resp)
}

func withValue(ctx context.Context, key contextKey, v any) context.Context {
	return context.WithValue(ctx, key, v)
}

// randID returns a short random hex string for request/audit IDs.
func randID() string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func clientIP(r *http.Request) string {
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		for i := 0; i < len(xff); i++ {
			if xff[i] == ',' {
				return xff[:i]
			}
		}
		return xff
	}
	if host, _, err := net.SplitHostPort(r.RemoteAddr); err == nil {
		return host
	}
	return r.RemoteAddr
}

// authMiddleware validates the Bearer access token on protected routes.
func (s *Server) authMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		raw := bearerToken(r)
		if raw == "" {
			writeErr(w, r, http.StatusUnauthorized, "UNAUTHORIZED", "missing bearer token", nil)
			return
		}
		if !s.limiterToken.Take(raw, 1) {
			w.Header().Set("Retry-After", "60")
			writeErr(w, r, http.StatusTooManyRequests, "RATE_LIMITED", "too many requests", nil)
			return
		}
		deviceID, err := s.signer.ValidateAccessToken(raw)
		if err != nil {
			code := "INVALID_TOKEN"
			if err == auth.ErrTokenExpired {
				code = "TOKEN_EXPIRED"
			}
			writeErr(w, r, http.StatusUnauthorized, code, "authentication failed", nil)
			return
		}
		next.ServeHTTP(w, r.WithContext(withValue(r.Context(), ctxDeviceID, deviceID)))
	}
}

// ipRateLimit applies the per-IP limiter to all public routes.
func (s *Server) ipRateLimit(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !s.limiterIP.Allow(clientIP(r)) {
			w.Header().Set("Retry-After", "10")
			writeErr(w, r, http.StatusTooManyRequests, "RATE_LIMITED", "too many requests", nil)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// readOnlyMiddleware rejects mutating routes when the agent runs read-only.
// This is the authoritative enforcement point (docs/14 §8).
func (s *Server) readOnlyMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if s.readOnly {
			writeErr(w, r, http.StatusForbidden, "READ_ONLY", "action denied in read-only mode", map[string]any{"action": r.Method + " " + r.URL.Path})
			return
		}
		next.ServeHTTP(w, r)
	})
}

// audit records a privileged action after the handler runs.
func (s *Server) audit(deviceID, action, target string, err error, r *http.Request) {
	result := "ok"
	if err != nil {
		result = "error"
	}
	s.auditLog.Record(audit.Entry{
		TS:     time.Now().UTC(),
		Actor:  deviceID,
		Action: action,
		Target: target,
		Result: result,
		IP:     clientIP(r),
	})
}

func bearerToken(r *http.Request) string {
	h := r.Header.Get("Authorization")
	if len(h) > 7 && strings.EqualFold(h[:7], "Bearer ") {
		return h[7:]
	}
	return ""
}

