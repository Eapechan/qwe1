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

- Live health monitoring — CPU, RAM, disk, network, temperature, uptime
- Docker management — list, inspect, start/stop/restart, stream logs
- Interactive terminal — real PTY sessions from your phone
- File browser — navigate, upload, and manage files on the server
- Alerts — threshold-based with history and acknowledgement
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

This shows an enrollment token you'll enter in the app.

### 3. Install the app

Build the APK or install from releases, then enter your server URL and the enrollment token.

See [GETTING_STARTED.md](GETTING_STARTED.md) for the full step-by-step guide.

## Architecture

```
Flutter App (phone) <-- HTTP/WebSocket --> Go Agent (your server) --> Docker API
```

| Component | Stack | Location |
|-----------|-------|----------|
| Mobile app | Flutter, Riverpod, Material 3 | `app/` |
| Server agent | Go, net/http, WebSocket | `agent/` |

## What Works

| Feature | Status |
|---------|--------|
| Host metrics (CPU/RAM/Disk) | Working |
| Docker management | Working |
| File browser (list/read/write/upload) | Working |
| Alerts engine | Working |
| Authentication (enroll/refresh/revoke) | Working |
| Terminal (PTY sessions) | Backend working, UI partial |
| Real-time metrics streaming | Backend working, UI partial |

## Documentation

| Doc | What it answers |
|-----|-----------------|
| [Getting Started](GETTING_STARTED.md) | How to run everything end-to-end |
| [Vision](docs/01-vision.md) | Why qwe1 exists |
| [Architecture](docs/09-architecture.md) | How it's built |
| [API](docs/11-api-design.md) | The wire contract |
| [Security](docs/14-security-architecture.md) | How we defend it |
| [Roadmap](docs/17-roadmap.md) | What's next |

## Contributing

We welcome contributors of every skill level. See [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

- Discussions for RFCs and questions
- [Bug reports](https://github.com/Eapechan/qwe1/issues/new)
- Docs fixes are always appreciated

## Security

qwe1 is a remote-management tool — it is a high-value target. If you find a vulnerability, please follow our [responsible disclosure policy](SECURITY.md). **Do not open a public issue for security bugs.**

## License

[AGPL-3.0-or-later](LICENSE) — the code is a commons. If you offer qwe1 as a networked service, your modifications must be released to the community.
