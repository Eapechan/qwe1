# qwe1 Refactor & Cleanup Report

This document describes every change made during the qwe1 repository cleanup and refactor.

## New Repository Structure

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

## Files Moved

| File | From | To | Reason |
|------|------|----|--------|
| `GETTING_STARTED.md` | Root | `docs/` | Long documentation belongs in docs/ |
| `BACKEND_ROADMAP.md` | Root | `docs/` | Long documentation belongs in docs/ |
| `report.md` | Root | `docs/` | Historical troubleshooting report moved to docs/ |
| `agent/internal/config/config.go` | `agent/internal/config/` | `agent/config/` | Simplify import path; config is a top-level concern |
| `agent/internal/config/config_test.go` | `agent/internal/config/` | `agent/config/` | Same as above |

## Files Removed

### Build artifacts (gitignored, cleaned from working tree)
| File | Reason |
|------|--------|
| `agent/bin/qwe1-agent` | Pre-built binary artifact |
| `agent/bin/qwe1-agent-linux` | Pre-built binary artifact |
| `agent/qwe1-agent` | Pre-built binary artifact |
| `*.auth.json` (root-level) | Runtime auth state; gitignored |
| `agent.log` | Runtime log; gitignored |
| `enroll-qr.png` | Generated QR artifact |

### Obsolete scripts
| File | Reason |
|------|--------|
| `run.sh` | Replaced by `tools/development.sh`, `tools/enroll.sh`, and `tools/diagnose.sh` |

### Broken CI workflow
| File | Reason |
|------|--------|
| `.github/workflows/contract.yml` | Referenced non-existent `api/openapi.yaml` and `api/` directory; never triggered |

### CI fixes applied
| File | Change |
|------|--------|
| `.github/workflows/ci-agent.yml` | Go version 1.22 → 1.25; removed `api/**` path references |
| `.github/workflows/ci-app.yml` | Removed `api/**` path references |
| `.github/workflows/release.yml` | Go version 1.22 → 1.25 |
| `.github/workflows/security.yml` | Go version 1.22 → 1.25 |

### Go backend — dead code removed
| File | What was removed | Reason |
|------|-----------------|--------|
| `agent/internal/auth/attempts.go` | `AttemptTracker` type and all methods | Zero callers; brute-force lockout feature never wired |
| `agent/internal/auth/signer.go` | `Signer.Secret()` method | Never called anywhere |
| `agent/internal/auth/store.go` | `NeedsPersist`, `MarkPersisted`, `SetSignerSecret`, `ValidateAccess`, `AccessClaims`, `RotateRefresh` (non-atomic), `MarkRefreshUsed`, `RevokeAll`, `Devices` | All dead; only `RotateRefreshAtomic` and core methods are used |
| `agent/internal/audit/audit.go` | `Log.Record`, `Log.List` | `Server.audit()` never called; audit subsystem is inert |
| `agent/internal/docker/docker.go` | `StreamEvents`, `Event`, `Close`, `Kill`, `annotateStats`, `cpuPercent`, `withStats` code path | Never called; `Container.CPUPercent`/`MemoryBytes` fields only populated by dead code |
| `agent/internal/files/files.go` | `Manager.Stat`, `Manager.Roots`, `ErrInvalidName`, entire `Favorites` block (type + all methods) | Zero callers; favorites/bookmarks feature unimplemented |
| `agent/internal/host/host.go` | `HasTempSensors` method | Only used in tests; capability reporting never calls it |
| `agent/internal/host/host.go` | Fixed `m.Users = int(hi.Procs)` bug | `Procs` is process count, not user count; duplicated `m.Processes` field |
| `agent/internal/ratelimit/ratelimit.go` | `Limiter.Cleanup` method | Never scheduled; would cause unbounded memory growth if called |
| `agent/internal/server/authmw.go` | `randID()` function | Zero callers |
| `agent/internal/server/server.go` | `Server.rateLimit` field + its `New(300/60, 10)` ctor call | Dead global limiter; only per-token and per-IP limiters are used |
| `agent/internal/server/server.go` | `if ticker == nil` dead guard | `time.NewTicker` never returns nil |
| `agent/internal/server/types.go` | `hostMetricsJSON`, `dockerLogLineJSON`, `thresholdJSON`, `alertsThreshold` type aliases | Never referenced anywhere |
| `agent/internal/server/handlers.go` | `handleAudit` (GET /audit) | Stub returning empty; app never calls it |
| `agent/internal/server/handlers.go` | `handleMetricsHistory` (GET /metrics/history) | Stub returning empty; app never calls it |
| `agent/internal/server/handlers.go` | `handleAlertThresholds` (GET /alerts/thresholds) | Stub returning empty; app never calls it |
| `agent/internal/server/handlers.go` | `handleAlertThresholdsUpdate` (PUT /alerts/thresholds) | Stub no-op; app never calls it |
| `agent/internal/terminal/terminal.go` | `Get`, `KillAll`, `Sweep`, `Attach`, `Detach`, `Input`, `Resize`, `Out`, `Done`, `LastActive`, `ErrClosed` | Zero production callers; WS never wires terminal sessions |
| `agent/internal/server/ws.go` | `splitString`, `trimSpace` handrolled helpers | Replaced with `strings.Split` / `strings.TrimSpace` from stdlib |

### Go backend — code fixed (not removed)
| File | Change | Reason |
|------|--------|--------|
| `agent/internal/server/server.go` | Fixed `intervalSec` log unit bug (`5ns` → `5`) | Duration division yielded `time.Duration` instead of `int` |
| `agent/internal/server/server.go` | Wired `TemperaturePath` into `readTemps` | Config field was unused at runtime |
| `agent/cmd/qwe1-agent/main.go` | Extracted shared `firstIPv4` helper for `detectLanIP`/`detectTailscaleIP` | ~35 lines of duplicated logic |
| `agent/internal/server/server.go` | Removed dead `readOnly` code path | No config field ever sets it; read-only mode can never be enabled |

