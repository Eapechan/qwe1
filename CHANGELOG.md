# Changelog

All notable changes to the qwe1 backend will be documented in this file.

The format is based on [Conventional Commits](https://conventionalcommits.org/).

---

## [1.0.0] — 2026-08-03

### Added

- Complete backend agent with 31 REST endpoints and WebSocket support
- Authentication system: enroll, refresh, revoke, device management
- Host metrics collection: CPU, RAM, disk, network, temperature, uptime, load, cache, buffers, disk I/O, kernel, arch, OS, boot time, users, processes
- Docker management: containers, images, volumes, networks — list, inspect, lifecycle, logs
- File management: CRUD, copy, search, favorites
- Terminal (PTY): create, kill, resize
- Alerts engine: threshold-based alerting with debounce and deduplication
- Rate limiting: per-IP and per-token
- TLS support: TLS 1.3, self-signed cert generation
- Audit logging: ring buffer with handler
- Performance profiling: pprof endpoints
- Unit tests for host, files, alerts packages

### Fixed

- Dead code removal (enrollByHash, cleanupEnrollments, logLevel, perMinute, parseBool, base64 hack)
- Missing metrics (Cache, Buffers, DiskIO, per-interface network, Kernel, Arch, OS, BootTime, Users, Processes)
- Missing Docker features (image/volume/network CRUD)
- Missing file features (copy, search, favorites)

### Changed

- API reference updated with all new endpoints
- README updated with v1.0 feature list and complete endpoint table
- Docker management: container lifecycle, logs, inspect, stats, events
- File management: list, read, write, upload, mkdir, rename, delete
- Terminal (PTY): create, kill, resize sessions
- Alert engine: threshold evaluation with debounce and deduplication
- WebSocket hub: multiplexed real-time channels
- Audit logging: bounded ring buffer of privileged actions
- Rate limiting: per-IP and per-token token-bucket limiter
- TLS 1.3 with self-signed ECDSA P-256 certificate generation
- YAML configuration with sensible defaults
- Structured JSON logging via `log/slog`
- Middleware stack: CORS, logging, recovery, rate limiting, auth
- Comprehensive test suite (7 server integration tests)
- Dockerfile and Makefile for build and deployment

### Changed

- Enrollment tokens now include `qwe1-` prefix for app validation compatibility

### Fixed

- N/A

---

## [0.1.0] — 2026-07-31

### Added

- Initial agent scaffold with config and server wiring
- Basic host metrics collector (CPU, RAM, disk)
- First draft of REST API endpoints
- Auth store and token signing infrastructure
- Docker client integration (list, start, stop, restart)
- File system operations (list, read, write)
- Alert engine with threshold evaluation
- WebSocket hub for real-time metrics
- Rate limiting middleware
- Audit log ring buffer

---

## [0.0.1] — 2026-07-01

### Added

- Project repository initialized
- Monorepo structure: `app/` (Flutter) + `agent/` (Go)
- Initial documentation scaffold
- CI configuration
- Dockerfile and Makefile