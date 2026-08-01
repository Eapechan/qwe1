# 02 — Market Research

**Project:** qwe1
**Status:** `[DECIDED]` — analysis complete; positioning locked in for v1
**Owner:** Product / Strategy

---

## 1. Research method

- Competitor categories studied: **Docker management UIs**, **self-hosted dashboards**, **Linux server management**, **proxmox/mobile solutions**, **mobile SSH clients**.
- Analysed as **experiences** (design, onboarding, UX) and as **products** (features, architecture, licensing), with a focus on the *mobile* experience, because that is qwe1's wedge.
- Where mobile UIs do not exist, we evaluated the closest product category and noted the mobile gap.

---

## 2. Competitive landscape

| Product | Category | Platform | Open source | Mobile app | Model |
|---------|----------|----------|-------------|------------|-------|
| Portainer | Docker management | Web | Yes (Zlib) | PWA only | Self-hosted |
| Dockge | Docker Compose management | Web | Yes (MIT) | No | Self-hosted |
| CasaOS | Home server OS + dashboard | Web | Yes (Apache 2.0) | No | Self-hosted OS |
| Yacht | Docker management | Web | Yes (MIT) | No | Self-hosted |
| Cockpit | Linux server admin | Web | Yes (LGPL) | PWA/limited | Self-hosted |
| Homarr | Dashboard | Web | Yes (GPL-3) | No | Self-hosted |
| Cosmos Server | Cloud-native dashboard & stack | Web | Yes (Apache 2.0) | No | Self-hosted |
| Proxmox VE | Virtualization platform | Web | Yes (AGPL) | Third-party only | Self-hosted |
| Termius | SSH client | Mobile + Desktop + Web | No | Yes | SaaS + freemium |
| ServerCat / Termius-like | Server manager | Mobile | No | Yes | SaaS |
| Gatus / Uptime Kuma | Uptime monitoring | Web | Yes | Notifications only | Self-hosted |

---

## 3. Product-by-product analysis

### 3.1 Portainer
- **Pros:** Mature, feature-rich, huge community, excellent container UX (stacks, images, volumes, networks), role-based access, edge agent support, multi-environment.
- **Cons:** Web-first; mobile experience is a PWA at best. Heavier deployment (its own stack). Complex for the "I just want status + restart" user. UI is dense and desktop-oriented. Edge-agent telemetry model requires a Portainer instance somewhere (cloud or self-hosted) as a hub.
- **Missing features (for our users):** Native mobile feel, SSH terminal built-in as a first-class mobile flow, touch-first design, offline-friendly cache, per-server status from a single phone screen.
- **Opportunity:** qwe1 is *mobile-native* where Portainer is *web-native ported to mobile*.

### 3.2 Dockge
- **Pros:** Beautiful, focused, compose-file-first workflow, clean "status" overview, MIT.
- **Cons:** Compose-only (no raw `docker run`, images, volumes management), web-only, no mobile app, no monitoring/alerting beyond container state, no terminal.
- **Opportunity:** Dockge nails *compose editing*; qwe1 is not an editor. We take the clean aesthetic and add the operations layer (lifecycle, logs, health) that Dockge deliberately omits.

### 3.3 CasaOS
- **Pros:** Beautiful web UI, app-store concept for homelab apps, great onboarding for Linux novices.
- **Cons:** It's an *operating system/framework* — it wants to own the box. Not a management client for arbitrary existing servers. Web-only. Storage-centric (ZeroOS) model differs from a general remote-management tool.
- **Opportunity:** CasaOS proved the market wants *beautiful, simple* self-hosted UIs. qwe1 brings that beauty to the phone and to *any* existing server.

### 3.4 Yacht
- **Pros:** Simple Docker UI, templates, MIT.
- **Cons:** Smaller community, slower development, web-only, minimal monitoring, no terminal/files, mobile is an afterthought.
- **Opportunity:** Yacht shows a simple Docker UI is feasible; it also shows the ceiling of a web-only, low-community project. qwe1's mobile-native approach and monitoring layer differentiate.

### 3.5 Cockpit
- **Pros:** The reference for Linux system administration. Wide module ecosystem, terminal, logs, storage, powerful. Battle-tested by RHEL ecosystem.
- **Cons:** Desktop/designed-for-big-screens. PWA mobile support is minimal and awkward. Auth model (PAM/user accounts) is server-admin oriented, not consumer. Styling is utilitarian.
- **Opportunity:** Cockpit validates the *system-management* feature set (terminal, storage, logs). qwe1 repackages the same core needs for a phone and for consumer homelab users, with a purpose-built agent instead of PAM-based auth.

### 3.6 Homarr
- **Pros:** Pretty dashboard, widget system, GPL-3, integrates many services' status.
- **Cons:** A *dashboard of links/status tiles*, not a management plane. No actions (restart, terminal, files). Web-only.
- **Opportunity:** Homarr is glanceable; qwe1 is glanceable **and actionable**. We can later absorb the "dashboard" pattern (v3 desktop companion).

### 3.7 Cosmos Server
- **Pros:** Modern, ambitious (cloud-native stacks, git-based deploys, apps), active development, Apache 2.0.
- **Cons:** Opinionated deployment model (its own manager on the box), web-first, targets advanced users, mobile app absent.
- **Opportunity:** Cosmos targets *managed stacks*; qwe1 targets *any existing server* with a phone-first experience. Complementary more than competing.

