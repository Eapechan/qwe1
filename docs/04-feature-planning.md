# 04 — Feature Planning

**Project:** qwe1
**Version:** v1
**Status:** `[DECIDED]`
**Owner:** Product / Engineering

Prioritisation: **MoSCoW**. Every feature carries: Purpose, Priority (M/S/N/F), Complexity (XS/S/M/L/XL), and Dependencies.

Complexity legend: **XS** = hours, **S** = 1–3 days, **M** = 3–7 days, **L** = 1–3 weeks, **XL** = 3+ weeks (per developer).

---

## 1. Must Have (v1 release-critical)

| ID | Feature | Purpose | Priority | Complexity | Dependencies |
|----|---------|---------|----------|-----------|--------------|
| F-001 | Agent install (one-liner + Docker) | Fast onboarding | M | M | Agent base (F-002) |
| F-002 | Go agent with TLS + token auth | Foundation of everything | M | L | — |
| F-003 | QR enrollment / pairing | Effortless secure onboarding | M | M | F-002, auth design ([13](./13-authentication.md)) |
| F-004 | Multiple server profiles (local DB) | Manage >1 server | M | S | DB layer ([12](./12-database-design.md)) |
| F-005 | Server CRUD + connectivity status | Manage server list | M | S | F-004 |
| F-006 | Dashboard: CPU, RAM, disk, network, temp, uptime | Core value — glanceable health | M | M | F-007 |
| F-007 | Host metrics collector (agent) | Data source for dashboard | M | M | F-002 |
| F-008 | Live metric streaming (WebSocket) | "Fast, feels alive" | M | M | F-007 |
| F-009 | Docker container list + status | Core daily use | M | M | F-010 |
| F-010 | Docker integration (agent) | Container access | M | M | F-002, Docker socket |
| F-011 | Container start/stop/restart | Essential control | M | M | F-009, F-010 |
| F-012 | Container logs (tail + stream) | Debugging | M | M | F-010 |
| F-013 | Terminal session (PTY over WS) | Power-user core | M | L | F-002, WS infra |
| F-014 | File browser (allow-listed roots) | File access | M | L | F-002, FS module |
| F-015 | Alert engine (agent) + thresholds | Notifications value | M | M | F-007 |
| F-016 | Alert history + local notifications | Surface alerts | M | M | F-015, local DB |
| F-017 | Secure storage (Keychain/Keystore) | Security non-negotiable | M | S | — |
| F-018 | JWT auth + refresh rotation | Security non-negotiable | M | M | F-002 |
| F-019 | Read-only mode (per server) | Safety | M | S | F-018 |
| F-020 | Dark + light themes | Design quality | M | S | Design system ([07](./07-design-system.md)) |
| F-021 | Settings screen | App configuration | M | S | — |
| F-022 | i18n framework (English content) | Future localization | M | S | — |

## 2. Should Have (strongly desired; ship if capacity or immediately after GA)

| ID | Feature | Purpose | Priority | Complexity | Dependencies |
|----|---------|---------|----------|-----------|--------------|
| F-101 | Biometric app lock | Security/UX | S | S | F-017 |
| F-102 | Container pause/unpause/kill/remove (with confirm-typing) | Full lifecycle | S | S | F-009 |
| F-103 | Container inspect (masked env, ports, mounts, networks) | Deep debugging | S | M | F-010 |
| F-104 | Per-container CPU/mem usage | Triage noisy containers | S | M | F-010, F-007 |
| F-105 | Metric history charts (bounded on-device retention) | Trends | S | M | F-008, DB |
| F-106 | Alert webhook/ntfy forwarding | Alerting independence | S | M | F-015 |
| F-107 | Terminal themes + font size + copy/paste | Terminal quality | S | S | F-013 |
| F-108 | File upload/download to/from phone | Full file ops | S | M | F-014 |
| F-109 | Server grouping + labels | Organization | S | S | F-004 |
| F-110 | Confirm-inline actions with undo-style feedback | UX polish | S | S | F-011 |
| F-111 | Terminal session reconnect within app | Reliability | S | M | F-013 |
| F-112 | Log level filter + search | Log usability | S | M | F-012 |
| F-113 | Remote logout / revoke device | Security control | S | S | F-018 |
| F-114 | Audit log view (agent-side actions) | Accountability | S | M | F-002 |

