# qwe1 Backend Development Plan

**Project:** qwe1 — Self-Hosted Server Management Platform
**Component:** Backend (Go Agent)
**Version:** v1.0
**Last Updated:** 2026-08-03

---

## Development Workflow

For every phase and subphase, follow this 8-step cycle:

1. **Update documentation** — Ensure all relevant docs reflect the plan before coding.
2. **Create implementation plan** — Break the work into concrete, testable tasks.
3. **Implement** — Write the code following existing patterns and conventions.
4. **Write tests** — Unit tests for new logic, integration tests for new endpoints.
5. **Verify** — Run `go test ./...` and `go vet ./...` to confirm correctness.
6. **Refactor if needed** — Clean up duplication, improve naming, optimize.
7. **Commit logically** — One logical change per commit with conventional commit message.
8. **Update CHANGELOG** — Add an entry for the completed work.

**Never skip documentation.**
**Never skip testing.**
**Never continue to the next phase until the current phase is fully completed and verified.**

---

## Phase 1: Foundation Audit

### Subphases

#### 1.1 Inspect folder structure

- Walk `agent/` directory tree
- Document every package and its files
- Identify public vs internal APIs

#### 1.2 Identify completed features

- Map each endpoint to its handler
- Mark each as working, stubbed, or missing
- Verify each working endpoint returns correct structured JSON

#### 1.3 Identify incomplete modules

- List all stubbed endpoints
- List all TODO comments in the codebase
- Identify missing features from the roadmap

#### 1.4 Remove dead code only if safe

- Search for unused imports, dead functions, commented-out code
- Only remove if no side effects and no references exist
- Verify with `go vet` after removal

#### 1.5 Verify routing

- Confirm all routes in `server.go` match the API reference
- Check for route conflicts or ambiguous patterns
- Verify HTTP methods are correct

#### 1.6 Verify middleware

- Confirm middleware stack order is correct
- Verify auth middleware protects all sensitive routes
- Verify rate limiting is applied correctly
- Verify CORS headers are appropriate

#### 1.7 Verify authentication

- Test enroll → refresh → revoke flow end-to-end
- Verify token signing and validation
- Verify refresh token rotation
- Verify reuse detection

#### 1.8 Verify configuration

- Confirm all config fields have sensible defaults
- Verify YAML parsing works correctly
- Test config loading from file vs defaults

#### 1.9 Verify logging

- Confirm structured JSON logging to stdout
- Verify log levels work (debug, info, warn, error)
- Ensure no sensitive data is logged

#### 1.10 Verify database usage

- Agent uses no external database (file-backed JSON store)
- Verify auth store persistence is atomic
- Verify no database dependencies exist

#### 1.11 Verify Docker integration

- Test Docker socket connection
- Verify all container operations work
- Test graceful degradation when Docker is unavailable

#### 1.12 Verify server agent communication

- Test HTTP endpoints with valid and invalid tokens
- Test WebSocket connection and message routing
- Verify TLS handshake works
- Verify certificate fingerprint is correct

### Deliverable

A documented backend audit with current state assessment and roadmap.

---

## Phase 2: Core Infrastructure

### 2.1 Configuration

**Tasks:**
- [x] Config loader (`config.Load`)
- [x] Environment variables support
- [x] Validation
- [x] Defaults

**Verification:** `go test ./internal/config/...`

### 2.2 Logger

**Tasks:**
- [x] Structured logging (`log/slog`)
- [x] Log levels
- [x] Console logging (stdout JSON)
- [ ] File logging (add file handler option)

**Verification:** `go test ./...` and manual log output check

### 2.3 Middleware

**Tasks:**
- [x] Authentication (`authmw.go`)
- [x] Authorization (read-only mode)
- [x] Recovery (`middleware.go`)
- [x] Request logging (`middleware.go`)
- [x] Rate limiting (`ratelimit/ratelimit.go`)
- [ ] Validation (add request body validation helpers)

**Verification:** `go test ./internal/server/...`

### 2.4 Utilities

**Tasks:**
- [x] Error helpers (`respond.go`)
- [x] JSON responses (`respond.go`)
- [x] Time helpers (in handlers)
- [x] Encryption helpers (`auth/signer.go`)

**Verification:** `go test ./...`

### Deliverable

Stable backend foundation with all infrastructure in place.

---

## Phase 3: Authentication System

### Subphase: Enrollment

- [x] Token generation
- [x] Token validation
- [x] Device registration

### Subphase: Login

- [x] Authentication (enroll exchange)
- [x] Session validation (auth middleware)

### Subphase: Token Management

- [x] Refresh (token rotation)
- [x] Revocation (device revocation)

### Subphase: Device Management

- [x] Device IDs (random hex)
- [x] Device metadata (name, platform, timestamps)

### Deliverable

Complete authentication system with enroll, refresh, revoke, and device management.

---

## Phase 4: Server Communication

### Subphase: Heartbeat

- [x] `/status` endpoint

### Subphase: Status sync

