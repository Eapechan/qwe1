package server

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/internal/config"
)

func newTestServer(t *testing.T, readOnly bool) (*Server, *config.Config) {
	t.Helper()
	cfg := config.Default()
	cfg.Config.Dir = t.TempDir()
	cfg.Docker.Enabled = false
	cfg.TLS.Cert = ""
	cfg.TLS.Key = ""

	root := t.TempDir()
	cfg.Files.Roots = []string{root}
	cfg.ReadOnly = readOnly

	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	s, err := New(cfg, logger)
	if err != nil {
		t.Fatal(err)
	}
	return s, cfg
}

func doReq(t *testing.T, h http.Handler, method, path string, body any, token string) *httptest.ResponseRecorder {
	t.Helper()
	var rdr io.Reader
	if s, ok := body.(string); ok {
		rdr = strings.NewReader(s)
	} else if body != nil {
		b, _ := json.Marshal(body)
		rdr = bytes.NewReader(b)
	}
	req := httptest.NewRequest(method, path, rdr)
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func decode[T any](t *testing.T, rec *httptest.ResponseRecorder) T {
	t.Helper()
	var v T
	if err := json.Unmarshal(rec.Body.Bytes(), &v); err != nil {
		t.Fatalf("decode: %v (body %s)", err, rec.Body.String())
	}
	return v
}

func enroll(t *testing.T, s *Server, h http.Handler) (access, refresh string) {
	t.Helper()
	tok, err := s.authSvc.GenerateEnrollment()
	if err != nil {
		t.Fatal(err)
	}
	rec := doReq(t, h, http.MethodPost, "/auth/enroll", map[string]any{
		"enrollmentToken": tok,
		"device":          map[string]any{"name": "test", "platform": "ios"},
	}, "")
	if rec.Code != http.StatusCreated {
		t.Fatalf("enroll status = %d body = %s", rec.Code, rec.Body.String())
	}
	resp := decode[tokenResponse](t, rec)
	return resp.AccessToken, resp.RefreshToken
}

func TestHealthzAndStatus(t *testing.T) {
	s, _ := newTestServer(t, false)
	h := s.routes()
	if rec := doReq(t, h, "GET", "/healthz", nil, ""); rec.Code != http.StatusOK {
		t.Fatalf("healthz = %d", rec.Code)
	}
	rec := doReq(t, h, "GET", "/status", nil, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d", rec.Code)
	}
	var status struct {
		Name       string `json:"name"`
		APIVersion int    `json:"apiVersion"`
		Caps       struct {
			Files bool `json:"files"`
		} `json:"caps"`
	}
	status = decode[struct {
		Name       string `json:"name"`
		APIVersion int    `json:"apiVersion"`
		Caps       struct {
			Files bool `json:"files"`
		} `json:"caps"`
	}](t, rec)
	if status.APIVersion != 1 || status.Name == "" {
		t.Fatalf("status = %+v", status)
	}
}

func TestAuthMiddlewareRejectsMissingToken(t *testing.T) {
	s, _ := newTestServer(t, false)
	rec := doReq(t, s.routes(), "GET", "/auth/me", nil, "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("auth/me = %d, want 401", rec.Code)
	}
	rec = doReq(t, s.routes(), "GET", "/auth/me", nil, "invalid.token.here")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("auth/me bad token = %d, want 401", rec.Code)
	}
}

func TestEnrollAndAuthenticatedFlow(t *testing.T) {
	s, _ := newTestServer(t, false)
	h := s.routes()

	access, refresh := enroll(t, s, h)
	if access == "" || refresh == "" {
		t.Fatal("empty tokens from enroll")
	}

	// me
	rec := doReq(t, h, "GET", "/auth/me", nil, access)
	if rec.Code != http.StatusOK {
		t.Fatalf("me = %d body = %s", rec.Code, rec.Body.String())
	}

	// metrics
	rec = doReq(t, h, "GET", "/metrics/latest", nil, access)
	if rec.Code != http.StatusOK {
		t.Fatalf("metrics = %d", rec.Code)
	}

	// refresh
	rec = doReq(t, h, "POST", "/auth/refresh", map[string]any{"refreshToken": refresh}, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("refresh = %d body = %s", rec.Code, rec.Body.String())
	}
	resp := decode[tokenResponse](t, rec)
	if resp.AccessToken == "" || resp.RefreshToken == "" {
		t.Fatal("empty rotated tokens")
	}
	// Old refresh is now invalid.
	rec = doReq(t, h, "POST", "/auth/refresh", map[string]any{"refreshToken": refresh}, "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("reuse refresh = %d, want 401", rec.Code)
	}
}

