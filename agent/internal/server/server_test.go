package server

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/qwe1/qwe1/agent/internal/auth"
	"github.com/qwe1/qwe1/agent/config"
)

type tokenResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	TokenType    string `json:"tokenType"`
}

func newTestServer(t *testing.T) (*Server, *config.Config) {
	t.Helper()
	cfg := config.Default()
	cfg.ServerName = filepath.Join(t.TempDir(), "agent")
	cfg.Docker.Enabled = false
	cfg.TLSCertPath = ""
	cfg.TLSKeyPath = ""
	cfg.Files.AllowedRoots = []string{t.TempDir()}

	s, err := New(cfg)
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

// enroll seeds an enrollment token into the store and exchanges it for
// access/refresh tokens via the /auth/enroll endpoint.
func enroll(t *testing.T, s *Server, h http.Handler) (access, refresh string) {
	t.Helper()
	tok := "qwe1-test-token"
	s.auth.AddEnrollment(auth.HashToken(tok), time.Now().Add(time.Hour))
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

func TestStatus(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()
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

// TestCapabilitiesReported verifies the capability envelope (including the
// dockerSocket diagnostic) is present on /status and /auth/me. It runs with
// Docker disabled, so it is safe on machines without a Docker daemon.
func TestCapabilitiesReported(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()

	access, _ := enroll(t, s, h)

	for _, tc := range []struct {
		name, path string
		token      string
	}{
		{"status", "/status", ""},
		{"me", "/auth/me", access},
	} {
		t.Run(tc.name, func(t *testing.T) {
			rec := doReq(t, h, "GET", tc.path, nil, tc.token)
			if rec.Code != http.StatusOK {
				t.Fatalf("%s = %d body = %s", tc.path, rec.Code, rec.Body.String())
			}
			var body struct {
				Caps map[string]any `json:"caps"`
			}
			_ = json.Unmarshal(rec.Body.Bytes(), &body)
			caps := body.Caps
			if caps == nil {
				var body2 struct {
					Capabilities map[string]any `json:"capabilities"`
				}
				_ = json.Unmarshal(rec.Body.Bytes(), &body2)
				caps = body2.Capabilities
			}
			if caps == nil {
				t.Fatalf("%s: no caps/capabilities in %s", tc.path, rec.Body.String())
			}
			if _, ok := caps["docker"].(bool); !ok {
				t.Fatalf("%s: docker cap missing or not bool: %v", tc.path, caps)
			}
			if _, ok := caps["dockerSocket"].(string); !ok {
				t.Fatalf("%s: dockerSocket diag missing: %v", tc.path, caps)
			}
			for _, k := range []string{"terminal", "files", "tempSensors"} {
				if _, ok := caps[k].(bool); !ok {
					t.Fatalf("%s: %s cap missing: %v", tc.path, k, caps)
				}
			}
		})
	}
}

// TestDockerContainersUnavailable verifies the Docker endpoint returns 503
// DOCKER_UNAVAILABLE when the manager is not reachable — this must hold on
// machines without a Docker daemon (e.g. macOS CI).
func TestDockerContainersUnavailable(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()
	access, _ := enroll(t, s, h)
	rec := doReq(t, h, "GET", "/docker/containers", nil, access)
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("docker/containers = %d, want 503 (body %s)", rec.Code, rec.Body.String())
	}
	if !strings.Contains(rec.Body.String(), "DOCKER_UNAVAILABLE") {
		t.Fatalf("expected DOCKER_UNAVAILABLE in body: %s", rec.Body.String())
	}
}

func TestAuthMiddlewareRejectsMissingToken(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()
	if rec := doReq(t, h, "GET", "/auth/me", nil, ""); rec.Code != http.StatusUnauthorized {
		t.Fatalf("auth/me = %d, want 401", rec.Code)
	}
	if rec := doReq(t, h, "GET", "/auth/me", nil, "invalid.token.here"); rec.Code != http.StatusUnauthorized {
		t.Fatalf("auth/me bad token = %d, want 401", rec.Code)
	}
}

func TestEnrollAndAuthenticatedFlow(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()

	access, refresh := enroll(t, s, h)
	if access == "" || refresh == "" {
		t.Fatal("empty tokens from enroll")
	}

	if rec := doReq(t, h, "GET", "/auth/me", nil, access); rec.Code != http.StatusOK {
		t.Fatalf("me = %d body = %s", rec.Code, rec.Body.String())
	}
	if rec := doReq(t, h, "GET", "/metrics/latest", nil, access); rec.Code != http.StatusOK {
		t.Fatalf("metrics = %d", rec.Code)
	}

	// Refresh rotation.
	rec := doReq(t, h, "POST", "/auth/refresh", map[string]any{"refreshToken": refresh}, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("refresh = %d body = %s", rec.Code, rec.Body.String())
	}
	resp := decode[tokenResponse](t, rec)
	if resp.AccessToken == "" || resp.RefreshToken == "" {
		t.Fatal("empty rotated tokens")
	}
	// Old refresh is now invalid and reuse revokes the device.
	if rec := doReq(t, h, "POST", "/auth/refresh", map[string]any{"refreshToken": refresh}, ""); rec.Code != http.StatusUnauthorized {
		t.Fatalf("reuse refresh = %d, want 401", rec.Code)
	}
}

func TestEnrollBadToken(t *testing.T) {
	s, _ := newTestServer(t)
	rec := doReq(t, s.routes(), "POST", "/auth/enroll",
		map[string]any{"enrollmentToken": "qwe1-bogus", "device": map[string]any{}}, "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("bad enroll = %d, want 401", rec.Code)
	}
}

func TestFilesRoundTrip(t *testing.T) {
	s, cfg := newTestServer(t)
	h := s.routes()
	access, _ := enroll(t, s, h)

	// Write (JSON body with path + content).
	rec := doReq(t, h, "POST", "/fs/write", map[string]any{"path": "hello.txt", "content": "hi there"}, access)
	if rec.Code != http.StatusOK {
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

	// Read (raw body).
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
	if _, err := os.Stat(filepath.Join(cfg.Files.AllowedRoots[0], "hello.txt")); !os.IsNotExist(err) {
		t.Fatal("file not deleted")
	}
}

func TestRevoke(t *testing.T) {
	s, _ := newTestServer(t)
	h := s.routes()
	access, _ := enroll(t, s, h)
	rec := doReq(t, h, "POST", "/auth/revoke", map[string]any{}, access)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("revoke = %d body = %s", rec.Code, rec.Body.String())
	}
	if got := s.auth.DeviceCount(); got != 0 {
		t.Fatalf("devices after revoke = %d, want 0", got)
	}
}

func TestAttemptTrackerLockout(t *testing.T) {
	tr := auth.NewAttemptTracker(2, 10*time.Second, 30*time.Second)
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
