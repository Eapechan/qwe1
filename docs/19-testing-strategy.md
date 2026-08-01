# 19 — Testing Strategy

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Engineering / QA

---

## 1. Test pyramid & targets

```
        ┌──────────────┐  Manual QA + Beta (human)
       /│  E2E          │  integration_test (app), agent e2e
      / │──────────────│  ← ~5% automated coverage target
     /  │  Integration  │  contract tests, docker/pty/fs integration
    /───│──────────────│
   /   Widget/Golden   │  screens, flows, themes
  /─────────────────────│
 /      Unit (core)     │  domain, providers, repositories, auth, alerts, path-safety
┌───────────────────────┐
```

| Level | Target | Where |
|-------|--------|-------|
| Unit | **≥ 80%** line coverage on domain + state + security-critical agent code (auth, path safety, alerts, token lifecycle) | `app/test/unit`, `agent/.../*_test.go` |
| Widget/Golden | Key screens (dashboard, docker, logs, terminal, files, settings, errors) | `app/test/widget`, `app/test/golden` |
| Integration | App: repos vs fake agent (contract); Agent: docker socket, PTY, fs, rate limits | `app/integration_test`, `agent` `_test.go` |
| Contract | App & agent validate against `api/openapi.yaml` | `contract` CI job |
| E2E/Manual | Release-candidate pass on reference devices | manual + beta |

## 2. Unit tests

### App
- Domain: use cases, alert severity, offline policy, path validation.
- Providers/notifiers: state transitions, optimistic updates, error mapping (mocktail).
- TokenManager: refresh/rotation/expiry/revocation logic (fake clock).
- Pure fns: fingerprint formatting, metric formatting (tabular), units.

### Agent
- Auth: enrollment one-time, refresh rotation, reuse detection, lockout (with fake clock).
- Path safety: traversal, symlink escapes, allow-list normalization (table-driven + fuzzing).
- Alert rules: threshold + duration debounce semantics.
- Token lifecycle: hashing, revocation, TTL edge cases.
- **Fuzzing:** `fs path`, `enrollment token` parser, `docker filter` parser, WS frame parser (Go native fuzzing in CI, short duration).

## 3. Integration tests

### Agent
- **Docker:** spin disposable docker engine (`testcontainers-go`) → real start/stop/restart/logs/list/inspect/events; verify read-only enforcement returns 403.
- **Terminal:** real PTY → spawn `/bin/sh`, echo round-trip, resize, force-close, concurrency cap (429).
- **FS:** real temp dirs as roots → list/read/write/rename/delete/upload; traversal → 403; permission-denied propagation.
- **Auth e2e:** enroll → call → refresh → rotate → revoke → 401.

### App
- Repository tests against a **fake agent** (in-process mock implementing the contract) — verifies offline cache, staleness, offline-op queue flush, reconnect reconcile.
- `integration_test` on device/emulator: onboarding→add server→dashboard→docker restart→logs→terminal→files happy path against a local agent (CI-run on Linux, manual on iOS).

## 4. Widget & golden tests

- Widget: each `SC-*` screen with mocked providers — states: loading, data, empty, error, offline-stale, read-only (buttons disabled).
- Golden: dark/light snapshots for key screens to catch regressions; approve-on-change workflow documented.

## 5. Contract tests

- OpenAPI `api/openapi.yaml` is authoritative.
- **Agent:** generated server assertions (or hand-rolled) — every handler tested against the spec (status codes, schemas, error envelope).
- **App:** generated client mocks validate request/response shapes in CI.
- Both run in `contract.yml` on any `api/**`, `agent/**`, `app/**` change.

## 6. Security tests

- Replay: refresh token reuse → revoke; access token replay → rejected.
- Brute force: enroll/refresh lockout timing.
- Rate limiting: headers + 429 behavior.
- TLS: handshake against wrong-fingerprint cert → blocked; TLS < 1.2 → refused.
- Path traversal fuzz (already in §2).
- Read-only middleware: every mutating route returns 403 in read-only.
- Dependency scan: `govulncheck`, OSV scanner; gitleaks on all pushes.
- These map 1:1 to [14-security-architecture.md](./14-security-architecture.md) §17 checklist.

## 7. Performance tests

- App: cold start (< 2s) and dashboard render (< 3s) measured on a mid-range reference device in CI (`integration_test` + metric assertions).
- Memory: container list 200+ containers, log stream 1000 lines — assert no unbounded growth (bounded buffers).
- Terminal latency: LAN round-trip assertion (< 200ms) in integration harness.
- Agent: idle CPU/RSS assertions in CI (linux runner).

## 8. API tests

- Covered by contract tests (§5) + integration; plus:
- Idempotency-key behavior; pagination (`cursor`); 426 on version mismatch; error envelope shape on all failure modes.

## 9. Manual QA & beta

- **QA checklist** per release (docs/qa-checklist.md): onboarding, add/remove server, offline, read-only, terminal edge cases (multiline paste, resize, disconnects), file transfer, notifications, both themes, a11y (VoiceOver/TalkBack), reduced motion.
- **Beta:** TestFlight + Play internal/closed. ≥ 50 users, ≥ 2 weeks (M5). Crash-free ≥ 99.5%; every reported bug triaged; release-candidate gating.
- **Reference devices (manual):** iPhone (latest + one older), mid-range Android, low-end Android.

## 10. CI wiring

| Job | Runs | Gates |
|-----|------|-------|
| `ci-app` | analyze, unit, widget, golden, (linux) integration | PR merge |
| `ci-agent` | vet, staticcheck, unit+integration (docker/pty/fs), fuzz (short) | PR merge |
| `contract` | OpenAPI validation both sides | PR merge (api/agent/app changes) |
| `security` | gitleaks, govulncheck, OSV, dep audit | PR + nightly |
| `perf` | reference-metric assertions | main + release |
| `release` | full suite + e2e, goreleaser, SBOM | tag |

## 11. Coverage reporting

- `coverage` comments on PRs (app: `lcov`; agent: `go tool cover`).
- Decline in coverage on new code fails the required check (soft threshold 80% on new code).