## 3. Nice to Have (if time; otherwise v1.1)

| ID | Feature | Purpose | Priority | Complexity | Dependencies |
|----|---------|---------|----------|-----------|--------------|
| F-201 | mDNS/LAN auto-discovery of agents | Zero-config LAN | N | M | F-002, platform NSD |
| F-202 | Accent color customization | Personalization | N | XS | Theme system |
| F-203 | Widgets (iOS) / shortcuts (Android) glanceables | Quick glance | N | L | F-008 |
| F-204 | Terminal share/export session log | Collaboration | N | S | F-013 |
| F-205 | Container create/edit (limited, compose-based) | Provisioning | N | XL | F-010 |
| F-206 | Notifications channel per server type | Granular alerting | N | S | F-015 |
| F-207 | Widget: single-server status tile | Glance | N | M | F-008 |
| F-208 | Haptics on critical alerts | Tactile feedback | N | XS | Notifications |

## 4. Future Version (explicitly NOT v1)

| ID | Feature | Target | Complexity | Notes |
|----|---------|--------|-----------|-------|
| F-301 | Multi-user agent + RBAC | v2 | XL | Design hooks reserved in [09](./09-architecture.md) |
| F-302 | AI operations copilot (summaries, triage, NL commands) | v2 | XL | No AI in v1 by mandate |
| F-303 | Push notifications via user-configured relays (ntfy/apns via self-host) | v2 | M | Requires relay; violates zero-cloud unless self-hosted |
| F-304 | Plugin architecture + catalog | v3 | XL | Architecture-only hooks in v1 |
| F-305 | Desktop companion app | v3 | XL | — |
| F-306 | Proxmox / VM management plugin | v3 | L | Plugin path |
| F-307 | Kubernetes / multi-host views | v3 | XL | — |
| F-308 | SSO/SAML, SIEM export | Enterprise | XL | — |
| F-309 | Non-Docker workload monitoring (services, processes) | v3 | L | — |

## 5. Feature dependency graph (Must + Should, simplified)

```
Agent core (F-002)
   ├── Metrics collector (F-007) ───> Dashboard (F-006) ───> Live stream (F-008)
   │                                       └──> Alert engine (F-015) ───> History (F-016)
   ├── Docker module (F-010) ───> List (F-009) ───> Actions (F-011)
   │                             └──> Logs (F-012) ───> filter/search (F-112)
   ├── Terminal module (F-013) ───> themes/copy (F-107), reconnect (F-111)
   └── FS module (F-014) ───> transfer (F-108)
Auth (F-018) ───> pairing (F-003) ───> profiles (F-004) ───> CRUD (F-005)
Secure storage (F-017) ───> biometric (F-101), remote logout (F-113)
Theme (F-020) ───> design system (07)
```

## 6. Capacity planning (v1 estimate)

- **Total Must:** ≈ 22 features. Rough estimate: **10–14 developer-weeks** of app + agent work (excluding polish), assuming 2 engineers (1 Flutter, 1 Go) in parallel where dependency graph permits.
- **Total Should:** ≈ 8–12 developer-weeks additional.
- See [17-roadmap.md](./17-roadmap.md) for milestone mapping.

## 7. Feature ownership & sign-off

- Every Must feature requires a design brief (UX) + implementation spec (eng) + test plan (QA) before entering a milestone.
- Feature is "Done" only when its acceptance criteria pass and its documentation is updated (Definition of Done in [01-vision.md](./01-vision.md) §10).
