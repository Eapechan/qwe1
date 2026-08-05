# ChatGPT Context — qwe1 Session Summary

> Feed this file to ChatGPT to get up to speed on the project and the most
> recent session's work without re-reading the whole codebase.

## What is qwe1?

A privacy-first, self-hosted server-management app. No cloud.

```
Flutter App (phone) <-- HTTP/WebSocket --> Go Agent (your server) --> Docker API
```

- **`app/`** — Flutter (Android) app: dashboard, host metrics, Docker container
  management, file browser, alerts, terminal (UI stubbed).
- **`agent/`** — Go binary (`github.com/qwe1/qwe1/agent`) that runs on each
  user's Linux server. Exposes a REST API + WebSocket. Packages: `internal/`
  `auth`, `config`, `docker`, `host`, `terminal`, `files`, `alerts`,
  `ratelimit`, `audit`, `certs`, `server`.

Auth is QR-based enrollment: `run.sh` prints a `qwe1://enroll?...` QR
(`qwe1-agent --enroll`), the app scans it, exchanges the enrollment token via
`POST /auth/enroll` for access/refresh tokens. **This flow works and must not
be changed — never add manual access-token input.**

Environment notes:
- Dev machine is a Mac with **no Docker**; Flutter SDK at
  `/Users/binu/flutter/bin/flutter` (Dart/Flutter 3.19.6 — avoid newer Dart
  syntax). The real agent runs on a **separate Linux Xubuntu server with
  Docker**; the app connects from a phone.
- macOS is used for build / `flutter analyze` / `flutter test` / `go build` /
  `go vet` / `go test -race`. Docker integration tests must be skipped/mocked
  on macOS (no daemon).

---

## Goal of the session

The user's server showed **Docker containers and server metrics as not shown in
the app**, and the backend reported Docker capability as `false`. Task: audit,
find root causes, fix, add detailed startup logging, update docs, and keep the
QR enrollment/auth flow unchanged.

## Root causes found

1. **Docker "not available" / `docker:false`**
   `s.docker != nil` was the only signal for Docker capability. If the daemon
   wasn't ready when the agent started, it stayed broken forever — no retry, no
   diagnostics.

2. **Metrics not shown**
   Metrics relied *only* on the WebSocket stream; if WS never delivered, the
   dashboard was empty. Also, capabilities were not persisted at enrollment,
   and `ServerStatus.capabilities` was `Map<String, bool>`, which **crashes**
   the app when `caps` includes any non-bool value (the new `dockerSocket`
   string).

---

## What was changed

### Backend (Go)

- `agent/internal/docker/docker.go`
  - Structured `slog` logging.
  - `resolveSocket()` — expands `unix://`/`tcp://` prefixes; defaults to
    `/var/run/docker.sock`.
  - `Manager.Socket()` and `Available()` (non-nil client + 5s ping timeout).

- `agent/internal/server/server.go`
  - `dockerMu sync.RWMutex` protecting `s.docker` (background goroutine writes
    it; handlers read via accessors).
  - `retryDocker(ctx)` — background goroutine, 6 attempts, 5s apart, started in
    `Run()` when Docker is enabled but not ready at startup. Flipping
    `caps.docker` to `true` as soon as the daemon becomes reachable.
  - Accessors: `dockerAvailable()`, `dockerManager()`, `dockerSocketOrConfig()`.
  - Detailed startup logging in `New()` (listener scheme, host, port, auth
    store, metrics interval, docker, terminal, files, alerts, rate limits) and
    in `Run()` for every goroutine.

- `agent/internal/server/handlers.go`
  - `capabilities()` map now includes `dockerSocket` (a String diagnostic).
  - `handleStatus` and `/auth/me` both use it.
  - All `if s.docker == nil` replaced with the `m := s.dockerManager();
    if m == nil { ... }` guard (returns 503 `DOCKER_UNAVAILABLE`), and all
    `s.docker.X` replaced with `m.X`.

- `agent/internal/server/server_test.go` — new tests:
  - `TestCapabilitiesReported` — `/status` and `/auth/me` carry `caps` with
    `docker` (bool) + `dockerSocket` (string) + `terminal`/`files`/`tempSensors`.
  - `TestDockerContainersUnavailable` — `/docker/containers` returns 503
    `DOCKER_UNAVAILABLE` with Docker disabled (macOS-safe).

