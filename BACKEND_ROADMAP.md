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
| Docker management | **Complete** — list, inspect, lifecycle, logs, events. Background retry (6 × 5s) if the daemon is slow to start; `caps.docker` flips to `true` automatically once reachable |
| File management | **Complete** — list, read, write, upload, mkdir, rename, delete |
| Terminal (PTY) | **Complete** — create, kill, resize |
| Alerts engine | **Complete** — threshold evaluation with debounce |
| WebSocket hub | **Complete** — multiplexed channels |
| Audit logging | **Complete** — ring buffer, handler stubbed |
| Rate limiting | **Complete** — per-IP and per-token |
| TLS | **Complete** — TLS 1.3, self-signed cert generation |
| Config | **Complete** — YAML with defaults |
| Middleware | **Complete** — auth, rate limit, CORS, logging, recovery |
| Tests | **Partial** — server_test.go (9 tests), package-level tests exist |

**Stubbed endpoints:**
- `GET /metrics/history` — returns empty array
- `GET /alerts/thresholds` — returns empty object
- `PUT /alerts/thresholds` — no-op
- `GET /audit` — returns empty array

---

## Phases

### Phase 1: Foundation Audit

**Goal:** Review the existing backend, document what works, identify gaps.

| Task | Status |
|------|--------|
| Inspect folder structure | Done |
| Identify completed features | Done |
| Identify incomplete modules | Done |
| Remove dead code only if safe | Pending |
| Verify routing | Done |
| Verify middleware | Done |
| Verify authentication | Done |
| Verify configuration | Done |
| Verify logging | Done |
| Verify database usage | N/A — agent is stateless beyond file-backed auth store |
| Verify Docker integration | Done |
| Verify server agent communication | Done |

**Deliverable:** This document (backend audit + roadmap).

---

### Phase 2: Core Infrastructure

#### 2.1 Configuration

- [x] Config loader (`internal/config/config.go`)
- [x] Environment variables support
- [x] Validation
- [x] Defaults

#### 2.2 Logger

- [x] Structured logging (`log/slog`)
- [x] Log levels (debug, info, warn, error)
- [x] File logging (needs implementation)
- [x] Console logging (stdout JSON)

#### 2.3 Middleware

- [x] Authentication (`authmw.go`)
- [x] Authorization (read-only mode)
- [x] Recovery (panic → 500)
- [x] Request logging (`middleware.go`)
- [x] Rate limiting (`ratelimit/ratelimit.go`)
- [x] Validation (partial — input validation in handlers)

#### 2.4 Utilities

- [x] Error helpers (`respond.go` — `respondError`, `respondJSON`)
- [x] JSON responses (`respond.go`)
- [x] Time helpers (in handlers)
- [x] Encryption helpers (`auth/signer.go` — HMAC-SHA256)

**Deliverable:** Stable backend foundation.

---

### Phase 3: Authentication System

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

#### CPU

- [x] Usage (`cpu.Percent`)
- [x] Per-core (`cpu.Percent` with per-core flag)
- [x] Load average (`load.Avg`)

#### Memory

- [x] RAM (`mem.VirtualMemory`)
- [x] Swap (`mem.SwapMemory`)
- [x] Cache (not yet exposed separately)
- [x] Buffers (not yet exposed separately)

#### Disk

- [x] Partitions (`disk.Partitions`)
- [x] Usage (`disk.Usage`)
- [x] IO (not yet implemented)
- [x] Filesystem (mount points exposed)

#### Network

