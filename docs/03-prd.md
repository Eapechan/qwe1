# 03 — Product Requirements Document (PRD)

**Project:** qwe1
**Version:** v1.0
**Status:** `[DECIDED]`
**Owner:** Product

---

## 1. Problem statement

People who run personal Linux servers (homelabs, VPSes, NAS boxes) manage them with a patchwork of tools: SSH from a laptop, web UIs on desktop, separate uptime monitors, and ad-hoc notification scripts. On a phone — where they actually want to check in — the experience is poor: web UIs are desktop-oriented, good mobile SSH apps are closed-source subscriptions, and nothing open-source combines *monitoring, Docker control, terminal, files, and alerts* in one privacy-first app that requires no cloud service.

qwe1 solves this by giving users a native mobile control plane that talks **directly** to a small, open-source agent on each of their servers — no cloud, no account, no subscription.

## 2. Objectives

| ID | Objective | Measured by |
|----|-----------|-------------|
| OBJ-1 | Time-to-first-value under 10 minutes | Install → live metrics on phone |
| OBJ-2 | Mobile-native UX that matches native apps | Design-system conformance + user testing; cold start < 2s (see FR-NS1) |
| OBJ-3 | Zero cloud dependency | Architecture: no vendor endpoint contacted at any point |
| OBJ-4 | Broad, useful operations coverage | Must-have feature completeness at v1 release |
| OBJ-5 | Trustworthy security | Passing security checklist + no critical-severity release findings |
| OBJ-6 | Sustainable community | Documented contribution path; public roadmap |

## 3. User personas

### P1 — Alex, the homelab enthusiast (primary)
- 28, runs a NUC and a Raspberry Pi at home: Plex, Home Assistant, Pi-hole, a few containers.
- Checks servers on the couch, on the bus, in bed. Uses phone constantly, laptop rarely for admin.
- **Pain:** "I SSH in from my phone just to see if Plex is up and maybe restart it. It's 2026."
- **Needs:** glanceable status, one-tap restart, an alert when the Pi disk fills up.
- **Friction tolerance:** medium. Will run a curl script, will not configure YAML for fun.

### P2 — Sam, the sysadmin
- 35, runs a VPS fleet for side projects + a home server.
- Wants control: real terminals, logs, files, precise monitoring.
- **Pain:** "I can't do terminal stuff from my phone without a closed SaaS app."
- **Needs:** reliable terminal, tail logs, storage monitoring, alerts, secure by default.
- **Friction tolerance:** high — but intolerant of insecurity and unreliability.

### P3 — Priya, the Docker developer
- 31, develops containerized apps; runs staging on a home box.
- **Pain:** "A container went down; I only found out by luck."
- **Needs:** container health + logs + quick restart; uptime awareness.

### P4 — Dan, the self-hosting beginner
- 24, just bought a mini PC and installed Ubuntu Server + Docker.
- **Pain:** "Terminal scares me; I just want my apps to run and know when they break."
- **Needs:** dead-simple onboarding, clear status, restart buttons, plain-language alerts.
- **Friction tolerance:** low. Every step must be obvious.

## 4. User stories

### Onboarding & server management
- US-01 As a new user, I want to install the agent with one command so I can get started quickly.
- US-02 As a user, I want to pair my phone to the agent via a QR code so I don't type long tokens.
- US-03 As a user, I want to add multiple servers so I can manage all of them from one app.
- US-04 As a user, I want to rename and group servers so my dashboard is organized.
- US-05 As a user, I want to see connection status for each server so I know which is reachable.

### Monitoring
- US-06 As a user, I want a dashboard with CPU, RAM, disk, network, temperature, and uptime.
- US-07 As a user, I want live-updating charts while the app is open.
- US-08 As a user, I want to see per-container resource usage.
- US-09 As a user, I want alerts when thresholds are breached (CPU, RAM, disk, temp, container down).
- US-10 As a user, I want the last known state shown offline so I can still see recent values.

### Docker
- US-11 As a user, I want to see all containers with status, image, and resource usage.
- US-12 As a user, I want to start, stop, restart, and pause a container.
- US-13 As a user, I want to view and tail container logs.
- US-14 As a user, I want to see container inspect details (env, ports, mounts, networks, labels).
- US-15 As a user, I want confirmations and feedback before and after container actions.

### Terminal
- US-16 As a user, I want a full interactive terminal session to run commands.
- US-17 As a user, I want terminal sessions that survive screen changes and reconnects within the app.
- US-18 As a user, I want terminal themes and font size controls.
- US-19 As a user, I want to force-close a session (including stuck processes).

### File browser
- US-20 As a user, I want to browse files on the server within the allowed root path.
- US-21 As a user, I want to view file contents (text/images) and get metadata.
- US-22 As a user, I want to upload/download files between phone and server.
- US-23 As a user, I want to delete, rename, and create files/directories (respecting permissions).

### Notifications
- US-24 As a user, I want to receive local notifications for alerts when the app is reachable.
- US-25 As a user, I want an in-app alert/notification history.
- US-26 As a user, I want to optionally forward alerts to my own webhook/ntfy endpoint.