- Fixed a logging unit bug: `intervalSec=5ns` → `5` (Duration division yields a
  Duration; cast to `int`).

### Flutter app

- `app/lib/domain/repositories/server_repository.dart`
  - `ServerStatus.capabilities` is now `Map<String, dynamic>` (was
    `Map<String, bool>`).

- `app/lib/data/repositories/server_repository_impl.dart`
  - `getStatus` parses caps via `Map<String, dynamic>.from(...)`.
  - `addServer` fetches capabilities from `/auth/me` after enrollment and
    persists to `capsJson` (`'{}'` when empty — column is non-nullable).
  - `watchMetrics` rewritten: keeps the WS channel, but adds
    `_startMetricsPolling` — a guaranteed **5s HTTP polling baseline** of
    `GET /metrics/latest`. WS JSON parsing wrapped in try/catch. Polling timer
    cancelled via `controller.onCancel` (cleans up `_metricsControllers`).

- `app/lib/state/servers/server_provider.dart`
  - `_pingStatus` uses `repository.getStatus()` and copies capabilities.
  - `refreshStatuses` persists the server when status **or** capabilities
    change (added `_sameCapabilities`).

- `app/lib/ui/screens/container_list_screen.dart`
  - Friendly "Docker is not available" empty state when the error is
    `ServerUnavailableException` (503 → capability gating); generic error
    otherwise.

- `app/lib/ui/screens/server_detail_screen.dart`
  - Network ↓/↑ metric cards (`_formatBytes`, `_getNetColor`).
  - `_buildMetricsError` includes a retry button via
    `ref.invalidate(serverMetricsProvider(serverId))`.

### Docs

- `README.md` — Docker retry + metrics WS/HTTP-fallback notes.
- `GETTING_STARTED.md` — updated `/status` response shape (incl. `dockerSocket`),
  "Docker is not available" troubleshooting section, metrics fallback note.
- `BACKEND_ROADMAP.md` — fixed `backei f#` heading typo, updated Docker
  resilience note, Phase 10 HTTP-fallback line, test count 7 → 9.

---

## Verification (all on macOS, all passing)

- `go build ./...`, `go vet ./...`, `go test ./...` — pass.
- `go test -race ./...` — pass (incl. new server tests).
- `flutter analyze` (app/) — no errors/warnings introduced. Remaining are
  pre-existing info-level style lints plus two documented warnings:
  unused `dart:io` import in `app/lib/core/utils/qr_enrollment.dart:1` and
  unused `go_router` import in `app/lib/ui/screens/qr_scan_screen.dart:3`.
- `flutter test` — pass.

## Still to do

- **Real runtime verification on the Linux Docker server** (separate device):
  deploy the updated agent, confirm `/status` reports `docker:true` and
  `/docker/containers` returns real containers, then confirm the app shows
  containers + live metrics.

## Key invariants / gotchas

- QR-based enrollment/auth flow works — **do not change it**, no manual token
  input.
- Capability map intentionally includes `dockerSocket` (String) — Flutter must
  tolerate non-bool values (`Map<String, dynamic>`).
- Background Docker retry goroutine writes `s.docker` under `sync.RWMutex`;
  handlers must use `dockerAvailable()`/`dockerManager()`, never read
  `s.docker` directly.
- `app/lib/screens/server_detail_screen.dart` uses `serverId` field, not
  `widget.serverId` (ConsumerWidget has no `widget`).
- Metrics entity: `HostInfo.sensors` is `List<TempSensor>`; `NetworkMetrics`
  has `rxBytesPerSec`, `txBytesPerSec`.
- `config.yaml`: Docker enabled, socket `/var/run/docker.sock`, metricsInterval
  5, listen port 9443 plain HTTP.
- `build.md` in the repo was truncated to one line **before** this session
  (pre-existing local change) — not part of this work.

## Useful commands

```bash
# Backend
cd agent && go build ./... && go vet ./... && go test -race ./...

# Flutter
export PATH="$PATH:/Users/binu/flutter/bin"
cd app && flutter analyze && flutter test

# Android APK (needs JAVA_HOME)
export JAVA_HOME=~/java/current
cd app && flutter build apk --debug

# Run the agent on the Linux server
./run.sh
./run.sh --foreground   # foreground, streams logs
```