### 3.8 Proxmox VE (mobile)
- **Pros:** Full virtualization management, AGPL, strong API, powerful web UI.
- **Cons:** No official mobile app; third-party mobile apps are limited, unpolished, or stale. Caters to VM/CT admins, not Docker/homelab users.
- **Opportunity:** Proxmox's weak official mobile story is a gap. qwe1 is not a Proxmox client (that is a v3 possibility via plugin), but the *standard for a good self-hosted mobile client* is unclaimed.

### 3.9 Termius and closed-source mobile SSH/server managers
- **Pros:** Polished mobile UX, terminal + snippets + port forwarding, great onboarding, reliable. The UX bar to match.
- **Cons:** Closed source, SaaS-centric, subscription for the good features, cloud account dependency, no Docker/monitoring (Termius is terminal-focused), no local-first posture.
- **Opportunity:** These products proved people will pay for a great mobile server UX. qwe1 is the open, privacy-first, self-hosted answer with a broader feature set.

### 3.10 Uptime Kuma / Gatus
- **Pros:** Excellent uptime monitoring with notification channels, self-hosted, open.
- **Cons:** Uptime-focused only; no server management, no Docker, no terminal, no files. Not a control plane.
- **Opportunity:** qwe1 includes the monitoring/alerting core (agent-side) *and* the control plane in one app.

---

## 4. Synthesis: the real gap

The market has, broadly:

1. **Beautiful web dashboards** (Homarr, CasaOS, Dockge) — not mobile, not actionable.
2. **Powerful web admin** (Cockpit, Portainer) — not mobile-first, complex, dense.
3. **Good mobile SSH** (Termius et al.) — closed source, SaaS, terminal-only.
4. **Uptime monitors** — monitors, not control planes.
5. **No official mobile** (Proxmox) — gap waiting to be filled.

**No product delivers all of these simultaneously:**
- Native mobile experience
- Open source
- Zero cloud / privacy-first
- Monitoring **and** alerting **and** Docker **and** terminal **and** files
- Multiple servers from one phone
- Simple enough for a homelab beginner, capable enough for an admin

**qwe1's wedge: "Termius-grade mobile UX × Portainer-grade Docker ops × Cockpit-grade system insight × Zero cloud — open source."**

---

## 5. SWOT

### Strengths (inherited)
- Combination of categories no competitor matches (esp. in open source).
- Privacy-first / zero-cloud is a durable moat and marketing message.
- Mobile native is genuinely better for on-the-go server ops (alerts in the pocket).
- Open source builds trust with exactly the target audience (self-hosters).

### Weaknesses (to be honest about)
- New project: no brand, no community yet.
- Mobile-only means we compete with desktop-first incumbents who have huge feature depth.
- Agent install on user's server is a *trust* and *friction* moment; onboarding must be excellent.
- No push infrastructure means alerts rely on app being reachable (mitigated by webhook/ntfy).

### Opportunities
- Explosive growth of homelab + self-hosting hobby (mini-PCs, N100 boxes, cheap VPS).
- Dissatisfaction with subscriptions (Termius) and cloud-required tooling.
- Proxmox/Cockpit mobile gap.
- AI (v2) can create a genuinely differentiated "operations copilot" once the v1 foundation exists.

### Threats
- Portainer/others shipping a real mobile app.
- New competitors from the AI-wave (AI shell tools) grabbing mindshare.
- Fragmentation of the Linux/Docker ecosystem (podman, nerdctl, orchestration).
- Security perception risk: remote-management tools are high-value targets; one bad CVE hurts trust.

---

## 6. Differentiation strategy (what qwe1 does differently)

| Dimension | Incumbents | qwe1 |
|-----------|-----------|------|
| Platform | Web-first, PWA | **Native mobile (Flutter), iOS + Android** |
| Architecture | Hub/manager app you must run | **Thin agent per server, app connects directly** |
| Cloud | Often requires their service or accounts | **Zero cloud; user-owned everything** |
| Open source | Mixed (some closed, some permissive) | **AGPL-3.0, community-run** |
| Scope | Terminal OR Docker OR monitoring OR dashboard | **Monitoring + Docker + terminal + files + alerts in one** |
| Onboarding | Install a big stack | **Single small agent binary, QR pairing** |
| Offline | Thin or none | **Local cache, last-known state, offline-queued actions** |

## 7. Positioning statement

> **qwe1 is the open-source server app for your phone.** Monitor, manage Docker, drop into a terminal, and browse files on all your Linux servers — from one app, with zero cloud, and everything encrypted to an agent you run yourself.

## 8. Risks this research surfaced (tracked in PRD)

- R1 — The feature set is broad (monitoring + docker + terminal + files). **Risk:** scope creep kills v1. **Mitigation:** strict Must/Should/Nice prioritisation ([04-feature-planning.md](./04-feature-planning.md)); terminal + file browser are Must-Have but built to a defined subset.
- R2 — Agent trust/friction on install. **Mitigation:** one-liner install, QR enrollment, transparent open-source auditability.
- R3 — Alerting without push. **Mitigation:** agent-side alert buffer + optional webhook/ntfy; document expectation clearly.
- R4 — Security perception. **Mitigation:** the depth of [14-security-architecture.md](./14-security-architecture.md) and a visible security policy.