- [x] `/metrics/latest` endpoint

### Subphase: Server metadata

- [x] Hostname, uptime, load via `host.Collector`

### Subphase: Connection status

- [x] WebSocket `/ws` endpoint

### Subphase: Reconnect logic

- [x] WS hub handles reconnects (client re-subscribes)

### Subphase: Timeout handling

- [x] HTTP server timeouts
- [x] WS read timeout

### Deliverable

Reliable communication between app and agent.

---

## Phase 5: System Monitoring

### Subphase: CPU

- [x] Usage
- [x] Per-core
- [x] Load average

### Subphase: Memory

- [x] RAM
- [x] Swap
- [ ] Cache
- [ ] Buffers

### Subphase: Disk

- [x] Partitions
- [x] Usage
- [ ] IO
- [x] Filesystem

### Subphase: Network

- [x] Upload
- [x] Download
- [ ] Interfaces (single interface currently)
- [x] Bandwidth
- [ ] Latency

### Subphase: Temperature

- [x] CPU
- [ ] Motherboard
- [ ] Drives

### Subphase: System

- [x] Hostname
- [ ] Kernel
- [ ] Architecture
- [ ] OS
- [x] Uptime
- [ ] Boot time
- [ ] Users
- [ ] Processes

### Deliverable

Complete system monitoring with all metrics exposed.

---

## Phase 6: Docker Integration

### Subphase: Container Discovery

- [x] List containers
- [x] Status
- [x] Health
- [ ] Labels
- [x] Ports
- [ ] Images

### Subphase: Container Actions

- [x] Start
- [x] Stop
- [x] Restart
- [x] Kill
- [x] Pause
- [x] Resume
- [x] Remove

### Subphase: Container Logs

- [x] Streaming
- [x] Filtering
- [x] Tail
- [ ] Search

### Subphase: Container Stats

- [x] CPU
- [x] RAM
- [ ] Network
- [ ] Disk IO
- [ ] PIDs

### Subphase: Images

- [ ] List
- [ ] Pull
- [ ] Delete
- [ ] Inspect

### Subphase: Volumes

- [ ] List
- [ ] Inspect

### Subphase: Networks

- [ ] List
- [ ] Inspect

### Deliverable

Complete Docker management.

---

## Phase 7: File Management

- [x] Browse
- [ ] Copy
- [x] Move
- [x] Delete
- [x] Rename
- [x] Upload
- [x] Download
- [ ] Permissions
- [ ] Search
- [ ] Favorites

### Deliverable

Remote file manager.

---

## Phase 8: Terminal

- [x] Secure terminal
- [x] Multiple sessions
- [x] Resize
- [ ] History
- [x] Disconnect handling
- [x] Command execution

### Deliverable

Web terminal.

---

## Phase 9: Notifications

- [x] Critical alerts
- [x] Warnings
- [x] Information
- [ ] Server offline
- [x] Container stopped
- [x] Disk full
- [x] High CPU
- [x] High RAM
- [ ] Network issues

### Deliverable

Notification engine.

---

## Phase 10: Live Updates

- [x] WebSocket
- [x] Realtime metrics
- [x] Realtime logs
- [x] Realtime status
- [x] Realtime notifications
- [x] Heartbeat updates

### Deliverable

Realtime backend.

---

## Phase 11: Security

- [x] Rate limiting
- [x] Encryption
- [x] HTTPS support
- [x] Secure tokens
- [ ] Input validation (enhance)
- [x] Output sanitization (docker inspect masking)
- [ ] Command restrictions
- [x] Audit logging

### Deliverable

Production-grade security.

---

## Phase 12: Performance

- [ ] Caching
- [ ] Connection pooling
- [ ] Memory optimization
- [ ] Concurrency improvements
- [ ] Profiling
- [ ] Benchmarking

### Deliverable

Optimized backend.

---

## Phase 13: Testing

### Unit tests

- [ ] Auth tests (expand coverage)
- [ ] Config tests
- [ ] Server tests (expand coverage)
- [ ] Host metrics tests
- [ ] Docker manager tests
- [ ] File manager tests
- [ ] Terminal manager tests
- [ ] Alerts engine tests
- [ ] Rate limiter tests

### Integration tests

- [ ] Docker socket integration
- [ ] PTY integration
- [ ] FS integration
- [ ] Auth e2e flow

### Endpoint tests

- [ ] All 31 endpoints tested

### Docker tests

- [ ] Docker build and run

### Stress tests

- [ ] Concurrent connections
- [ ] High metrics volume

### Regression tests

- [ ] Full suite regression

### Deliverable

High test coverage with all phases tested.

---

## Phase 14: Release Preparation

- [ ] Documentation review
- [ ] API documentation
- [ ] Versioning (semver, tag v1.0.0)
- [ ] Migration guide (N/A — v1 is initial)
- [ ] Release notes
- [ ] Packaging (binary, Docker image, install script)

### Deliverable

Backend v1.0 Release Candidate.