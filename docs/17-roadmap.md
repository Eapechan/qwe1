# 17 — Development Roadmap

**Project:** qwe1
**Status:** `[DECIDED]` (estimates are planning-level, not commitments)
**Owner:** Product / Engineering

> Estimates assume **2 full-time engineers** (1 Flutter, 1 Go) + part-time design. Calendar = "weeks of focused effort". Parallelizable tracks are marked ⚡.

---

## Milestone map

```
M0 Discovery ─► M1 Foundation ─► M2 Realtime ─► M3 Ops ─► M4 Hardening ─► M5 Beta ─► M6 GA
                 ⚡app/agent        ⚡        ⚡docker/fs   ⚡security
```

| Milestone | Theme | Duration | Entry criteria | Exit criteria |
|-----------|-------|----------|----------------|---------------|
| M0 | Discovery & setup | 2 wks | — | Repo scaffold, CI, OpenAPI v0, design tokens, ADRs for `[OPEN]` items |
| M1 | Foundation | 4 wks | M0 | Auth (enroll/refresh/revoke) + pairing QR + profiles + dashboard w/ static host metrics + secure storage + both themes |
| M2 | Realtime | 3 wks | M1 | WS multiplexer, live metrics stream, docker list/status + events, alert engine + history + local notifications |
| M3 | Operations | 5 wks | M2 | Docker actions + logs + inspect; terminal (PTY); file browser (allow-list) + transfers |
| M4 | Hardening & polish | 4 wks | M3 | Security checklist (§17 of [14](./14-security-architecture.md)), offline strategy, error/empty states, a11y pass, perf pass, i18n framework |
| M5 | Beta | 3 wks | M4 | Closed beta ≥ 50 testers, 2+ weeks, crash-free ≥ 99.5%, all AC pass, docs published |
| M6 | GA | 2 wks | M5 | Release (stores + agent tags), release notes, SBOM, changelog, marketing/landing |

---

## M0 — Discovery & setup (2 wks)
- **Objectives:** de-risk unknowns; lock the contract; set up engineering quality rails.
- **Deliverables:**
  - Monorepo scaffold (`app/`, `agent/`, `api/`, `scripts/`, CI workflows).
  - OpenAPI `v1` skeleton with review against [11-api-design.md](./11-api-design.md).
  - Design tokens + component library skeleton ([07](./07-design-system.md)).
  - ADRs resolving all `[OPEN]` items (terminal renderer, mTLS toggle, IP binding, mkdocs vs vitepress).
  - Agent CI: build matrix proof (armv7/arm64/amd64 static).
  - Install script + Dockerfile v0.
- **Dependencies:** none.

## M1 — Foundation (4 wks)
- **Objectives:** vertical slice: enroll → see a server's static metrics on the dashboard.
- **Deliverables:**
  - Agent: TLS + self-signed CA + enroll/refresh/revoke + rate limiting + audit skeleton; host module (CPU/RAM/disk/temp/uptime) with capability detection.
  - App: secure storage, TokenManager, dio interceptors, Riverpod scaffolding, add-server (QR + manual + fingerprint confirm), server profiles (Drift), dashboard + server detail (static), empty/error states, dark/light themes.
  - Contract tests for auth endpoints.
- **Exit:** US-01–US-06 pass; 10-min onboarding demo works end-to-end.
- **Dependencies:** M0.

## M2 — Realtime (3 wks)
- **Objectives:** make the app "alive": live metrics, live container state, alerts.
- **Deliverables:**
  - Agent: WS multiplexer (metrics/alerts/docker/logs channels), alert engine + thresholds + buffer + webhook/ntfy, docker module (list/inspect/events/stats).
  - App: WS client + per-channel streams, live charts (fl_chart), docker list + status chips, alerts screen + history + local notifications, reconnection logic.
- **Exit:** AC-02, AC-06 pass; live dashboard demo on LAN.
- **Dependencies:** M1.

## M3 — Operations (5 wks)
- **Objectives:** the "control" half: docker actions, logs, terminal, files.
- **Deliverables:**
  - Agent: docker lifecycle actions + remove, logs (tail/stream) with limits, PTY terminal module (sessions, resize, force-close, concurrency caps), FS module (allow-list, list/read/write/rename/delete/upload) with path safety, audit of mutations.
  - App: container detail + confirm sheets (destructive typing), logs view (filter/search/stream), terminal UI (themes, modifier bar, reconnect), file browser (browse/preview/transfer/multi-select), read-only enforcement UI.
- **Exit:** AC-03, AC-04, AC-05 pass.
- **Dependencies:** M2.

## M4 — Hardening & polish (4 wks)
- **Objectives:** production-readiness.
- **Deliverables:**
  - Full security checklist pass ([14](./14-security-architecture.md) §17): revoke flows, brute-force tests, replay tests, docker env masking, fuzzing (path/input), secret scan.
  - Offline strategy: cache staleness UX, config-only offline queue, reconnect reconcile.
  - Error/empty/success state coverage, a11y pass (labels, contrast, scaling, reduce-motion), perf pass (cold start, memory caps, list virtualisation), i18n framework (English).
  - Docs: install guide, user guide, API docs refresh, troubleshooting.
- **Exit:** all non-blocking issues from M5-tracker cleared; performance targets met.
- **Dependencies:** M3.

## M5 — Beta (3 wks)
- **Objectives:** validate in the real world; stabilise.
- **Deliverables:**
  - TestFlight + Play (internal/closed) builds; beta cohort ≥ 50 (homelab/docker/sysadmin personas).
  - Telemetry opt-in (aggregate only) for crash-free + activation measurement.
  - Bug triage cadence (daily), release-candidate discipline.
  - Documentation site published (user + admin guides).
- **Exit:** 2+ weeks stable; ≥ 99.5% crash-free; 0 critical open; AC-01…AC-10 pass on reference devices; security checklist green.
- **Dependencies:** M4.

## M6 — GA (2 wks)
- **Objectives:** ship.
- **Deliverables:** App Store + Play + F-Droid submission; agent v1.0.0 release (goreleaser, signed, SBOM); landing page; changelog; announcement posts; handoff to v2 planning.
- **Exit:** v1.0.0 live; adoption metrics instrumented (opt-in).
- **Dependencies:** M5.

---

## Cross-cutting track: Security
- Security work is **continuous**, not a milestone: threat-model review at M1, auth hardening at M2/M3 (with the ops features that create attack surface), full checklist at M4. Security **gates** every milestone exit.

## Cross-cutting track: Docs & design
- Docs updated with every feature as it lands (Definition of Done, [01-vision.md](./01-vision.md) §10).
- Design QA per milestone (contrast, both themes, a11y, motion).

## Dependencies & risk watch
- **Critical path:** M1 → M2 → M3 → M4 → M5 → M6 (app). Agent tracks in parallel where independent (host module, then docker, then terminal/fs).
- **Biggest schedule risks:** terminal UX quality (R-6 in [03-prd.md](./03-prd.md)), agent ↔ app contract drift (mitigated by OpenAPI + contract CI), iOS review friction for terminal/keyboard edge cases.
- **Buffer:** ~15% total; fold into M4 if all is green.
