<p align="center">
  <img src="assets/branding/logo.svg" alt="qwe1" width="120" />
  <h1 align="center">qwe1</h1>
  <p align="center">Your self-hosted servers, in your pocket. No cloud. Ever.</p>
</p>

<p align="center">
  <a href="https://github.com/Eapechan/qwe1/releases"><img alt="Release" src="https://img.shields.io/github/v/release/Eapechan/qwe1"></a>
  <a href="LICENSE"><img alt="License: AGPL-3.0" src="https://img.shields.io/badge/license-AGPL--3.0-blue"></a>
</p>

---

## Project Status

| | |
|---|---|
| **Current Version** | v2.0 |
| **Status** | Active Development |
| **Next Milestone** | v2.1 |

### Roadmap

| Version | Status |
|---------|--------|
| ✅ v2.0 | Core Platform (Stable) |
| 🚧 v2.1 | Monitoring & UI/UX Overhaul (Active) |
| 📅 v2.2 | Dockerized Agent & Simplified Deployment |
| 💡 v3.0 | AI Management & Automation |

---

## Introduction

qwe1 is a modern self-hosted server management platform focused on Docker, homelabs, Linux servers, and remote infrastructure with a clean mobile-first experience. It pairs a lightweight Go agent on each server with a Flutter mobile app, giving you direct control over your hardware — no cloud, no accounts, no vendor in between.

## Features

| Feature | Status |
|---------|--------|
| Server Pairing | ✅ Stable |
| Dashboard | ✅ Stable |
| Live Server Metrics | ✅ Stable |
| Docker Detection | ✅ Stable |
| Container Discovery | ✅ Stable |
| Container Health | ✅ Stable |
| Per-Container Metrics | 🚧 In Progress |
| Container Details | 🚧 Partial |
| Container Actions | 🚧 Partial |
| Container Logs | 🚧 Partial |
| Live Graphs | 🚧 In Progress |
| Terminal Access | 🚧 Partial |
| File Manager | 🚧 Partial |
| Alerts | 🚧 In Progress |
| Authentication | 🚧 Partial |
| Settings | 🚧 Partial |
| Multi-Server | 📅 Planned |
| AI Assistant | 💡 Future |
| Backup Automation | 💡 Future |

## Current Focus

The v2.1 milestone is focused on completing the monitoring experience and polishing the UI. Completed work includes:**

- Complete UI/UX redesign with dark-first palette and animated components
- New onboarding flow with page animations
- Revamped startup animation with compression, ripple, and power-on effects
- Mission Control dashboard with health ring and animated metrics
- Redesigned container cards with pulse indicators and sparklines
- Interactive terminal and file browser with touch feedback
- Animated widgets library (health ring, progress ring, sparkline, animated card)
- Live per-container metrics
- Terminal improvements
- File manager enhancements
- Container statistics
- Alerts
- UI polish and animations
- Performance improvements

## Design Vision

qwe1 aims to build a premium, animated, modern server management experience — not a traditional dashboard. The UI draws inspiration from:

- **Netflix** — smooth animations and visual hierarchy
- **Plex** — clean, content-focused layout
- **NZB360** — mobile-first navigation patterns
- **Arc Browser** — minimal, purposeful design
- **Nothing OS** — bold typography and subtle depth
- **Apple Human Interface Guidelines** — consistency, clarity, and deference

The goal is to make managing servers feel effortless and enjoyable on any screen size.

## Architecture

```
Flutter App
    ↓
Backend API
    ↓
Local Agent
    ↓
Docker Engine / Linux System
    ↓
Containers • Files • Metrics
```

The agent is a single static Go binary that runs on each Linux server. It exposes a secure REST API over HTTPS (TLS 1.3) and a WebSocket endpoint for real-time streams.

```
agent/
├── cmd/qwe1-agent/main.go    # Entrypoint: CLI flags, enroll, server bootstrap
├── internal/
│   ├── server/               # HTTP/WS server, router, middleware, handlers
│   │   ├── server.go         # Server wiring, route registration, lifecycle
│   │   ├── handlers.go       # All REST endpoint handlers
│   │   ├── authmw.go         # Auth middleware, rate limiting, audit recording
│   │   ├── middleware.go      # Logging, recovery, CORS middleware
│   │   ├── respond.go        # JSON response helpers
│   │   ├── types.go          # Shared API type aliases
│   │   ├── ws.go             # WebSocket hub, client management
│   │   └── server_test.go    # Integration tests
│   ├── auth/                  # Token signing, validation, device store
│   ├── config/                # YAML config loader with defaults
│   ├── host/                   # Host metrics collector (CPU, RAM, disk, network, temp)
│   ├── docker/                # Docker Engine API wrapper
│   ├── terminal/              # PTY session manager
│   ├── files/                 # Allow-listed filesystem operations
│   ├── alerts/                # Threshold evaluation engine
│   ├── ratelimit/             # Token-bucket rate limiter
│   ├── audit/                 # Bounded ring-buffer audit log
│   └── certs/                 # Self-signed TLS certificate generation
```

## Screenshots

🚧 Updated screenshots and UI previews will be added after the v2.1 redesign.

