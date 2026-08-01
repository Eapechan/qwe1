<p align="center">
  <img src="assets/branding/logo.svg" alt="qwe1" width="120" />
  <h1 align="center">qwe1</h1>
  <p align="center">Your self-hosted servers, in your pocket. No cloud. Ever.</p>
</p>

<p align="center">
  <a href="https://github.com/qwe1/qwe1/releases"><img alt="Release" src="https://img.shields.io/github/v/release/qwe1/qwe1"></a>
  <a href="LICENSE"><img alt="License: AGPL-3.0" src="https://img.shields.io/badge/license-AGPL--3.0-blue"></a>
  <a href="https://github.com/qwe1/qwe1/actions"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/qwe1/qwe1/ci-agent.yml"></a>
</p>

---

**qwe1** is a privacy-first, open-source mobile app for managing your self-hosted Linux servers. Monitor health, manage Docker containers, drop into a terminal, browse files, and get alerted — all from your phone, talking **directly** to a lightweight agent on each of your servers.

**No account. No cloud. No vendor between you and your hardware.**

## Highlights

- 📊 Live health monitoring — CPU, RAM, disk, network, temperature, uptime
- 🐳 Docker management — list, inspect, start/stop/restart, stream logs
- ⌨️ Interactive terminal — real PTY sessions from your phone
- 📁 File browser — navigate, preview, and transfer files on the server
- 🔔 Alerts — threshold-based, with history and optional webhook/ntfy forwarding
- 🔒 Security by default — TLS 1.3, certificate pinning, short-lived tokens, biometric lock
- 📱 Multiple servers, one app
- 🏠 Zero cloud — every byte travels only between your phone and your own servers

## Quickstart

Install the agent on your Linux server (Debian/Ubuntu, Fedora, Alpine, or any distro with a shell):

```sh
curl -fsSL https://get.qwe1.sh | sh
```

or via Docker:

```sh
docker run -d --name qwe1-agent --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 9443:9443 qwe1/agent
```

Then generate a pairing code:

```sh
qwe1-agent enroll
```

Install the app from the [App Store](#), [Play Store](#), or [F-Droid](#), scan the QR code, confirm the fingerprint, and you're done — **under 10 minutes**.

## Documentation

This repository is currently in the **planning phase** and contains the complete architecture and product documentation. Start with the [documentation index](docs/README.md).

| Doc | What it answers |
|-----|-----------------|
| [Vision](docs/01-vision.md) | Why qwe1 exists |
| [Market Research](docs/02-market-research.md) | The gap we fill |
| [PRD](docs/03-prd.md) | Exactly what we build |
| [Architecture](docs/09-architecture.md) | How it's built |
| [API](docs/11-api-design.md) | The wire contract |
| [Security](docs/14-security-architecture.md) | How we defend it |
| [Roadmap](docs/17-roadmap.md) | When it ships |

## Contributing

We welcome contributors of every skill level. See [CONTRIBUTING.md](CONTRIBUTING.md) to get started, and check the [good first issues](https://github.com/qwe1/qwe1/issues?q=is:issue+is:open+label:good-first-issue).

- 💬 Discussions for RFCs and questions
- 🐞 [Bug reports](https://github.com/qwe1/qwe1/issues/new/choose)
- 📝 Docs fixes are always appreciated

## Security

qwe1 is a remote-management tool — it is a high-value target. If you find a vulnerability, please follow our [responsible disclosure policy](SECURITY.md). **Do not open a public issue for security bugs.**

## License

[AGPL-3.0-or-later](LICENSE) — the code is a commons. If you offer qwe1 as a networked service, your modifications must be released to the community.

## Status

**Planning phase** — architecture and product documentation complete, implementation starting per the [roadmap](docs/17-roadmap.md). No stable release yet.
