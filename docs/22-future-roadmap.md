# 22 — Future Roadmap

**Project:** qwe1
**Status:** `[DECIDED]` (v1 scope is closed; v2/v3 are directional)
**Owner:** Product

> This document is intentionally **directional**, not committed. v1 is the contract; everything below is the horizon. **No AI features exist in v1.** AI appears only here, clearly labelled as future.

---

## 1. Version 2

### Themes
- **Multi-user & roles** — agent-side accounts, RBAC (admin/operator/read-only/viewer), per-user read-only, shared agents across devices.
- **Alerting independence** — self-hosted push relays: ntfy-first-class, optional webhook fan-out, and a user-run relay for true push when offline.
- **Smarter operations** (still human-controlled):
  - **AI-assisted operations (labelled, opt-in):** log-burst summaries, alert triage suggestions, natural-language Docker actions that *propose* commands for explicit confirmation. All AI runs on the user's chosen model (local via Ollama, or user-configured provider); **no vendor-default AI backend.**
  - Pre-flight dry-runs for container actions.
- **Server discovery** — mDNS/LAN discovery of agents (still fingerprint-confirmed).
- **Notifications** — richer channels (per-server alert noise control), notification summaries.
- **Desktop companion** (first pass) — web app sharing the agent API.

### Architecture implications (planned in v1)
- Auth layer separates device identity from user roles (token claims `aud`/scope reserved).
- Agent modules already isolated → RBAC is additive.
- Relay plugs in behind the same API contract.

## 2. Version 3

- **Plugin architecture** — typed agent capability modules + a community catalog; app renders plugin surfaces via a declarative manifest. (v1's module boundaries are the plugin seams.)
- **Broader workloads** — non-Docker services/processes monitoring, systemd unit control, Proxmox/VM agent plugin, K8s (read-only views first).
- **Desktop companion** (full) — Flutter web/desktop reusing app code.
- **Local-first web UI** — optional thin web console served by the agent for LAN browser access.

## 3. Enterprise possibilities (directional)

- **SSO/SAML/OIDC** via pluggable token verification (auth layer already supports external verification as a hook).
- **Audit export** to SIEM (syslog/JSON stream), compliance reports, retention policies.
- **Fleet management** — an optional manager that coordinates many agents (a **user-run** component; still no vendor cloud).
- **Support tiers / consulting** — separate from the open-core license (see [01-vision.md](./01-vision.md) §9 for the license strategy discussion).

## 4. Plugin architecture (future sketch)

```
qwe1-agent (core: auth, http, ws, config)
 ├── plugins/  ── capability modules (host, docker, terminal, fs today)
 └── manifests ── JSON describing actions/realtime channels/UI surfaces
app ── renders plugin surfaces from manifest + icons
catalog ── community-curated (v3)
```

Constraints recorded now: plugins must be **sandboxed** (separate process or strict capability grants), signed, and versioned against the agent's API.

## 5. AI integration (future only — NOT in v1)

Where AI would land, when it arrives:

| Capability | v2 (proposed) | Guardrails |
|------------|---------------|------------|
| Log summary / anomaly highlight | Summarise bursts; highlight anomalies | Never auto-act; read-only output; on-device or user model |
| Alert triage suggestions | Rank + explain alerts | Transparent reasoning; user confirms |
| Natural-language Docker ops | Translate NL → proposed command | Explicit confirmation; dry-run preview; audit-logged |
| Terminal assistant | Suggest commands (read-only) | No auto-execution; context scoped |

**Hard rules (recorded for v2):** AI never executes actions without explicit human confirmation; AI is always opt-in; the user chooses the model and the data never leaves their chosen runtime by default. The v1 data path contains **no AI hook**.

## 6. Versioning & compatibility outlook

- v1 API (`v1`) remains supported through v2 via a compatibility layer; major bumps documented in release notes.
- Plugins pin API versions; agent/app compatibility matrix in [09-architecture.md](./09-architecture.md) §6.

## 7. What we will NOT do (future-proofing)

- No vendor cloud relays (user-run relays only).
- No AI default-on, no AI vendor lock-in, no AI telemetry.
- No closed-source core (AGPL forever; optional enterprise add-ons remain transparent about licensing).