## API Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `GET` | `/status` | No | Public reachability check |
| `POST` | `/auth/enroll` | No | Exchange enrollment token for credentials |
| `POST` | `/auth/refresh` | No | Rotate refresh token, issue new access token |
| `POST` | `/auth/revoke` | Yes | Revoke current device |
| `GET` | `/auth/me` | Yes | Device identity and capabilities |
| `GET` | `/metrics/latest` | Yes | Latest host metrics snapshot |
| `GET` | `/metrics/history` | Yes | Historical metrics (stubbed) |
| `GET` | `/docker/containers` | Yes | List containers |
| `POST` | `/docker/containers/{id}/start` | Yes | Start container |
| `POST` | `/docker/containers/{id}/stop` | Yes | Stop container |
| `POST` | `/docker/containers/{id}/restart` | Yes | Restart container |
| `POST` | `/docker/containers/{id}/pause` | Yes | Pause container |
| `POST` | `/docker/containers/{id}/unpause` | Yes | Resume container |
| `POST` | `/docker/containers/{id}/kill` | Yes | Kill container |
| `DELETE` | `/docker/containers/{id}` | Yes | Remove container |
| `GET` | `/docker/containers/{id}/inspect` | Yes | Inspect container |
| `GET` | `/docker/containers/{id}/logs` | Yes | Container logs |
| `GET` | `/docker/images` | Yes | List images |
| `GET` | `/docker/images/{id}` | Yes | Inspect image |
| `POST` | `/docker/images/{id}/pull` | Yes | Pull image |
| `DELETE` | `/docker/images/{id}` | Yes | Remove image |
| `GET` | `/docker/volumes` | Yes | List volumes |
| `GET` | `/docker/volumes/{name}` | Yes | Inspect volume |
| `GET` | `/docker/networks` | Yes | List networks |
| `GET` | `/docker/networks/{id}` | Yes | Inspect network |
| `POST` | `/terminal` | Yes | Create PTY session |
| `DELETE` | `/terminal/{id}` | Yes | Kill terminal session |
| `GET` | `/fs/list` | Yes | List directory contents |
| `GET` | `/fs/read` | Yes | Read file |
| `POST` | `/fs/upload` | Yes | Upload file |
| `POST` | `/fs/mkdir` | Yes | Create directory |
| `POST` | `/fs/write` | Yes | Write file |
| `PATCH` | `/fs/rename` | Yes | Rename/move file |
| `DELETE` | `/fs` | Yes | Delete file/directory |
| `POST` | `/fs/copy` | Yes | Copy file/directory |
| `GET` | `/fs/search` | Yes | Search files by pattern |
| `GET` | `/fs/favorites` | Yes | List favorites |
| `POST` | `/fs/favorites` | Yes | Add favorite |
| `DELETE` | `/fs/favorites` | Yes | Remove favorite |
| `GET` | `/alerts` | Yes | List alerts |
| `PUT` | `/alerts/{id}/ack` | Yes | Acknowledge alert |
| `GET` | `/alerts/thresholds` | Yes | Get alert thresholds (stubbed) |
| `PUT` | `/alerts/thresholds` | Yes | Update alert thresholds (stubbed) |
| `GET` | `/audit` | Yes | Audit log (stubbed) |
| `GET` | `/debug/pprof/` | Yes | List pprof profiles |
| `GET` | `/debug/pprof/profile` | Yes | CPU profile download |
| `GET` | `/ws` | No | WebSocket endpoint |

See the [API reference](https://github.com/Eapechan/qwe1/blob/v1/API_REFERENCE.md) on the `v1` branch for full request/response schemas.

## Quickstart

### 1. Install the app

Build the APK from source or download the latest release, then install it on your device.

### 2. Set up the agent

**Prerequisites:** Go >= 1.25 on your server ([install Go](https://go.dev/dl/)).

Clone the repo and use the management script:

```bash
git clone https://github.com/Eapechan/qwe1.git
cd qwe1
tools/qwe1.sh dev
```

`tools/qwe1.sh dev` builds the agent, starts it, and runs a full verification suite.

To generate the enrollment QR code:

```bash
tools/qwe1.sh enroll
```

The QR code is saved to `enroll-qr.png` and printed as ASCII in the terminal. The token is valid for **1 hour** and can be reused across devices. After it expires, run `tools/qwe1.sh enroll` again.

For a production deployment with TLS certs + systemd, follow the manual steps in [GETTING_STARTED.md](docs/GETTING_STARTED.md). A commented config template lives at [`config.example.yaml`](config.example.yaml).

### 3. Pair the app

Open the qwe1 app → Add Server → **Scan QR Code** → scan the QR from the terminal or `enroll-qr.png`.

See [GETTING_STARTED.md](docs/GETTING_STARTED.md) for the full step-by-step guide.

## Planned Features

The following features are planned but not yet implemented:

- Multi-server management
- Live container graphs
- Rich notifications
- AI diagnostics
- Docker Compose management
- Backup scheduling
- Plugin system

## Version History

| Version | Status | Focus |
|---------|--------|-------|
| v2.0 | Stable | Core platform |
| v2.1 | In Progress | Monitoring & UI overhaul |
| v2.2 | Planned | Dockerized agent |
| v3.0 | Planned | AI management |

## Documentation

| Doc | What it answers |
|-----|-----------------|
| [Getting Started](docs/GETTING_STARTED.md) | How to run everything end-to-end |
| [Security](SECURITY.md) | Security policy and responsible disclosure |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Code of Conduct](CODE_OF_CONDUCT.md) | Community standards |

## Contributing

We welcome contributors of every skill level. See [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

- Discussions for RFCs and questions
- [Bug reports](https://github.com/Eapechan/qwe1/issues/new)
- Docs fixes are always appreciated

## Security

qwe1 is a remote-management tool — it is a high-value target. If you find a vulnerability, please follow our [responsible disclosure policy](SECURITY.md). **Do not open a public issue for security bugs.**

## License

[AGPL-3.0-or-later](LICENSE) — the code is a commons. If you offer qwe1 as a networked service, your modifications must be released to the community.