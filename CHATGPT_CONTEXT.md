# ChatGPT Context — qwe1 Project Summary

> Feed this file to ChatGPT to get up to speed on the project and its
> current state without re-reading the whole codebase.

## What is qwe1?

A privacy-first, self-hosted server-management app. No cloud.

```
Flutter App (phone) <-- HTTP/WebSocket --> Go Agent (your server) --> Docker API
```

- **`app/`** — Flutter (Android) app: dashboard, host metrics, Docker container
  management, file browser, alerts, terminal (UI stubbed).
- **`agent/`** — Go binary (`github.com/qwe1/qwe1/agent`) that runs on each
  user's Linux server. Exposes a REST API + WebSocket.
- **`tools/`** — Development scripts (build, enroll, diagnose).
- **`docs/`** — Long-form documentation.

## Repository Structure

```
qwe1/
├── agent/
│   ├── cmd/
│   │   └── qwe1-agent/
│   │       └── main.go
│   ├── config/
│   │   ├── config.go
│   │   └── config_test.go
│   ├── internal/
│   │   ├── alerts/
│   │   ├── audit/
│   │   ├── auth/
│   │   ├── certs/
│   │   ├── docker/
│   │   ├── files/
│   │   ├── host/
│   │   ├── ratelimit/
│   │   ├── server/
│   │   └── terminal/
│   ├── Dockerfile
│   ├── go.mod
│   └── go.sum
├── app/
│   └── (Flutter application)
├── tools/
│   ├── development.sh
│   ├── enroll.sh
│   └── diagnose.sh
├── docs/
│   ├── GETTING_STARTED.md
│   ├── BACKEND_ROADMAP.md
│   ├── report.md
│   └── REFACTOR.md
├── assets/
│   └── branding/
│       └── logo.svg
├── README.md
├── config.yaml
├── config.example.yaml
└── .github/
    └── workflows/
        ├── ci-agent.yml
        ├── ci-app.yml
        ├── release.yml
        └── security.yml
```

## Key Invariants

- **QR-based enrollment/auth flow works** — do not change it, no manual token input.
- **Capability map** intentionally includes `dockerSocket` (String) — Flutter must tolerate non-bool values (`Map<String, dynamic>`).
- **Background Docker retry goroutine** writes `s.docker` under `sync.RWMutex`; handlers must use `dockerAvailable()`/`dockerManager()`, never read `s.docker` directly.
- **Dev machine** is macOS (no Docker); **production** is Linux Xubuntu with Docker.
- **Never require Docker on macOS**; Docker validation only on Linux.

## Scripts

### `tools/development.sh`
Builds the Go agent, verifies config, starts the agent, and runs health checks:
- Builds agent binary (skips if current)
- Verifies config exists (creates minimal HTTP config if missing)
- Checks port availability
- Stops any stale agent process
- Starts the agent
- Verifies `/status`, `/metrics/latest`, WebSocket `/ws` endpoints
- On Linux only: verifies Docker socket and container listing
- Prints colored PASS/FAIL summary
- Fails fast with human-readable error messages

### `tools/enroll.sh`
Generates a new enrollment token and QR code:
- Ensures config exists
- Starts the agent if not already running
- Generates enrollment token via `--enroll` flag
- Generates both ASCII QR and PNG QR (`enroll-qr.png`)
- Prints LAN URL, Tailscale URL, token, and expiry
- Verifies agent is responding on `/status`

### `tools/diagnose.sh`
Comprehensive 16-point health check covering Go installation, agent binary,
config, port, /status, /metrics/latest, WebSocket, Docker (Linux only),
Tailscale, LAN IP, disk usage, memory, firewall, running processes, and
enrollment system. Prints `✓ PASS`, `⚠ WARNING`, or `✗ FAIL` with fixes.

## Auth Flow (QR Enrollment)

1. Server generates enrollment token via `./tools/enroll.sh` or `qwe1-agent --enroll`
2. Token is embedded in QR code payload (`qwe1://enroll?...`)
3. Phone scans QR code
4. App calls `POST /auth/enroll` with the token
5. App receives access + refresh tokens
6. Tokens are stored securely on the phone
7. App fetches server status and capabilities

No manual token entry. QR enrollment is the only pairing method.

## Recent Major Refactor (commit 568235f)

### Repository Structure
- Moved docs (GETTING_STARTED.md, BACKEND_ROADMAP.md, report.md) → `docs/`
- Moved `agent/internal/config/` → `agent/config/` (simplify import paths)
- Removed `run.sh` (replaced by tools/ scripts)
- Created `tools/` with three scripts
- Created `docs/REFACTOR.md` with full change log

### Backend Cleanup
- Removed dead code across 12 Go files (auth, audit, docker, files, host, ratelimit, server, terminal)
- Fixed `m.Users` bug in host.go, wired TemperaturePath
- Simplified `detectLanIP`/`detectTailscaleIP` via shared helper
- Replaced handrolled `splitString`/`trimSpace` with stdlib
- Fixed `intervalSec` log unit bug (`5ns` → `5`)
- Kept alerts, terminal, audit packages as requested (disabled, not deleted)

### CI Workflows
- Fixed Go version 1.22 → 1.25 in ci-agent.yml, release.yml, security.yml
- Removed broken `contract.yml` (referenced nonexistent `api/openapi.yaml`)
- Removed `api/**` path references from ci-agent.yml, ci-app.yml
- Created `agent/.goreleaser.yaml`

### Verification
- `go build ./...` ✓
- `go vet ./...` ✓
- `go test -race ./...` ✓
- `flutter analyze` ✓ (0 errors, 2 pre-existing warnings)
- `flutter test` ✓ (all pass)

## Environment Notes

- Dev machine: macOS, no Docker; Flutter SDK at `/Users/binu/flutter/bin/` (Dart/Flutter 3.19.6)
- Production: Linux Xubuntu server with Docker
- macOS used for build / `flutter analyze` / `flutter test` / `go build` / `go vet` / `go test -race`
- Docker integration tests must be skipped/mocked on macOS (no daemon)

## Useful Commands

```bash
# Backend
cd agent && go build ./... && go vet ./... && go test -race ./...

# Flutter
export PATH="$PATH:/Users/binu/flutter/bin"
cd app && flutter analyze && flutter test

# Android APK (needs JAVA_HOME)
export JAVA_HOME=~/java/current
cd app && flutter build apk --debug

# Development (Linux server)
./tools/development.sh

# Generate enrollment QR
./tools/enroll.sh

# Full health diagnostic
./tools/diagnose.sh
```

## Pre-existing Warnings (not from this session)

- Unused `dart:io` import in `app/lib/core/utils/qr_enrollment.dart:1`
- Unused `go_router` import in `app/lib/ui/screens/qr_scan_screen.dart:3`

## Pre-existing Files (not from this session)

- `build.md` — was a corrupted 3-byte file (`/co`), now deleted
- `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` — standard project docs at root