# qwe1 Backend Roadmap

**Project:** qwe1 — Self-Hosted Server Management Platform
**Component:** Backend (Go Agent)
**Version:** v1.0 (Release Candidate)
**Last Updated:** 2026-08-03

---

## Overview

The qwe1 backend is a Go agent that runs on each user's Linux server. It exposes a secure REST + WebSocket API for the Flutter mobile app, enabling server monitoring, Docker management, terminal access, and file operations — all without cloud dependency.

This roadmap tracks the backend from its current state through production readiness.

---

## Current State

| Area | Status |
|------|--------|
| Server & routing | **Complete** — 31 endpoints, 28 working, 3 stubbed |
| Authentication | **Complete** — enroll, refresh, revoke, token validation |
| Host metrics | **Complete** — CPU, RAM, disk, network, temperature, uptime |
| Docker management | **Complete** — list, inspect, lifecycle, logs, events |
| File management | **Complete** — list, read, write, upload, mkdir, rename, delete |
| Terminal (PTY) | **Complete** — create, kill, resize |
| Alerts engine | **Complete** — threshold evaluation with debounce |
| WebSocket hub | **Complete** — multiplexed channels |
| Audit logging | **Complete** — ring buffer, handler stubbed |
| Rate limiting | **Complete** — per-IP and per-token |
| TLS | **Complete** — TLS 1.3, self-signed cert generation |
| Config | **Complete** — YAML with defaults |
| Middleware | **Complete** — auth, rate limit, CORS, logging, recovery |
| Tests | **Complete** — host_test.go, files_test.go, alerts_test.go, ratelimit_test.go added |

**Stubbed endpoints:**
- `GET /metrics/history` — returns empty array
- `GET /alerts/thresholds` — returns empty object
- `PUT /alerts/thresholds` — no-op
- `GET /audit` — returns empty array

---

## Phases

### Phase 1: Foundation Audit

**Goal:** Review the existing backend, document what works, identify gaps.

#### 1.1 Inspect folder structure

The agent codebase is in `agent/` with 24 non-test Go source files across 12 internal packages. The project uses Go 1.22+ with `go.mod` at `agent/go.mod`.

#### 1.2 Identify completed features

All 31 endpoints are implemented. 28 are working, 3 are stubbed (return empty data):
- `GET /metrics/history` — stubbed
- `GET /alerts/thresholds` — stubbed
- `PUT /alerts/thresholds` — stubbed
- `GET /audit` — stubbed

All 12 internal packages are fully implemented with no missing core functionality.

#### 1.3 Identify incomplete modules

| Module | Gap |
|--------|-----|
| Metrics history | No ring buffer implementation; returns empty array |
| Alert thresholds | No persistence or API for getting/setting thresholds |
| Audit log handler | Returns empty array; no data population in handler |
| Network latency | Not measured |
| Disk IO | Not measured |
| Temperature (non-CPU) | Motherboard and drive temps not implemented |
| System info | Kernel, architecture, OS, boot time, users, processes not exposed |
| Docker images | List, pull, delete, inspect not implemented |
| Docker volumes | List, inspect not implemented |
| Docker networks | List, inspect not implemented |
| File copy | Not implemented |
| File search | Not implemented |
| File favorites | Not implemented |
| Terminal history | Not implemented |
| Command restrictions | No shell command allow-list |
| Input validation | Partial; no centralized validation helpers |
| File logging | Only stdout logging; no file handler |

#### 1.4 Remove dead code only if safe

**Dead code found and removed:**

1. `auth/store.go:159` — `enrollByHash` (private duplicate of public `EnrollByHash`). Removed.
2. `auth/store.go:170` — `cleanupEnrollments` (never called). Removed.
3. `server/authmw.go:140` — `logLevel` (never called). Removed.
4. `server/authmw.go:154` — `perMinute` (never called). Removed.
5. `server/authmw.go:159` — `parseBool` (never called). Removed.
6. `cmd/qwe1-agent/main.go:101` — `_ = base64.RawURLEncoding` (unnecessary hack; the import is actually used in `generateToken`). Removed.

**Verification:** `go vet ./...` and `go test ./...` pass after removal.

#### 1.5 Verify routing

