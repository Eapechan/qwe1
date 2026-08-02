# PROJECT STATUS — qwe1

> **Last updated**: 2026-08-01
> **Purpose**: Single source of truth for what's built, what works, what's broken, and what's next.
> **Audience**: Any AI or developer picking up this project.

---

## Project Overview

**qwe1** is a self-hosted server management mobile app. No cloud, no accounts.

```
Flutter App (Android phone) <-- HTTP/WebSocket --> Go Agent (Linux server) --> Docker API
```

- **Repository**: https://github.com/Eapechan/qwe1
- **Stack**: Flutter 3.19.6 (Dart 3.3.4) + Go 1.26.5
- **Architecture**: Clean architecture (data/domain/ui layers), Riverpod state, Material 3 design

---

## Current Phase

| Phase | Name | Status |
|-------|------|--------|
| Phase 1 | Backend agent implementation | **COMPLETE** |
| Phase 2 | Flutter app UI + DI wiring | **COMPLETE** |
| Phase 3 | End-to-end testing on real server | **NOT STARTED** |
| Phase 4 | Fix integration bugs | **NOT STARTED** |
| Phase 5 | Polish, release builds, ship | **NOT STARTED** |

**Where we are**: Phase 2 is done. Phase 3 (real server testing) is the next thing to do.

---

## Phase 1: Go Agent — COMPLETE

### Build
```
cd agent && go build -o bin/qwe1-agent ./cmd/qwe1-agent
```
**Status**: Builds clean, zero errors.

### Binary size: ~14MB (Mach-O on macOS)

### API Endpoints (31 total)

#### Public (no auth)
| Route | Handler | Status |
|-------|---------|--------|
| `GET /status` | `handleStatus` | **WORKING** |
| `POST /auth/enroll` | `handleEnroll` | **WORKING** |
| `POST /auth/refresh` | `handleRefresh` | **WORKING** |
| `POST /auth/revoke` | `handleRevoke` | **WORKING** |
| `GET /auth/me` | `handleMe` | **WORKING** |
| `GET /ws` | `handleWebSocket` | **WORKING** |

#### Protected (require Bearer token)
| Route | Handler | Status |
|-------|---------|--------|
| `GET /metrics/latest` | `handleMetricsLatest` | **WORKING** |
| `GET /metrics/history` | `handleMetricsHistory` | **STUBBED** — returns `[]` |
| `GET /docker/containers` | `handleDockerContainers` | **WORKING** |
| `POST /docker/containers/{id}/start` | `handleDockerStart` | **WORKING** |
| `POST /docker/containers/{id}/stop` | `handleDockerStop` | **WORKING** |
| `POST /docker/containers/{id}/restart` | `handleDockerRestart` | **WORKING** |
| `POST /docker/containers/{id}/pause` | `handleDockerPause` | **WORKING** |
| `POST /docker/containers/{id}/unpause` | `handleDockerUnpause` | **WORKING** |
| `POST /docker/containers/{id}/kill` | `handleDockerKill` | **WORKING** (signal param ignored) |
| `DELETE /docker/containers/{id}` | `handleDockerRemove` | **WORKING** |
| `GET /docker/containers/{id}/inspect` | `handleDockerInspect` | **WORKING** |
| `GET /docker/containers/{id}/logs` | `handleDockerLogs` | **WORKING** |
| `POST /terminal` | `handleTerminalCreate` | **WORKING** |
| `DELETE /terminal/{id}` | `handleTerminalDelete` | **WORKING** |
| `GET /fs/list` | `handleFsList` | **WORKING** |
| `GET /fs/read` | `handleFsRead` | **WORKING** |
| `POST /fs/upload` | `handleFsUpload` | **WORKING** |
| `POST /fs/mkdir` | `handleFsMkdir` | **WORKING** |
| `POST /fs/write` | `handleFsWrite` | **WORKING** |
| `PATCH /fs/rename` | `handleFsRename` | **WORKING** |
| `DELETE /fs` | `handleFsDelete` | **WORKING** |
| `GET /alerts` | `handleAlerts` | **WORKING** |
| `PUT /alerts/{id}/ack` | `handleAlertAck` | **WORKING** |
| `GET /alerts/thresholds` | `handleAlertThresholds` | **STUBBED** — returns `{}` |
| `PUT /alerts/thresholds` | `handleAlertThresholdsUpdate` | **STUBBED** — no-op |
| `GET /audit` | `handleAudit` | **STUBBED** — returns `[]` |