### Settings & security
- US-27 As a user, I want biometric lock for the app.
- US-28 As a user, I want a read-only mode per server so I can safely hand the phone to someone.
- US-29 As a user, I want to remove a server (and revoke its agent access) from the app.
- US-30 As a user, I want to review the certificate fingerprint of each server.

## 5. Acceptance criteria

- AC-01 (US-01/02): A first-time user can install the agent and pair within 10 minutes, following only on-screen instructions.
- AC-02 (US-06): The dashboard renders all metrics within 3 seconds of open with valid data; charts update at the configured interval without gaps when connected.
- AC-03 (US-11–13): Container list loads < 2s for ≤ 200 containers; log tail streams with < 1s latency and respects the agent's log limits.
- AC-04 (US-16): Terminal input-to-output round-trip latency is < 200ms on LAN; terminal survives an app background/foreground cycle.
- AC-05 (US-20): File browser cannot traverse outside the configured allow-list root; attempts return 403.
- AC-06 (US-24/25): Alerts recorded by the agent appear in history with timestamps; local notifications fire when the app is active.
- AC-07 (US-27): Biometric lock prevents app access when enabled and device policy allows it.
- AC-08 (US-28): In read-only mode, all mutating endpoints/UI are disabled end-to-end (agent refuses too).
- AC-09 (Security): All transport is TLS with pinning; token rotation is enforced (Section 13/14).
- AC-10 (Offline): With no connectivity, previously-cached data is shown with a "last updated" marker; queued actions are blocked with clear messaging (no silent failure).

## 6. Functional requirements

> Detailed feature-by-feature specs live in [04-feature-planning.md](./04-feature-planning.md) and [08-screens.md](./08-screens.md). This section states the authoritative requirement set.

### FR-DS — Device & server management
- FR-DS-01 Multiple server profiles (name, host, port, agent URL, fingerprint, labels, group).
- FR-DS-02 Server CRUD + connectivity test + status indicator.
- FR-DS-03 Grouping/organization of servers.
- FR-DS-04 Per-server read-only mode toggle.
- FR-DS-05 mDNS auto-discovery `[DEFERRED to v1.1]`.

### FR-MN — Monitoring
- FR-MN-01 Host metrics: CPU (per-core + total), RAM, swap, disk (per mount), network (throughput), temperature (per sensor, when available), uptime, load average.
- FR-MN-02 Live streaming of metrics while connected (WebSocket), fallback polling.
- FR-MN-03 Metric history kept on-device (bounded retention, see [12-database-design.md](./12-database-design.md)).
- FR-MN-04 Alert threshold configuration per server (CPU, RAM, disk, temp, container down, host down).
- FR-MN-05 Alert buffer + history on-device; optional webhook/ntfy forwarding.

### FR-DK — Docker
- FR-DK-01 Container list: name, status, image, created, ports, CPU/mem usage, health.
- FR-DK-02 Container actions: start, stop, restart, pause, unpause, kill, remove (each requiring explicit confirm; remove/kill requires typing container name).
- FR-DK-03 Container logs: stream tail with level filtering and search.
- FR-DK-04 Container inspect: config, env (masked per security rules), mounts, networks, labels, port mappings.
- FR-DK-05 Containers-per-server count and global status summary.
- FR-DK-06 Docker engine reachability/error surfacing.

### FR-TM — Terminal
- FR-TM-01 Interactive PTY session over WebSocket (local shell on the server).
- FR-TM-02 Session management: create, attach/detach, reconnect, terminate.
- FR-TM-03 Themes (dark/light), font size, scrollback, copy/paste of selection.
- FR-TM-04 Concurrency limit enforced agent-side (e.g., 4 simultaneous sessions).
- FR-TM-05 Optionally start session as a specific user (via sudo, requires configured privileges) `[DEFERRED]`.

### FR-FB — File browser
- FR-FB-01 Browse within configured root path(s); per-agent allow-list.
- FR-FB-02 File metadata, preview (text, image), download to phone, upload from phone.
- FR-FB-03 Create/rename/delete files and directories; permission errors surfaced.
- FR-FB-04 Truncated/limited directory listings for very large directories.

### FR-NT — Notifications
- FR-NT-01 Agent-side alert detection and buffering.
- FR-NT-02 On-device local notifications when app is active/reachable.
- FR-NT-03 Alert history screen (per server + global).
- FR-NT-04 Optional webhook/ntfy forwarding configured via app or agent config.

### FR-SE — Security (summary; full spec in [14-security-architecture.md](./14-security-architecture.md))
- FR-SE-01 TLS 1.3 (fallback 1.2) with certificate pinning.
- FR-SE-02 Short-lived access tokens (JWT) + rotating refresh tokens.
- FR-SE-03 Biometric app lock.
- FR-SE-04 Secrets in Keychain/Keystore only.
- FR-SE-05 Read-only mode enforced agent-side.
- FR-SE-06 Rate limiting and brute-force protection agent-side.
- FR-SE-07 Remote logout / token revocation.
- FR-SE-08 Audit log of admin actions agent-side.