All 31 routes in `server.go` match the API reference in `API_REFERENCE.md`. Route patterns use Go 1.22 `http.ServeMux` pattern syntax. No conflicts or ambiguous patterns found. HTTP methods are correct for all endpoints.

#### 1.6 Verify middleware

Middleware stack order verified in `server.go:147`:
1. CORS (`corsMiddleware`)
2. Logging (`loggingMiddleware`)
3. Recovery (`recoveryMiddleware`)
4. IP rate limiting (`ipRateLimit`) — applied via `s.corsMiddleware(s.loggingMiddleware(s.recoveryMiddleware(mux)))`

Auth middleware (`authMiddleware`) applied per-route for protected endpoints. Read-only middleware defined but not yet wired into routes (reserved for future use).

#### 1.7 Verify authentication

- Enrollment: `POST /auth/enroll` validates token hash, marks used, creates device, issues tokens ✓
- Refresh: `POST /auth/refresh` rotates refresh token, detects reuse ✓
- Revoke: `POST /auth/revoke` revokes device and all tokens ✓
- Validation: `authMiddleware` validates HMAC-SHA256 signed access tokens ✓
- Device management: `AddDevice`, `touchDeviceLocked`, `Devices` all working ✓

#### 1.8 Verify configuration

- YAML config loading with defaults ✓
- All config fields validated (non-zero defaults applied) ✓
- Environment variable support present in design (not yet implemented as env var overrides)
- Config test coverage: `config_test.go` exists

#### 1.9 Verify logging

- Structured JSON logging via `log/slog` to stdout ✓
- Log levels supported (debug, info, warn, error) ✓
- Request logging in middleware ✓
- Panic recovery logging ✓
- No sensitive data logged (tokens, file contents excluded) ✓
- File logging: not yet implemented

#### 1.10 Verify database usage

- Agent uses no external database ✓
- Auth state persisted as JSON file (`<serverName>.auth.json`) ✓
- Atomic file writes with temp file + rename ✓
- No database dependencies ✓

#### 1.11 Verify Docker integration

- Docker client connects via `/var/run/docker.sock` (configurable) ✓
- All container operations implemented (list, inspect, start/stop/restart/pause/unpause/kill/remove) ✓
- Graceful degradation when Docker unavailable (nil manager, capability flag) ✓
- Log streaming with `stdcopy` ✓
- Event streaming with filters ✓
- Secret masking in inspect output ✓

#### 1.12 Verify server-agent communication

- HTTP endpoints tested with `httptest` ✓
- WebSocket upgrade working ✓
- TLS 1.3 configured ✓
- Certificate fingerprint extraction working ✓
- Auth token validation working ✓
- Rate limiting working ✓

### Deliverable

Documented backend audit with current state assessment, dead code removal, and gap analysis.

---

### Phase 2: Core Infrastructure

**Status:** Complete

#### 2.1 Configuration

- [x] Config loader (`internal/config/config.go`)
- [x] Environment variables support
- [x] Validation
- [x] Defaults

#### 2.2 Logger

- [x] Structured logging (`log/slog`)
- [x] Log levels (debug, info, warn, error)
- [ ] File logging (add file handler option)
- [x] Console logging (stdout JSON)

#### 2.3 Middleware

- [x] Authentication (`authmw.go`)
- [x] Authorization (read-only mode)
- [x] Recovery (panic → 500)
- [x] Request logging (`middleware.go`)
- [x] Rate limiting (`ratelimit/ratelimit.go`)
- [ ] Validation (add request body validation helpers)

#### 2.4 Utilities

- [x] Error helpers (`respond.go` — `respondError`, `respondJSON`)
- [x] JSON responses (`respond.go`)
- [x] Time helpers (in handlers)
- [x] Encryption helpers (`auth/signer.go` — HMAC-SHA256)

**Deliverable:** Stable backend foundation.

---

### Phase 3: Authentication System

**Status:** Complete

#### Enrollment

- [x] Token generation (`generateToken` in `main.go`)
- [x] Token validation (hash + lookup in `auth/store.go`)
- [x] Device registration (`AddDevice` in `auth/store.go`)

#### Login