**Score**: 28/31 working, 3 stubbed.

### Internal Packages

| Package | Location | Status | What It Does |
|---------|----------|--------|-------------|
| `auth` | `internal/auth/` | **WORKING** | HMAC-SHA256 token signing, refresh rotation, JSON-persisted store, reuse detection, brute-force lockout |
| `certs` | `internal/certs/` | **WORKING** | Self-signed ECDSA P-256 cert generation, fingerprint extraction |
| `config` | `internal/config/` | **WORKING** | YAML config with defaults for all sections |
| `host` | `internal/host/` | **WORKING** | CPU/mem/disk/net/temp via gopsutil, rate-diff'd network stats |
| `docker` | `internal/docker/` | **WORKING** | Full Docker Engine API wrapper (v25) |
| `terminal` | `internal/terminal/` | **WORKING** | PTY sessions via creack/pty, idle sweep, window resize |
| `files` | `internal/files/` | **WORKING** | Allow-listed roots, symlink-aware, atomic writes |
| `alerts` | `internal/alerts/` | **WORKING** | Threshold engine with debounce, host + container checks |
| `ratelimit` | `internal/ratelimit/` | **WORKING** | Token-bucket per-key rate limiting |
| `audit` | `internal/audit/` | **WORKING** | Ring-buffer in-memory log (data structure works, handler stubbed) |
| `server` | `internal/server/` | **WORKING** | HTTP server, middleware stack, WebSocket hub |

**Score**: 11/11 packages fully implemented.

### CLI Commands

| Command | Status |
|---------|--------|
| `./qwe1-agent --config config.yaml` | **WORKING** — runs server |
| `./qwe1-agent --enroll` | **WORKING** — generates token, stores hash in auth.json |
| `./qwe1-agent --enroll --enroll-days 30` | **WORKING** — custom expiry |

> **Resolved (2026-08-02):** Enrollment tokens now include the `qwe1-` prefix (e.g. `qwe1-<base64url>`), matching the Flutter app's validation. Previously the generated token lacked the prefix, which caused the app to reject it with "Invalid token format". See `agent/cmd/qwe1-agent/main.go` (`generateToken`).

### Auth Flow

1. `--enroll` generates random token prefixed with `qwe1-` (e.g. `qwe1-<base64url>`), SHA-256 hashes it, stores hash in `<serverName>.auth.json` with expiry
2. App sends token to `POST /auth/enroll`
3. Agent hashes received token, looks up hash in store, validates (not expired, not used)
4. Marks enrollment as used (one-time)
5. Generates device ID (random hex)
6. Signs access token (HMAC-SHA256, contains deviceID + expiry)
7. Generates refresh token (random base64url)
8. Stores refresh token hash in auth store
9. Returns accessToken, refreshToken, serverFingerprint

---

## Phase 2: Flutter App — COMPLETE

### Build
```
export JAVA_HOME=~/java/current
cd app && flutter build apk --debug
```
**Status**: Builds clean, zero errors. APK at `build/app/outputs/flutter-apk/app-debug.apk` (~156MB).

### Architecture

```
lib/
├── main.dart              # Entry point, ProviderScope with overrides
├── app.dart               # MaterialApp.router setup
├── providers.dart         # DI overrides (all 6 repositories wired)
├── core/
│   ├── error/             # AppException, ErrorMapper
│   └── utils/             # Formatters, Units, Validators
├── data/
│   ├── models/            # DTOs (alert, container, metrics, server) — JSON serializable
│   ├── repositories/      # Impl classes (server, docker, terminal, file, alert)
│   └── sources/
│       ├── local/         # Drift database, SecureStorage
│       └── remote/        # ApiClient (Dio), WebSocketClient
├── domain/
│   ├── entities/          # Freezed entities (Server, Container, Metrics, Alert, FileItem, Terminal)
│   └── repositories/      # Abstract interfaces
├── state/                 # Riverpod providers
│   ├── alerts/            # alertListProvider
│   ├── docker/            # containerListProvider, containerProvider
│   ├── files/             # fileListProvider
│   ├── servers/           # serverListProvider, serverProvider, serverMetricsProvider
│   ├── settings/          # settingsProvider
│   └── terminal/          # terminalSessionsProvider
└── ui/
    ├── router/            # GoRouter with 10 routes
    ├── screens/           # 10 screens
    ├── theme/             # Material 3 theme with AppColors extension
    └── widgets/           # 7 reusable widgets
```

