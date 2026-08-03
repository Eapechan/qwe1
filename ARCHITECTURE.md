# qwe1 Backend Architecture

**Project:** qwe1 — Self-Hosted Server Management Platform
**Component:** Backend (Go Agent)
**Version:** v1.0
**Last Updated:** 2026-08-03

---

## System Overview

```
Flutter App (phone) <-- HTTPS + WSS --> Go Agent (server) --> Docker API
                                                        --> Linux sysfs/proc
```

The agent is a single static Go binary that runs on each user's Linux server. It:

- Serves a REST API over HTTPS (TLS 1.3)
- Serves a WebSocket endpoint for real-time streams
- Collects host metrics via `gopsutil` and sysfs
- Manages Docker containers via the Docker Engine API
- Provides PTY-based terminal sessions
- Enforces file operations within allow-listed roots
- Evaluates alert thresholds and buffers events
- Records an audit log of privileged actions

---

## Folder Structure

```
agent/
├── cmd/
│   └── qwe1-agent/
│       └── main.go              # Entrypoint: flags, enroll CLI, server bootstrap
├── internal/
│   ├── server/
│   │   ├── server.go            # HTTP server setup, route registration, lifecycle
│   │   ├── handlers.go          # All REST endpoint handlers
│   │   ├── authmw.go            # Auth middleware, rate limiting, audit recording
│   │   ├── middleware.go        # Logging, recovery, CORS middleware
│   │   ├── respond.go           # JSON response helpers, JSON decoder
│   │   ├── types.go             # Shared API type aliases
│   │   ├── ws.go                # WebSocket hub, client management, message routing
│   │   ├── server_test.go       # Integration tests for routes and auth flow
│   │   └── middleware/          # (reserved for additional middleware)
│   │   └── websocket/           # (reserved for WS sub-protocols)
│   ├── auth/
│   │   ├── auth.go              # (placeholder — auth logic in store.go + signer.go)
│   │   ├── store.go             # Persistent auth store (JSON, mutex-guarded)
│   │   ├── signer.go            # HMAC-SHA256 token signing/validation
│   │   ├── attempts.go          # Brute-force lockout tracker
│   │   └── auth_test.go         # Auth tests
│   ├── config/
│   │   ├── config.go            # YAML config loader with defaults
│   │   └── config_test.go       # Config tests
│   ├── host/
│   │   ├── host.go              # Metrics collector (CPU, RAM, disk, network, temp)
│   │   ├── temps_linux.go       # Linux temperature sensor reads
│   │   └── temps_other.go       # Stub for non-Linux platforms
│   ├── docker/
│   │   └── docker.go            # Docker Engine API wrapper
│   ├── terminal/
│   │   ├── terminal.go          # PTY session manager
│   │   ├── terminal_test.go     # Terminal tests
│   │   ├── sysproc_linux.go     # Linux-specific process attributes
│   │   └── sysproc_darwin.go    # macOS-specific process attributes
│   ├── files/
│   │   ├── files.go             # Allow-listed filesystem operations
│   │   └── files_test.go        # File manager tests
│   ├── alerts/
│   │   ├── alerts.go            # Threshold evaluation engine
│   │   └── alerts_test.go       # Alerts tests
│   ├── ratelimit/
│   │   ├── ratelimit.go         # Token-bucket rate limiter
│   │   └── ratelimit_test.go    # Rate limiter tests
│   ├── audit/
│   │   └── audit.go             # Bounded ring-buffer audit log
│   ├── certs/
│   │   └── certs.go             # Self-signed ECDSA cert generation
│   └── server/
│       └── respond.go           # (moved to internal/server/)
├── Dockerfile
├── Makefile
├── go.mod
├── go.sum
└── qwe1-agent.auth.json         # Runtime auth state (generated)
```

---

## Request Flow

### REST Request

```
Client → HTTPS → CORS middleware → Logging middleware → Recovery middleware
  → Rate limiting (per-IP) → Route matching → Auth middleware (if protected)
  → Rate limiting (per-token) → Handler → JSON response
```

### WebSocket Connection

```
Client → WSS → WS upgrade → Channel subscription → Bidirectional stream
  • Client sends: binary (input), JSON control (resize, ping, subscribe)
  • Agent sends: binary (output), JSON (events, control)
```

---

## Middleware Stack (Ordered)

| Order | Middleware | Scope | Purpose |
|-------|-----------|-------|---------|
| 1 | CORS | All | Cross-origin headers, OPTIONS handling |
| 2 | Logging | All | Request logging (method, path, status, duration) |
| 3 | Recovery | All | Panic recovery → 500, no crash |
| 4 | IP Rate Limit | All | Per-IP token-bucket limiter |
| 5 | Auth | Protected | Bearer token validation, device context injection |
| 6 | Token Rate Limit | Protected | Per-token token-bucket limiter |
| 7 | Read-Only | Mutating | Rejects mutations when agent is read-only |

---

## Package Responsibility Matrix

| Package | Responsibility | Key Types |
|---------|---------------|-----------|
| `server` | HTTP/WS server, routing, middleware wiring, handlers | `Server`, `WSHub` |
| `auth` | Token generation, validation, storage, device management | `Store`, `Signer`, `AttemptTracker` |
| `config` | YAML configuration loading, defaults | `Config`, `AuthConfig`, `DockerConfig`, etc. |
| `host` | Host metrics collection (CPU, RAM, disk, network, temp) | `Collector`, `Metrics`, `CPUInfo`, `MemoryInfo` |
| `docker` | Docker Engine API interaction | `Manager`, `Container`, `LogLine`, `Event` |
| `terminal` | PTY session management | `Manager`, `Session` |
| `files` | Allow-listed filesystem operations | `Manager`, `Entry` |
| `alerts` | Threshold evaluation with debounce and dedupe | `Engine`, `Alert`, `Threshold`, `Rules` |
| `ratelimit` | Token-bucket rate limiting | `Limiter`, `bucket` |
| `audit` | Bounded ring-buffer audit log | `Log`, `Entry` |
| `certs` | Self-signed TLS certificate generation | `CertManager` |