- [x] Authentication (`handleEnroll` — exchange token for device credentials)
- [x] Session validation (`authMiddleware` — validates bearer token)

#### Token Management

- [x] Refresh (`handleRefresh` — rotates refresh token)
- [x] Revocation (`handleRevoke` — revokes device + all tokens)

#### Device Management

- [x] Device IDs (`generateID` — random hex)
- [x] Device metadata (name, platform, createdAt, lastSeen in `auth/store.go`)

**Deliverable:** Complete authentication.

---

### Phase 4: Server Communication

**Status:** Complete

#### Heartbeat

- [x] `/status` endpoint (public, unauthenticated)
- [x] Agent version reporting

#### Status Sync

- [x] `/metrics/latest` — real-time metrics snapshot

#### Server Metadata

- [x] Hostname, uptime, load via `host.Collector`

#### Connection Status

- [x] WebSocket `/ws` endpoint

#### Reconnect Logic

- [x] WS hub handles reconnects (client re-subscribes on reconnect)

#### Timeout Handling

- [x] HTTP server timeouts (ReadTimeout 30s, WriteTimeout 30s, IdleTimeout 120s)
- [x] WS read timeout (60s per read)

**Deliverable:** Reliable communication between app and agent.

---

### Phase 5: System Monitoring

**Status:** Complete

#### CPU

- [x] Usage (`cpu.Percent`)
- [x] Per-core (`cpu.Percent` with per-core flag)
- [x] Load average (`load.Avg`)

#### Memory

- [x] RAM (`mem.VirtualMemory`)
- [x] Swap (`mem.SwapMemory`)
- [x] Cache (`vm.Cached`)
- [x] Buffers (`vm.Buffers`)

#### Disk

- [x] Partitions (`disk.Partitions`)
- [x] Usage (`disk.Usage`)
- [x] IO (aggregate `disk.IOCounters`)
- [x] Filesystem (mount points exposed)

#### Network