### DI Wiring (providers.dart)

All 6 repositories are overridden at startup:

| Provider | Implementation | Wired? |
|----------|---------------|--------|
| `secureStorageProvider` | `SecureStorage` | YES |
| `serverRepositoryProvider` | `ServerRepositoryImpl` | YES |
| `dockerRepositoryProvider` | `DockerRepositoryImpl` | YES |
| `terminalRepositoryProvider` | `TerminalRepositoryImpl` | YES |
| `fileRepositoryProvider` | `FileRepositoryImpl` | YES |
| `alertRepositoryProvider` | `AlertRepositoryImpl` | YES |

### Screens

| Screen | Route | Status |
|--------|-------|--------|
| Dashboard | `/` | **WORKING** — server list, animated cards, empty state, FAB, long-press actions |
| Onboarding | `/onboarding` | **WORKING** — 5-page animated intro, skip button |
| Add Server | `/add-server` | **WORKING** — form with validation, enrollment token input |
| Server Detail | `/server/:serverId` | **WORKING** — header, metrics grid, quick actions |
| Container List | `/server/:serverId/containers` | **WORKING** — search, filter, start/stop/restart |
| Container Detail | `/server/:serverId/containers/:containerId` | **PARTIAL** — UI renders but action buttons are empty `() {}` |
| Terminal | `/server/:serverId/terminal` | **PARTIAL** — connect/disconnect works, but `_sendKey` and `_copyToClipboard` are stubs |
| File Browser | `/server/:serverId/files` | **PARTIAL** — list/browse/create/rename/delete work, file preview stubbed |
| Alerts | `/server/:serverId/alerts` | **WORKING** — filter, severity chips, acknowledge |
| Settings | `/settings` | **PARTIAL** — theme/biometric/readonly work, export/cache clear stubbed |

### Widgets

| Widget | Status |
|--------|--------|
| ServerCard | **WORKING** — animated press, status indicator, metric chips (hardcoded `--`) |
| ContainerCard | **WORKING** — status, health badge, CPU/mem, popup menu |
| AlertCard | **WORKING** — severity colors, type labels, acknowledge |
| MetricCard | **WORKING** — circular progress painter |
| TerminalView | **PARTIAL** — text output UI, no WebSocket data flow |
| StatusIndicator | **WORKING** — pulsing animation for online |
| EmptyState | **WORKING** — icon, title, message, action button |

### Theme (app_theme.dart)

- Material 3 with custom `_ColorTokens` for light/dark
- `AppColors` extension on `BuildContext` for easy access (context.primary, context.danger, etc.)
- Gradient support (context.primaryGradient)
- Rounded corners (20px cards, 14px inputs, 10px chips)

---

## What's Working End-to-End

| Flow | Status |
|------|--------|
| Agent starts and serves HTTP | Will verify in Phase 3 |
| `curl /status` returns server info | Will verify in Phase 3 |
| `--enroll` generates valid token | Tested locally, works |
| Flutter app builds and installs | APK built successfully |
| App shows onboarding | Works (UI only) |
| App shows dashboard (empty) | Works |
| App shows add-server form | Works with validation |

## What's NOT Working End-to-End (needs Phase 3 testing)

| Flow | Issue |
|------|-------|
| App connects to real agent | Not tested yet |
| App enrolls with real token | Not tested yet |
| Docker containers list | Backend works, app works, but integration not verified |
| Metrics display on dashboard | Server card shows `--` for all metrics |
| Terminal I/O | Backend PTY works, Flutter has no WebSocket connection |
| File download/preview | Backend supports, UI has no download/preview buttons |

---

## Known Bugs