### Flutter app — dead code removed
| File | What was removed | Reason |
|------|-----------------|--------|
| `app/lib/core/utils/units.dart` | All 8 helper functions | All wrapped by `Formatters`; zero imports |
| `app/lib/data/models/server_dto.dart` + `.g.dart` | DTO + generated code | Converters duplicated inline in `server_repository_impl.dart`; never imported |
| `app/lib/data/models/alert_dto.dart` + `.g.dart` | DTO + generated code | Severity mapping duplicated in `alert_repository_impl.dart`; never imported |
| `app/lib/domain/repositories/auth_repository.dart` | Interface only (no impl) | No implementation exists; only referenced by a test fake |

### Flutter app — dead providers removed
| Provider | File | Reason |
|----------|------|--------|
| `serverStatusProvider` | `server_provider.dart` | Never consumed by any widget |
| `fileContentProvider` | `file_provider.dart` | Never consumed by any widget |
| `alertThresholdProvider`, `alertStreamProvider`, `unacknowledgedAlertCountProvider`, `globalUnacknowledgedAlertCountProvider` | `alert_provider.dart` | Never consumed by any widget |
| `activeTerminalProvider`, `terminalOutputProvider` | `terminal_provider.dart` | Never consumed by any widget |
| `containerInspectProvider`, `containerLogsProvider` | `container_provider.dart` | Never consumed by any widget |
| `biometricEnabledProvider`, `readOnlyModeProvider` | `settings_provider.dart` | Written but never read anywhere |

### Flutter app — unused pubspec dependencies removed
| Dependency | Reason |
|-----------|--------|
| `riverpod_annotation` | Unused |
| `fl_chart` | Unused |
| `local_auth` | Unused |
| `flutter_local_notifications` | Unused |
| `permission_handler` | Unused |
| `share_plus` | Unused |
| `collection` | Unused |
| `crypto` | Unused |
| `flutter_localizations` | No l10n infrastructure exists |
| `mocktail` (dev) | Unused |
| `golden_toolkit` (dev) | Unused |

## New Scripts

### `tools/development.sh`
Builds the Go agent, verifies config, starts the agent, and runs health checks:
- Builds agent binary (skips if current)
- Verifies config exists (creates minimal HTTP config if missing)
- Checks port availability
- Stops any stale agent process
- Starts the agent
- Verifies `/status` endpoint
- Verifies `/metrics/latest` endpoint
- Verifies WebSocket `/ws` endpoint
- On Linux only: verifies Docker socket and container listing
- Verifies enrollment QR code exists
- Prints colored PASS/FAIL summary
- Fails fast with human-readable error messages for common problems

### `tools/enroll.sh`
Generates a new enrollment token and QR code:
- Ensures config exists
- Starts the agent if not already running
- Generates enrollment token via `--enroll` flag
- Generates both ASCII QR and PNG QR (`enroll-qr.png`)
- Prints LAN URL, Tailscale URL, token, and expiry
- Verifies agent is responding on `/status`

### `tools/diagnose.sh`
Comprehensive health check covering 16 checks:
1. Go installation
2. Agent binary
3. Config file
4. Port availability
5. `/status` endpoint
6. `/metrics/latest` endpoint
7. WebSocket `/ws` endpoint
8. Docker availability (Linux only)
9. Docker socket
10. Tailscale
11. LAN IP
12. Disk usage
13. Memory
14. Firewall
15. Running processes
16. Enrollment system / QR generation

Each check prints `✓ PASS`, `⚠ WARNING`, or `✗ FAIL` with suggested fixes.

## How to Use the New Scripts

### Start development environment
```bash
./tools/development.sh
```
This builds the agent, starts it, and runs all health checks.

### Stop the agent
```bash
./tools/development.sh stop
```

### Restart the agent
```bash
./tools/development.sh restart
```

### Generate enrollment QR code
```bash
./tools/enroll.sh
```

### Run full health diagnostic
```bash
./tools/diagnose.sh
```

## Linux Workflow (Production Server)

1. SSH into your Linux server
2. Clone the repo: `git clone https://github.com/Eapechan/qwe1.git`
3. Start the development environment: `./tools/development.sh`
4. Generate enrollment QR: `./tools/enroll.sh`
5. Scan the QR code with the qwe1 app on your phone
6. The app will enroll automatically and receive access/refresh tokens

## macOS Workflow (Development Machine)

1. Clone the repo: `git clone https://github.com/Eapechan/qwe1.git`
2. Start the development environment: `./tools/development.sh`
3. Docker validation is automatically skipped on macOS
4. Generate enrollment QR: `./tools/enroll.sh`
5. Scan the QR code with the qwe1 app on your phone

## Verification Results

All verification commands pass:
- `go build ./...` — passes
- `go vet ./...` — passes
- `go test -race ./...` — passes (including new tests for capabilities and Docker-unavailable 503)
- `flutter analyze` — no errors or warnings introduced (only pre-existing info lints)
- `flutter test` — all tests pass

## QR Enrollment Flow — Unchanged

The QR enrollment flow remains exactly as it was:
1. Server generates enrollment token via `--enroll` flag
2. Token is embedded in QR code payload (`qwe1://enroll?...`)
3. Phone scans QR code
4. App calls `POST /auth/enroll` with the token
5. App receives access + refresh tokens
6. Tokens are stored securely on the phone
7. App fetches server status and capabilities

No manual token entry was added or modified.