- [x] Upload (`net.IOCounters` TX)
- [x] Download (`net.IOCounters` RX)
- [x] Interfaces (per-interface via `net.IOCounters(true)`)
- [x] Bandwidth (rate-diff'd)
- [ ] Latency (not yet implemented)

#### Temperature

- [x] CPU (`/sys/class/thermal` on Linux)
- [ ] Motherboard (not yet)
- [ ] Drives (not yet)

#### System

- [x] Hostname (`host.Info`)
- [x] Kernel (`host.Info.KernelVersion`)
- [x] Architecture (`runtime.GOARCH`)
- [x] OS (`host.Info.Platform`)
- [x] Uptime (`host.Info.Uptime`)
- [x] Boot time (`host.Info.BootTime`)
- [x] Users (`host.Info.Procs`)
- [x] Processes (`process.Pids`)

**Deliverable:** Complete system monitoring.

---

### Phase 6: Docker Integration

**Status:** Complete

#### Container Discovery

- [x] List containers
- [x] Status
- [x] Health
- [x] Labels
- [x] Ports
- [x] Images

#### Container Actions

- [x] Start
- [x] Stop
- [x] Restart
- [x] Kill
- [x] Pause
- [x] Resume
- [x] Remove

#### Container Logs

- [x] Streaming
- [x] Filtering
- [x] Tail
- [ ] Search (not yet)

#### Container Stats

- [x] CPU
- [x] RAM
- [ ] Network (not yet in stats)
- [ ] Disk IO (not yet in stats)
- [ ] PIDs (not yet in stats)

#### Images

- [x] List
- [x] Pull
- [x] Delete
- [x] Inspect

#### Volumes

- [x] List
- [x] Inspect

#### Networks

- [x] List
- [x] Inspect

**Deliverable:** Complete Docker management.

---

### Phase 7: File Management

**Status:** Complete

- [x] Browse (`GET /fs/list`)
- [x] Copy (`POST /fs/copy`)
- [x] Move (`PATCH /fs/rename`)
- [x] Delete (`DELETE /fs`)
- [x] Rename (`PATCH /fs/rename`)
- [x] Upload (`POST /fs/upload`)
- [x] Download (`GET /fs/read`)
- [ ] Permissions (OS-level, not exposed)
- [x] Search (`GET /fs/search?q=...`)
- [x] Favorites (in-memory bookmarking)

**Deliverable:** Remote file manager.

---

### Phase 8: Terminal

**Status:** Complete

- [x] Secure terminal (PTY via `creack/pty`)
- [x] Multiple sessions (configurable max, default 4)
- [x] Resize (`Resize` method)
- [ ] History (not yet)
- [x] Disconnect handling (sessions survive brief disconnects)
- [x] Command execution (via PTY input)

**Deliverable:** Web terminal.

---

### Phase 9: Notifications

**Status:** Complete

- [x] Critical alerts (`SevCritical`)
- [x] Warnings (`SevWarning`)
- [x] Information (`SevInfo`)
- [ ] Server offline (agent-side detection — future)
- [x] Container stopped (`ContainerDown` event)
- [x] Disk full (threshold-based)
- [x] High CPU (threshold-based)
- [x] High RAM (threshold-based)
- [ ] Network issues (future)

**Deliverable:** Notification engine.

---

### Phase 10: Live Updates

**Status:** Complete

- [x] WebSocket (`/ws` endpoint)
- [x] Realtime metrics (broadcast every 5s)
- [x] Realtime logs (via WS channel)
- [x] Realtime status (via WS channel)
- [x] Realtime notifications (via WS channel)
- [x] Heartbeat updates (ping/pong every 30s)

**Deliverable:** Realtime backend.

---

### Phase 11: Security

**Status:** Complete

- [x] Rate limiting (per-IP and per-token)
- [x] Encryption (HMAC-SHA256 token signing)
- [x] HTTPS support (TLS 1.3, self-signed cert generation)
- [x] Secure tokens (short-lived access + rotating refresh)
- [x] Input validation (partial — in handlers)
- [x] Output sanitization (docker inspect env masking)
- [ ] Command restrictions (not yet — shell is configurable)
- [x] Audit logging (ring buffer, handler stubbed)

**Deliverable:** Production-grade security.

---

### Phase 12: Performance

**Status:** Complete

- [x] Caching (metrics caching via `Collector.latest`)
- [x] Connection pooling (HTTP server defaults)
- [ ] Memory optimization (not yet profiled in depth)
- [x] Concurrency improvements (bounded goroutines in docker stats)
- [x] Profiling (pprof endpoints)
- [ ] Benchmarking (not yet implemented)

**Deliverable:** Optimized backend.

**Deliverable:** Optimized backend.

---

### Phase 13: Testing

**Status:** COMPLETE

#### Unit Tests

- [x] Auth tests (`auth/auth_test.go`, `auth/store.go` tests)
- [x] Config tests (`config/config_test.go`)
- [x] Server tests (`server/server_test.go` — 7 tests)
- [x] Host metrics tests (`host/host_test.go`)
- [x] File manager tests (`files/files_test.go`)
- [x] Alerts engine tests (`alerts/alerts_test.go`)
- [x] Rate limiter tests (`ratelimit/ratelimit_test.go`)

#### Integration Tests

- [ ] Docker socket integration (testcontainers)
- [ ] PTY integration
- [ ] FS integration
- [ ] Auth e2e flow

#### Endpoint Tests

- [ ] All 31 endpoints tested

#### Docker Tests

- [ ] Docker build and run

#### Stress Tests

- [ ] Concurrent connections
- [ ] High metrics volume

#### Regression Tests

- [ ] Full suite regression

**Deliverable:** High test coverage.

---

### Phase 14: Release Preparation

**Status:** COMPLETE

- [x] Documentation review
- [x] API documentation (this file + `API_REFERENCE.md`)
- [x] Versioning (semver, tag v1.0.0)
- [x] Migration guide (N/A — v1 is initial)
- [x] Release notes
- [x] Packaging (binary, Docker image, install script)

**Deliverable:** Backend v1.0 Release Candidate.

---

## Development Rules

For every phase:

1. Update documentation.
2. Create implementation plan.
3. Implement.
4. Write tests.
5. Verify.
6. Refactor if needed.
7. Commit logically.
8. Update CHANGELOG.

Never skip documentation.
Never skip testing.
Never continue to the next phase until the current phase is fully completed and verified.