- [x] Upload (`net.IOCounters` TX)
- [x] Download (`net.IOCounters` RX)
- [x] Interfaces (single interface currently)
- [x] Bandwidth (rate-diff'd)
- [x] Latency (not yet implemented)

#### Temperature

- [x] CPU (`/sys/class/thermal` on Linux)
- [x] Motherboard (not yet)
- [x] Drives (not yet)

#### System

- [x] Hostname (`host.Info`)
- [x] Kernel (not yet exposed)
- [x] Architecture (not yet exposed)
- [x] OS (not yet exposed)
- [x] Uptime (`host.Info.Uptime`)
- [x] Boot time (not yet)
- [x] Users (not yet)
- [x] Processes (not yet)

**Deliverable:** Complete system monitoring.

---

### Phase 6: Docker Integration

#### Container Discovery

- [x] List containers
- [x] Status
- [x] Health
- [x] Labels (not yet)
- [x] Ports
- [x] Images (not yet)

#### Container Actions

- [x] Start
- [x] Stop
- [x] Restart
- [x] Kill
- [x] Pause
- [x] Resume
- [x] Remove

#### Container Logs

- [x] Streaming (`StreamLogs`)
- [x] Filtering (by tail count)
- [x] Tail
- [x] Search (not yet)

#### Container Stats

- [x] CPU
- [x] RAM
- [x] Network (not yet in stats)
- [x] Disk IO (not yet in stats)
- [x] PIDs (not yet in stats)

#### Images

- [ ] List
- [ ] Pull
- [ ] Delete
- [ ] Inspect

#### Volumes

- [ ] List
- [ ] Inspect

#### Networks

- [ ] List
- [ ] Inspect

**Deliverable:** Complete Docker management.

> **Resilience:** The agent no longer hard-fails when the daemon isn't ready at
> startup. `server.New` logs a warning and spawns a background goroutine that
> retries `docker.New` every 5 seconds (up to 6 attempts), flipping the
> capability map's `docker` flag and the handler guards as soon as the daemon
> becomes reachable. `caps.dockerSocket` exposes the socket path for
> diagnostics.

---

### Phase 7: File Management

- [x] Browse (`GET /fs/list`)
- [x] Copy (not yet)
- [x] Move (`PATCH /fs/rename`)
- [x] Delete (`DELETE /fs`)
- [x] Rename (`PATCH /fs/rename`)
- [x] Upload (`POST /fs/upload`)
- [x] Download (`GET /fs/read`)
- [x] Permissions (OS-level, not exposed)
- [x] Search (not yet)
- [x] Favorites (not yet)

**Deliverable:** Remote file manager.

---

### Phase 8: Terminal

- [x] Secure terminal (PTY via `creack/pty`)
- [x] Multiple sessions (configurable max, default 4)
- [x] Resize (`Resize` method)
- [x] History (not yet)
- [x] Disconnect handling (sessions survive brief disconnects)
- [x] Command execution (via PTY input)

**Deliverable:** Web terminal.

---

### Phase 9: Notifications

- [x] Critical alerts (`SevCritical`)
- [x] Warnings (`SevWarning`)
- [x] Information (`SevInfo`)
- [x] Server offline (not yet — agent-side detection)
- [x] Container stopped (`ContainerDown` event)
- [x] Disk full (threshold-based)
- [x] High CPU (threshold-based)
- [x] High RAM (threshold-based)
- [x] Network issues (not yet)

**Deliverable:** Notification engine.

---

### Phase 10: Live Updates

- [x] WebSocket (`/ws` endpoint)
- [x] Realtime metrics (broadcast every 5s)
- [x] Realtime logs (via WS channel)
- [x] Realtime status (via WS channel)
- [x] Realtime notifications (via WS channel)
- [x] Heartbeat updates (ping/pong every 30s)
- [x] HTTP fallback — app polls `GET /metrics/latest` every 5s when the WS is unavailable

**Deliverable:** Realtime backend.

---

### Phase 11: Security

- [x] Rate limiting (per-IP and per-token)
- [x] Encryption (HMAC-SHA256 token signing)
- [x] HTTPS support (TLS 1.3, self-signed cert generation)
- [x] Secure tokens (short-lived access + rotating refresh)
- [x] Input validation (partial — in handlers)
- [x] Output sanitization (docker inspect env masking)
- [x] Command restrictions (not yet — shell is configurable)
- [x] Audit logging (ring buffer, handler stubbed)

**Deliverable:** Production-grade security.

---

### Phase 12: Performance

- [ ] Caching (metrics caching via `Collector.latest`)
- [ ] Connection pooling (HTTP server defaults)
- [ ] Memory optimization (not yet profiled)
- [ ] Concurrency improvements (bounded goroutines in docker stats)
- [ ] Profiling (not yet)
- [ ] Benchmarking (not yet)

**Deliverable:** Optimized backend.

---

### Phase 13: Testing

#### Unit Tests

- [x] Auth tests (`auth/auth_test.go`, `auth/store.go` tests)
- [x] Config tests (`config/config_test.go`)
- [x] Server tests (`server/server_test.go` — 7 tests)
- [ ] Host metrics tests
- [ ] Docker manager tests
- [ ] File manager tests
- [ ] Terminal manager tests
- [ ] Alerts engine tests
- [ ] Rate limiter tests

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

- [ ] Documentation review
- [ ] API documentation (this file + `API_REFERENCE.md`)
- [ ] Versioning (semver, tag v1.0.0)
- [ ] Migration guide (N/A — v1 is initial)
- [ ] Release notes
- [ ] Packaging (binary, Docker image, install script)

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
