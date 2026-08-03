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

**qwe1** is a privacy-first, open-source mobile app for managing your self-hosted Linux servers. Monitor health, manage Docker containers, drop into a terminal, browse files, and get alerted — all from your phone, talking **directly** to a lightweight agent on each of your servers.

**No account. No cloud. No vendor between you and your hardware.**

## Highlights

- Live health monitoring — CPU, RAM, disk, network, temperature, uptime, disk I/O, processes
- Docker management — containers, images, volumes, networks; start/stop/restart, stream logs
- Interactive terminal — real PTY sessions from your phone
- File browser — navigate, upload, copy, search, and manage files on the server
- Alerts — threshold-based with history and acknowledgement
- Performance profiling — pprof endpoints for CPU and memory
- Security — TLS 1.3, certificate pinning, short-lived tokens, biometric lock
- Multiple servers, one app
- Zero cloud — every byte travels only between your phone and your own servers

## Quickstart

### 1. Install the agent

Build and run on your Linux server:

```bash
# Build for Linux amd64
GOOS=linux GOARCH=amd64 go build -o qwe1-agent ./cmd/qwe1-agent

# Transfer to server
scp qwe1-agent user@YOUR_SERVER_IP:~/qwe1-agent

# SSH in and run
ssh user@YOUR_SERVER_IP
chmod +x ~/qwe1-agent
./qwe1-agent
```

Or via Docker:

```sh
docker run -d --name qwe1-agent --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 9443:9443 qwe1/agent
```

### 2. Generate a pairing token

```bash
./qwe1-agent --enroll
```

This prints a QR code you can scan with the app, plus an enrollment token you can paste. The token is valid for **1 hour** and can be used by multiple devices within that window. After 1 hour, run `--enroll` again.

### 3. Install the app

Build the APK or install from releases, then scan the QR code or enter your server URL and the enrollment token.

See [GETTING_STARTED.md](GETTING_STARTED.md) for the full step-by-step guide.

Run the agent (or use `./token.sh` for a one-liner):

```bash
# terminal 1 — run the agent
./qwe1-agent --config config.yaml

# terminal 2 — generate a token + QR code
./token.sh
```

For a production deployment with TLS certs + systemd, follow the manual steps in
[GETTING_STARTED.md](GETTING_STARTED.md) (self-signed certs, hardened config,
systemd unit). A commented config template lives at
[`config.example.yaml`](config.example.yaml).

## Architecture

```
Flutter App (phone) <-- HTTP/WebSocket --> Go Agent (your server) --> Docker API
```

| Component | Stack | Location |
|-----------|-------|----------|
| Mobile app | Flutter, Riverpod, Material 3 | `app/` |
| Server agent | Go, net/http, WebSocket | `agent/` |

### Backend Architecture

The agent is a single static Go binary that runs on each user's Linux server. It exposes a secure REST API over HTTPS (TLS 1.3) and a WebSocket endpoint for real-time streams.

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
│   ├── auth/                 # Token signing, validation, device store
│   ├── config/               # YAML config loader with defaults
│   ├── host/                 # Host metrics collector (CPU, RAM, disk, network, temp)
│   ├── docker/               # Docker Engine API wrapper
│   ├── terminal/             # PTY session manager
│   ├── files/                # Allow-listed filesystem operations
│   ├── alerts/               # Threshold evaluation engine
│   ├── ratelimit/            # Token-bucket rate limiter
│   ├── audit/                # Bounded ring-buffer audit log
│   └── certs/                # Self-signed TLS certificate generation
```

### Backend Features

| Feature | Status | Details |
|---------|--------|---------|
| Authentication (enroll/refresh/revoke) | Working | HMAC-SHA256 tokens, refresh rotation, device management |
| Host metrics | Working | CPU, RAM, swap, disk, network, temperature, uptime, load, cache, buffers, disk I/O, kernel, arch, OS, boot time, users, processes |
| Docker management | Working | Containers, images, volumes, networks — list, inspect, lifecycle, logs |
| File management | Working | List, read, write, upload, mkdir, rename, delete, copy, search, favorites |
| Terminal (PTY) | Working | Create, kill, resize sessions |
| Alerts engine | Working | Threshold evaluation with debounce and deduplication |
| Real-time updates | Working | WebSocket hub with multiplexed channels |
| Audit logging | Working | Bounded ring buffer of privileged actions |
| Rate limiting | Working | Per-IP and per-token token-bucket limiter |
| TLS | Working | TLS 1.3, self-signed ECDSA P-256 cert generation |
| Performance profiling | Working | pprof endpoints for CPU/heap/goroutine profiles |

### API Endpoints

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

## Documentation

| Doc | What it answers |
|-----|-----------------|
| [Getting Started](GETTING_STARTED.md) | How to run everything end-to-end |
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