---

## Data Flows

### Authentication Flow

```
1. Agent: --enroll → generates random token (qwe1-<base64url>)
2. Agent: hashes token (SHA-256), stores in <serverName>.auth.json with expiry
3. App: POST /auth/enroll { enrollmentToken, device }
4. Agent: validates token hash, marks used, creates device, signs access token
5. Agent: generates refresh token, stores hash in auth store
6. Agent: returns { accessToken, refreshToken, expiresIn, serverFingerprint }
7. App: stores tokens, uses accessToken for subsequent requests
8. App: POST /auth/refresh { refreshToken } → rotates refresh token
9. App: POST /auth/revoke → revokes device, all tokens invalidated
```

### Metrics Flow

```
1. Agent: Collector.Run() samples metrics every N seconds (default 5s)
2. Agent: latest snapshot cached in Collector.latest
3. App: GET /metrics/latest → returns latest snapshot
4. Agent: broadcastMetrics() pushes to WS clients every 5s via /ws channel "metrics"
5. Agent: alerts.EvaluateHost() checks thresholds on every sample
```

### Docker Flow

```
1. App: GET /docker/containers → Agent lists containers via Docker API
2. App: POST /docker/containers/{id}/start → Agent calls ContainerStart
3. Agent: StreamEvents() forwards container state changes to WS clients
4. Agent: StreamLogs() tails container logs, streams via WS channel "logs"
```

### Terminal Flow

```
1. App: POST /terminal { cols, rows } → Agent creates PTY session
2. Agent: returns { sessionId, wsUrl: "/ws?channels=terminal:{id}" }
3. App: connects WSS to /ws?channels=terminal:{id}
4. App → Agent: binary frames (keyboard input)
5. Agent → App: binary frames (PTY output)
6. App → Agent: JSON control { op: "resize", cols, rows }
7. Agent: Resize() calls pty.Setsize()
```

### File Flow

```
1. App: GET /fs/list?path=/home/user → Agent resolves path within allowed roots
2. Agent: List() returns sorted directory entries (dirs first, then files)
3. App: GET /fs/read?path=file.txt → Agent opens file, streams content
4. App: POST /fs/upload (multipart/form-data) → Agent writes to temp, atomic rename
5. Agent: Resolve() normalizes path, checks symlink escapes, confines to roots
```

---

## Security Architecture

### TLS

- Minimum TLS 1.3
- Self-signed ECDSA P-256 certificates auto-generated on first run
- Certificate fingerprint shown during enrollment for out-of-band verification
- Configurable cert/key paths

### Tokens

- **Access tokens:** HMAC-SHA256 signed opaque tokens containing `deviceID:expiry`
- **Refresh tokens:** Random 32-byte base64url tokens
- **Access token TTL:** 900 seconds (15 minutes) default
- **Refresh token TTL:** 2592000 seconds (30 days) default
- **Rotation:** Refresh tokens are single-use; new refresh token issued on each refresh
- **Reuse detection:** Reusing a refresh token revokes the entire device

### Rate Limiting

- **Per-IP:** 60 requests/minute, burst 30
- **Per-token:** 300 requests/minute, burst 10
- **Enroll endpoint:** 10 requests/minute, burst 20
- **Algorithm:** Token-bucket with automatic bucket cleanup

### Path Safety

- All file paths resolved relative to allow-listed roots
- Symlink-aware resolution (resolves nearest existing ancestor)
- Traversal attempts return 403 `PATH_FORBIDDEN`
- Hidden files excluded by default

### Audit

- Privileged actions logged: enroll, auth events, container mutations, terminal create/kill, file deletions
- Fields: timestamp, actor (device ID), action, target, result, IP
- Bounded ring buffer (default 1000 entries)

---

## Configuration

```yaml
serverName: qwe1-agent
listenHost: "0.0.0.0"
listenPort: 9443
tlsCertPath: "/etc/qwe1/certs/cert.pem"
tlsKeyPath: "/etc/qwe1/certs/key.pem"

auth:
  accessTokenTTL: 900
  refreshTokenTTL: 2592000

docker:
  socketPath: "/var/run/docker.sock"
  enabled: true

host:
  metricsInterval: 5
  temperaturePath: "/sys/class/thermal"

terminal:
  maxSessions: 4
  idleTimeout: 300

files:
  allowedRoots:
    - "/home"
    - "/var/log"
  maxUpload: 524288000

alerts:
  enabled: true
  bufferSize: 1000
```

---

## Deployment

### Docker

```dockerfile
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /qwe1-agent ./cmd/qwe1-agent

FROM alpine:3.19
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /qwe1-agent /usr/local/bin/qwe1-agent
RUN addgroup -S qwe1 && adduser -S qwe1 -G qwe1
USER qwe1
EXPOSE 9443
ENTRYPOINT ["qwe1-agent"]
```

### Direct Binary

```bash
GOOS=linux GOARCH=amd64 go build -o qwe1-agent ./cmd/qwe1-agent
scp qwe1-agent user@server:~/qwe1-agent
ssh user@server
./qwe1-agent --config /etc/qwe1/config.yaml
```

---

## Future Considerations

- **Metrics export:** Prometheus `/metrics` endpoint (toggle, default off)
- **Health check:** `/healthz` endpoint for load balancers
- **Plugin architecture:** Isolated module boundaries ready for v2 plugins
- **Multi-user RBAC:** Auth layer supports device identity separation; RBAC is additive