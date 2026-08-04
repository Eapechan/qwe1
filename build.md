# qwe1 - Build & Architecture Reference

## Project Overview

qwe1 is a server monitoring agent with a Flutter mobile app. A Go agent runs on the target server exposing a REST + WebSocket API (port 9443) for container management, system metrics, file browsing, and terminal access. The Flutter app connects to the agent to display and control everything.

## Architecture

```
┌─────────────────────────────────────────────┐
│  Flutter App (app/)                         │
│  Riverpod state mgmt, Dio HTTP, drift DB    │
│  go_router navigation, WebSocket reconnect  │
└──────────────────┬──────────────────────────┘
                   │ HTTPS (port 9443)
                   ▼
┌─────────────────────────────────────────────┐
│  Go Agent (agent/)                          │
│  net/http server, JWT auth, Docker API,     │
│  PTY terminal, file ops, host metrics       │
│  WebSocket hub for live metrics + logs      │
└─────────────────────────────────────────────┘
```

### Agent structure (`agent/internal/`)

| Package | Purpose |
|---------|---------|
| `server` | HTTP/WS handlers, routing, middleware |
| `auth` | Token store, JWT signer, enrollment, refresh rotation |
| `docker` | Docker Engine API wrapper (containers, images, volumes, networks) |
| `host` | System metrics (CPU, memory, disk, temps) via gopsutil |
| `files` | Virtual filesystem (list, read, write, search) |
| `terminal` | PTY session management |

### App structure (`app/lib/`)

| Directory | Purpose |
|-----------|---------|
| `core/error/` | `AppException` hierarchy + `ErrorMapper` (Dio → typed exceptions) |
| `data/sources/remote/` | `ApiClient` (Dio + `AuthInterceptor` for 401 refresh) |
| `data/repositories/` | `DockerRepositoryImpl`, `ServerRepositoryImpl` |
| `state/docker/` | Riverpod providers for container list, single container, logs |
| `ui/screens/` | Container list, container detail, terminal, file browser, dashboard |
| `ui/widgets/` | `StatusIndicator`, `ContainerCard`, etc. |

## Tech Stack

| Component | Version |
|-----------|---------|
| Go | 1.25+ |
| Flutter / Dart | 3.19.6 / 3.3.4 |
| Android Gradle Plugin | 8.2.0 |
| Kotlin | 1.8.22 |
| Gradle | 8.4 |
| compileSdk | 35 |
| NDK | 25.1.8937393 |
| Desugaring | Enabled (core library desugaring) |
| MultiDex | Enabled |

Key Dart packages: `dio`, `flutter_riverpod`, `drift` (SQLite), `go_router`, `web_socket_channel`.

## Config (`config.yaml`)

```yaml
serverName: my-server          # Display name in the app
listenPort: 9443               # Agent port
tlsCertPath: "" / tlsKeyPath: ""  # Set for HTTPS (required for enrollment)
auth:
  accessTokenTTL: 900          # 15 min
  refreshTokenTTL: 2592000     # 30 days
  enrollmentTTL: 3600          # 1 hour
docker:
  enabled: true
  socketPath: /var/run/docker.sock
```

## Fixes Applied

### Go agent

| Fix | Files | Details |
|-----|-------|---------|
| `RotateRefreshAtomic` race | `auth/store.go` | Single-lock lookup+mark used+add new+touch device |
| `MarkEnrollmentUsed` | `auth/store.go`, `handlers.go:72` | Prevents enrollment token reuse |
| `Reload()` error logging | `handlers.go:56` | Logs failure instead of silently ignoring |
| Fingerprint error logging | `handlers.go:100` | Logs when TLS fingerprint can't be obtained |
| Middleware wiring | `server.go` | `readOnlyMiddleware` + `ipRateLimit` properly chained |

### run.sh

| Fix | Details |
|-----|---------|
| `needs_build()` | Auto-rebuilds agent when any `.go` file is newer than the binary |
| `token` action | Generates enrollment tokens, writes to `qwe1-token.auth.json` |
| `status` action | Checks server health + Docker capability |

### Flutter app

| Fix | Files | Details |
|-----|-------|---------|
| WS auto-reconnect | `web_socket_client.dart` | Exponential backoff (1s → 30s), auto-refresh token on 401 |
| Token refresh callback | `api_client.dart:162` | `AuthInterceptor` retries once on 401 with fresh token |
| `_pingStatus` error logging | `server_status.dart` | Logs errors via `debugPrint` instead of swallowing |

### Android build

| Fix | Details |
|-----|---------|
| AGP 8.2.0 | `android/build.gradle` — compatible with Java 21 |
| Kotlin 1.8.22 | `android/build.gradle` |
| Gradle 8.4 | `android/gradle/wrapper/gradle-wrapper.properties` |
| compileSdk 35 | `android/app/build.gradle` |
| NDK 25.1.8937393 | `android/app/build.gradle` |
| Core desugaring | `android/app/build.gradle` — `coreLibraryDesugaring` enabled |
| MultiDex | `android/app/build.gradle` — `multiDexEnabled true` |

## Current Issues

### 1. Docker 503 "Service unavailable. Docker socket may be down."

- **Where shown:** `container_list_screen.dart:124` displays `Error: ServerUnavailableException: Service unavailable. Docker socket may be down.`
- **Root cause:** `docker.New()` (`docker.go:83-101`) pings the Docker socket at startup; if unreachable, it returns `(nil, err)` and the server sets `s.docker = nil` (`server.go:67`). All Docker handlers then return **503 `DOCKER_UNAVAILABLE`** (`handlers.go:238-241`).
- **On macOS:** Docker socket is absent → always 503. This is expected.
- **On Linux server:** Docker must be installed and the socket (`/var/run/docker.sock`) must exist when the agent starts. If the agent starts before Docker, `docker` stays `false` until restart.
- **Fix:** Ensure Docker is installed on the server. If Docker starts after the agent, restart the agent or implement a dynamic capability check.

### 2. Wrong server name in `/status`

- **Where shown:** `handleStatus` returns `s.cfg.ServerName` (`handlers.go:23`) which reads `config.yaml:10`.
- **Current value:** `my-server`.
- **Fix:** Set `serverName` in `config.yaml` to your actual hostname or desired display name.

### 3. `run.sh status` → `docker: false, rest: true`

- **Expected on macOS.** The status endpoint reports `docker: s.docker != nil` (`handlers.go:27`). On a Linux server with Docker installed and reachable, this will show `true`.

## Deployment

### On the Linux server

```bash
# 1. Pull latest code
cd /path/to/qwe1
git pull

# 2. Edit config.yaml (set serverName, TLS paths if using HTTPS)
vim config.yaml

# 3. Start the agent
./run.sh
# or: ./agent/qwe1-agent --config config.yaml

# 4. Generate enrollment token
./run.sh token
# Copy the token shown, use it in the app to enroll

# 5. Verify
./run.sh status
# Should show: docker: true, rest: true
```

### In the app

1. Tap "+" to add server
2. Enter agent URL: `https://<server-ip>:9443`
3. Paste the enrollment token
4. App stores access/refresh tokens locally (drift SQLite)
5. Docker containers, metrics, terminal, files — all available if capabilities report `true`

## Build APK (local development)

```bash
cd app
flutter build apk --release
# Output: app/build/app/outputs/flutter-apk/app-release.apk

# Install on connected device
adb install app/build/app/outputs/flutter-apk/app-release.apk
```