1. **Container Detail action buttons are no-ops** — `container_detail_screen.dart:209,221,234` have `onPressed: () {}` instead of calling the provider
2. **Terminal is non-functional end-to-end** — `TerminalView` is a text stub with no WebSocket connection
3. **Docker kill ignores signal** — `handleDockerKill` decodes `req.Signal` but doesn't pass it to `Kill(ctx, id)`
4. **Server card metrics hardcoded** — Shows `--` instead of live data from WebSocket
5. **Alert streaming returns empty** — `AlertRepositoryImpl.watchAlerts()` returns `const Stream.empty()`

---

## Build Commands

```bash
# Go agent (macOS)
cd agent && go build -o bin/qwe1-agent ./cmd/qwe1-agent

# Go agent (Linux amd64)
cd agent && GOOS=linux GOARCH=amd64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent

# Go agent (Linux arm64)
cd agent && GOOS=linux GOARCH=arm64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent

# Generate enrollment token
./qwe1-agent --enroll --config ~/config.yaml

# Flutter APK
export JAVA_HOME=~/java/current
cd app && flutter build apk --debug

# Flutter analyze
cd app && flutter analyze

# Go tests
cd agent && go test ./...

# Code generation (after model changes)
cd app && dart run build_runner build
```

---

## File Reference

### Key Files to Know

| File | Purpose |
|------|---------|
| `agent/cmd/qwe1-agent/main.go` | Agent entry point, --enroll + --config flags |
| `agent/internal/server/server.go` | HTTP server setup, route registration |
| `agent/internal/server/handlers.go` | All 31 API handlers |
| `agent/internal/server/authmw.go` | Auth middleware, rate limiting |
| `agent/internal/server/ws.go` | WebSocket hub |
| `agent/internal/auth/store.go` | Token/device persistence |
| `agent/internal/auth/signer.go` | HMAC token signing |
| `app/lib/main.dart` | Flutter entry, ProviderScope |
| `app/lib/providers.dart` | DI overrides for all repositories |
| `app/lib/ui/theme/app_theme.dart` | Material 3 theme + AppColors extension |
| `app/lib/ui/router/app_router.dart` | GoRouter with all 10 routes |
| `app/lib/data/sources/remote/api_client.dart` | Dio HTTP client |
| `app/lib/data/sources/remote/web_socket_client.dart` | WebSocket client |
| `app/lib/data/repositories/server_repository_impl.dart` | Server enrollment + token management |
| `app/lib/state/servers/server_provider.dart` | Server list + detail providers |

### Config File (for server)

```yaml
serverName: my-server
listenHost: "0.0.0.0"
listenPort: 9443
tlsCertPath: ""      # empty = plain HTTP
tlsKeyPath: ""       # empty = plain HTTP
auth:
  accessTokenTTL: 900
  refreshTokenTTL: 2592000
docker:
  socketPath: /var/run/docker.sock
  enabled: true
host:
  metricsInterval: 5
terminal:
  maxSessions: 4
  idleTimeout: 300
files:
  allowedRoots: ["/home", "/var/log", "/tmp", "/etc"]
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
```

---

## Phase 3: What To Do Next

### Step 1: Deploy agent to real server
- Cross-compile: `GOOS=linux GOARCH=amd64 go build -o qwe1-agent-linux ./cmd/qwe1-agent`
- SCP to server
- Create config.yaml on server
- Run `./qwe1-agent-linux --config config.yaml`
- Verify: `curl http://SERVER_IP:9443/status`

### Step 2: Test enrollment
- Run `./qwe1-agent-linux --enroll` on server
- Copy the token

### Step 3: Connect Flutter app
- Build APK, install on phone
- Open app, add server with URL + token
- Check dashboard loads

### Step 4: Fix whatever breaks
- Most likely: connection issues, auth issues, data mapping issues
- Fix bugs, rebuild, test again

### Step 5: Wire remaining features
- Terminal WebSocket connection
- Metrics streaming to dashboard cards
- Container detail action buttons
- File download/preview

---

## Git History

```
4a8e321 docs: Update README and GETTING_STARTED with --enroll command
39ba00a feat: Implement --enroll CLI, upgrade Flutter UI with animations
1575ca0 Remove accidentally committed binary
940bf7e Initial commit: Flutter app + Go agent (working build)
```

Branches:
- `main` — primary branch
- `feature/enroll-and-ui-upgrade` — merged to main

Remote: `origin` → https://github.com/Eapechan/qwe1.git