### FR-ST — Settings & system
- FR-ST-01 Theme (light/dark/system), accent color `[Nice-to-Have]`.
- FR-ST-02 Language: English v1; i18n framework enabled `[i18n framework only]`.
- FR-ST-03 App update mechanism (stores); agent update mechanism documented.
- FR-ST-04 Crash reporting opt-in (on-device logs; no remote telemetry by default).
- FR-ST-05 Feedback/issue reporting that opens GitHub.

## 7. Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-PF-1 | Performance | Cold start (splash→dashboard) < 2s on mid-range device (2023+). |
| NFR-PF-2 | Performance | Dashboard initial render < 3s from app-open on Wi-Fi. |
| NFR-PF-3 | Performance | Container list < 2s for ≤ 200 containers. |
| NFR-PF-4 | Performance | Terminal round-trip < 200ms LAN; acceptable > 500ms WAN with jitter buffer. |
| NFR-PF-5 | Performance | App memory: keep under 150MB; log streams must not grow unboundedly (backpressure + bounds). |
| NFR-RL-1 | Reliability | Crash-free sessions ≥ 99.5% of app sessions; agent uptime target ≥ 99.9% while running. |
| NFR-RL-2 | Reliability | Reconnection logic with exponential backoff; state reconciliation after reconnect. |
| NFR-RL-3 | Reliability | No data loss for offline queued operations (persisted queue, replay semantics). |
| NFR-SC-1 | Security | See [14-security-architecture.md](./14-security-architecture.md) — binding. |
| NFR-SC-2 | Security | No secrets in plaintext DB; tokens ≤ 15 min lifetime for access tokens. |
| NFR-SC-3 | Security | Rate limits per IP + per token; account lockout after configurable attempts. |
| NFR-US-1 | Usability | All primary actions reachable within 2 taps from the dashboard. |
| NFR-US-2 | Usability | Touch targets ≥ 48×48dp; WCAG AA contrast in both themes. |
| NFR-CO-1 | Compatibility | Android 8+ (API 26+), iOS 15+; agent on Debian/Ubuntu/Fedora/Alpine + Docker; arch amd64/arm64/armv7. |
| NFR-OF-1 | Offline | Last-known metrics visible offline with stale marker; offline queue for config edits only (server ops require connectivity). |
| NFR-LO-1 | Localization | English first; architecture supports additional locales. |
| NFR-AC-1 | Accessibility | Screen-reader labels, scalable text, high-contrast themes (see [07-design-system.md](./07-design-system.md)). |
| NFR-DOC-1 | Documentation | All Must-have features documented before release (see [20-documentation.md](./20-documentation.md)). |

## 8. Success metrics

### Product metrics
- **Activation:** % of installs that pair ≥ 1 server within 24h. **Target:** ≥ 60% (of opt-in analytics; see privacy note).
- **Retention:** weekly active users / monthly active users. **Target:** ≥ 0.45.
- **Feature adoption:** % of active users using Docker, terminal, file browser weekly.
- **Alert value:** median time from "server issue" to "user aware" for active users.

### Engineering metrics
- **Reliability:** crash-free sessions ≥ 99.5%; release-blocking regressions = 0.
- **Security:** 0 critical findings in release-scanned vulns (dependency + app).

### Community metrics
- **Contributors:** ≥ 10 distinct contributors within 6 months of v1.
- **Docs:** all docs in [20-documentation.md](./20-documentation.md) published and linted.

> **Privacy note:** The app is privacy-first. Any product analytics MUST be opt-in, aggregate, and self-hostable. Default = none.

## 9. Risks and mitigations

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-1 | Scope creep (broad feature set) | High | High | Strict MoSCoW in [04-feature-planning.md](./04-feature-planning.md); terminal & files built to defined subsets |
| R-2 | Alerting without cloud push is weak | Medium | Medium | Agent-side webhook/ntfy; local notifications; explicit UX |
| R-3 | Security perception / CVE | Medium | High | Security-first architecture ([14](./14-security-architecture.md)), visible policy, audit-ready |
| R-4 | Agent install friction | Medium | Medium | One-line install, QR pairing, Docker install path, clear docs |
| R-5 | Hardware variance (temp sensors, distro quirks) | Medium | Medium | Graceful degradation, per-agent capability detection |
| R-6 | Terminal UX is hard to get right on mobile | High | Medium | Dedicated UX spec ([07](./07-design-system.md)), keyboard support, themes, testing |
| R-7 | API version drift app↔agent | Medium | Medium | API version header + paired releases (see [09](./09-architecture.md)) |
| R-8 | Community bandwidth for maintenance | Medium | Medium | Governance doc, milestone-focused releases, CI automation |

## 10. Release criteria (v1 GA)

1. All Must-Have features `[04-feature-planning.md](./04-feature-planning.md)` complete.
2. All acceptance criteria AC-01…AC-10 pass in QA.
3. Security checklist green ([14-security-architecture.md](./14-security-architecture.md) §12).
4. Test coverage thresholds met ([19-testing-strategy.md](./19-testing-strategy.md)).
5. Beta cycle: ≥ 2 weeks with ≥ 50 testers and 0 critical bugs open.
6. Docs complete and reviewed ([20-documentation.md](./20-documentation.md)).
