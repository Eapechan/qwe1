# 01 — Vision Document

**Project:** qwe1
**Version:** v1 (planning)
**Status:** `[DECIDED]`
**Owner:** Product

---

## 1. Mission

Give anyone running a personal Linux server a **beautiful, secure, mobile-native control plane** for their homelab — without relying on a single cloud service, without a subscription, and without handing over their infrastructure to a third party.

qwe1 is the **pocket-sized front door to your own infrastructure**: monitor health, manage Docker containers, drop into a terminal, browse files, and get alerted — all from a phone, all encrypted end-to-end to an agent you run yourself.

## 2. Vision

A world where "self-hosting" is not a technical obstacle course of SSH from a laptop and frantic `htop` sessions. With qwe1, self-hosters get an experience that feels like a polished commercial SaaS — **but every byte travels only between their phone and their own hardware**. The app is the remote, the agent is the switchboard, and the user holds every key.

## 3. Goals

### For the user
- **G1 — Manage servers from anywhere.** Monitor and control multiple self-hosted Linux servers from a phone.
- **G2 — Zero cloud dependence.** The product works with only a phone and a server on a network. No accounts, no telemetry, no vendor relay required.
- **G3 — Feel like a native, modern product.** Design and performance at the level of a first-party OS app: fast, minimal, tactile.
- **G4 — Be trustworthy by default.** Security is not a checkbox; it is the default configuration (encryption everywhere, minimal exposure, least privilege).

### For the project
- **G5 — Open source and sustainable.** A healthy, documented, contributor-friendly community project with a clear governance model.
- **G6 — Version 1 is small and excellent.** A narrow, rock-solid feature set rather than a broad, buggy one.
- **G7 — Foundational architecture.** The v1 architecture must accommodate multi-user, plugins, and AI without rewrites (see [22-future-roadmap.md](./22-future-roadmap.md)).

## 4. Non-goals (v1)

The following are explicitly **out of scope for v1**:

- **NG1 — Managed cloud service / relay.** No vendor-operated relay, push gateway, or SaaS backend.
- **NG2 — AI features.** No AI/LLM features in v1. Reserved exclusively for v2+.
- **NG3 — Full web console.** No attempt to replicate a full desktop web UI. The app is mobile-first.
- **NG4 — Windows/macOS agent.** Linux agents only in v1.
- **NG5 — Multi-user agent accounts.** One operator account per agent in v1. Multi-user RBAC is v2.
- **NG6 — Third-party integration marketplace.** No plugin marketplace in v1 (the *architecture* for plugins is designed in, the store is not).
- **NG7 — Container orchestration (Kubernetes, Swarm management).** Docker single-host management only.
- **NG8 — 24/7 background telemetry collection.** The app is not a persistent monitoring daemon on the phone; it is a control plane that reflects server state on demand and while active.
- **NG9 — Platform-as-a-service features.** No server provisioning, no cloud VPS management, no billing.

## 5. Target users

| Persona | Primary needs | Note |
|---------|---------------|------|
| **Homelab enthusiast** | Quick glanceable health, Docker control, alerts | Largest segment; power user; tolerant of setup friction |
| **Docker user** | Container lifecycle + logs | Core daily workflow |
| **Linux system administrator** | Terminal access, file operations, monitoring, alerts | Demanding of reliability and security |
| **Self-hosting hobbyist** | Simple setup, manage services on a VPS or home server | Needs the easiest onboarding |
| **Developer** | Terminal, logs, quick deploys via Docker | Needs low latency, fast UX |
| **Student / learner** | Learn Linux/Docker from a phone, low cost | Free, open source matters |
| **Home NAS user** | Storage monitoring, alerts, uptime | Needs simple, alert-driven UX |

## 6. Core principles

1. **Privacy first.** The app communicates only with the user's own servers. No data leaves the user's network except with explicit user configuration (e.g., optional webhooks).
2. **Open source.** AGPL-3.0. The code is a public good, auditable by anyone.
3. **Security by default.** TLS, short-lived tokens, secure key storage, and least privilege are defaults, not toggles.
4. **Minimal and fast.** Every feature earns its place. Cold start and screen transitions target native feel.
5. **Reliable under poor connectivity.** Offline-friendly: last-known state, queued actions, graceful degradation.
6. **Mobile first.** Touch targets, gestures, glanceable data, one-handed navigation.
7. **Self-hosted forever.** Users always retain the ability to run the entire product themselves. There is no "cloud tier" for v1.
8. **Progress over control.** The project belongs to its community. Good RFCs can change anything, including this document.

## 7. Future vision

qwe1 will grow from *"your servers in your pocket"* to *"your self-hosted life, unified"*:

- **v2 —** Multi-user agents, AI-assisted operations (summaries of log bursts, alert triage suggestions, natural-language docker commands), deeper alerting (push via user-configured relays), server auto-discovery.
- **v3 —** Plugin architecture with a community catalog, desktop companion, support for non-Docker workloads, and optional local-first web view.
- **Enterprise —** SSO/SAML, audit export to SIEM, agent fleet management, compliance reports.

Full detail in [22-future-roadmap.md](./22-future-roadmap.md).

## 8. Success looks like

- A user can go from *installing the agent* to *viewing live server metrics on their phone* in **under 10 minutes**.
- The v1 feature set (Section 4 of [04-feature-planning.md](./04-feature-planning.md)) is **100% implemented, tested, and documented**.
- The repository has an **active contributor base** with a documented contribution path and a responsive maintainer rotation.
- **Zero critical-severity security vulnerabilities** released; every release passes the security checklist in [14-security-architecture.md](./14-security-architecture.md).

## 9. License strategy

`[DECIDED]` **AGPL-3.0-or-later.**

Reasoning:
- The project's core promise is "privacy first, self-hosted forever." AGPL ensures that anyone who offers qwe1 as a networked service must release their modifications to the community — protecting the project's principles from closed-source forks that would monetize a community project.
- It is the standard copyleft license for self-hosted infrastructure software (shared by Mattermost, Nextcloud, Grafana historically, and similar projects).
- It aligns with the project's philosophical stance: the software is a commons, and improvements flow back.

**Caveat / risk:** AGPL can deter some commercial contributors. Mitigation: a dual-license or CLA conversation is deferred to governance discussions in v2 — flagged `[OPEN]` for later.

## 10. Definition of done for v1

- [ ] Agent installable via one command on Debian/Ubuntu, Fedora, Alpine, and as a Docker container, for `amd64`, `arm64`, `armv7`.
- [ ] App ships for iOS and Android from the same Flutter codebase.
- [ ] All **Must-Have** features from [04-feature-planning.md](./04-feature-planning.md) are implemented.
- [ ] App ↔ agent communication is TLS-encrypted with certificate pinning by default.
- [ ] Security architecture checklist (Section 12 of [14-security-architecture.md](./14-security-architecture.md)) is green.
- [ ] Core test coverage thresholds from [19-testing-strategy.md](./19-testing-strategy.md) are met.
- [ ] Documentation set in [20-documentation.md](./20-documentation.md) is published.