func TestEnrollBadToken(t *testing.T) {
	s, _ := newTestServer(t, false)
	rec := doReq(t, s.routes(), "POST", "/auth/enroll",
		map[string]any{"enrollmentToken": "qwe1-bogus", "device": map[string]any{}}, "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("bad enroll = %d, want 401", rec.Code)
	}
}

func TestReadOnlyGate(t *testing.T) {
	s, cfg := newTestServer(t, true)
	root := cfg.Files.Roots[0]
	if err := os.WriteFile(filepath.Join(root, "existing.txt"), []byte("x"), 0o644); err != nil {
		t.Fatal(err)
	}
	h := s.routes()
	access, _ := enroll(t, s, h)

	// Read is allowed in read-only mode.
	if rec := doReq(t, h, "GET", "/fs/list", nil, access); rec.Code != http.StatusOK {
		t.Fatalf("fs/list = %d", rec.Code)
	}
	// Mutations are rejected with 403.
	rec := doReq(t, h, "POST", "/fs/write?path=new.txt", "hi", access)
	if rec.Code != http.StatusForbidden {
		t.Fatalf("fs/write in read-only = %d, want 403 (body %s)", rec.Code, rec.Body.String())
	}
}

func TestFilesRoundTrip(t *testing.T) {
	s, cfg := newTestServer(t, false)
	h := s.routes()
	access, _ := enroll(t, s, h)

	// Write (path is a query param, content is the raw body).
	rec := doReq(t, h, "POST", "/fs/write?path=hello.txt", "hi there", access)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("write = %d body = %s", rec.Code, rec.Body.String())
	}

	// List.
	rec = doReq(t, h, "GET", "/fs/list", nil, access)
	if rec.Code != http.StatusOK {
		t.Fatalf("list = %d", rec.Code)
	}
	var listed struct {
		Items []struct {
			Name  string `json:"name"`
			IsDir bool   `json:"isDir"`
		} `json:"items"`
	}
	listed = decode[struct {
		Items []struct {
			Name  string `json:"name"`
			IsDir bool   `json:"isDir"`
		} `json:"items"`
	}](t, rec)
	found := false
	for _, e := range listed.Items {
		if e.Name == "hello.txt" {
			found = true
		}
	}
	if !found {
		t.Fatalf("hello.txt not listed: %+v", listed.Items)
	}

	// Read.
	rec = doReq(t, h, "GET", "/fs/read?path=hello.txt", nil, access)
	if rec.Code != http.StatusOK {
		t.Fatalf("read = %d body = %s", rec.Code, rec.Body.String())
	}
	if rec.Body.String() != "hi there" {
		t.Fatalf("read body = %q", rec.Body.String())
	}

	// Delete.
	rec = doReq(t, h, "DELETE", "/fs?path=hello.txt", nil, access)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("delete = %d body = %s", rec.Code, rec.Body.String())
	}
	root := cfg.Files.Roots[0]
	if _, err := os.Stat(filepath.Join(root, "hello.txt")); !os.IsNotExist(err) {
		t.Fatal("file not deleted")
	}
}

func TestRevoke(t *testing.T) {
	s, _ := newTestServer(t, false)
	h := s.routes()
	access, _ := enroll(t, s, h)
	rec := doReq(t, h, "POST", "/auth/revoke", map[string]any{}, access)
	if rec.Code != http.StatusOK && rec.Code != http.StatusNoContent {
		t.Fatalf("revoke = %d body = %s", rec.Code, rec.Body.String())
	}
	// Access token may still validate (stateless JWT) but refresh is dead.
	if got := s.authSvc.Devices(); len(got) != 0 {
		t.Fatalf("devices after revoke = %d, want 0", len(got))
	}
}

func TestShutdown(t *testing.T) {
	s, _ := newTestServer(t, false)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go s.alertsWorker(ctx)
	go s.sweepWorker(ctx)
	go s.limiterCleanup(ctx)
	if err := s.Shutdown(context.Background()); err != nil {
		t.Fatal(err)
	}
}

func TestAttemptTrackerLockout(t *testing.T) {
	cfg := config.Default()
	cfg.Auth.BruteForce = config.BruteForce{MaxAttempts: 2, Window: 10 * 1000000000, Lockout: 30 * 1000000000}
	tr := auth.NewAttemptTracker(cfg.Auth.BruteForce.MaxAttempts, cfg.Auth.BruteForce.Window, cfg.Auth.BruteForce.Lockout)
	if tr.Locked("1.2.3.4") {
		t.Fatal("should start unlocked")
	}
	tr.Fail("1.2.3.4")
	tr.Fail("1.2.3.4")
	if !tr.Locked("1.2.3.4") {
		t.Fatal("should be locked after 2 failures")
	}
	tr.Success("1.2.3.4")
	if tr.Locked("1.2.3.4") {
		t.Fatal("should unlock on success")
	}
}
