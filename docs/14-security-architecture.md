# 14 — Security Architecture

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Security (all teams)
**Severity:** This document is normative. Features may not ship without meeting its controls.

---

## 1. Security posture statement

qwe1 is a **remote management tool for user-owned infrastructure** — an inherently high-value target (access to a terminal on the user's server ≈ access to that server). The threat model therefore assumes a **capable, networked adversary** (not a nation-state) and treats the phone and the server as hostile-to-compromise endpoints. The default configuration must be secure; optional features must never weaken the default.

**Core invariant:** *No credential or plaintext secret ever leaves the user's devices except over TLS to a verified (pinned) agent, and no action is ever authorized without a valid, unexpired, non-revoked device token.*

---

## 2. Threat model

### 2.1 Assets

| Asset | Sensitivity | Where it lives |
|-------|-------------|----------------|
| Agent access tokens / refresh tokens | Critical | Phone (secure storage), agent (hashed) |
| Enrollment tokens | Critical (one-time) | Server terminal, in transit |
| Server identity (fingerprint) | Medium | Phone, server |
| Docker control capability | Critical | Agent ↔ Docker socket |
| Terminal / shell access | Critical | Agent PTYs |
| File contents on server | High | Agent FS module |
| Metrics / host info | Low–Medium | Agent, phone cache |
| Audit log | Medium | Agent |

### 2.2 Adversaries & attack vectors

| # | Adversary | Vector | Likelihood | Impact |
|---|-----------|--------|-----------|--------|
| T-1 | Random internet scanner | Scanning for exposed agent port; brute force /auth | High | Medium (blocked by rate limits, lockout, no passwords) |
| T-2 | Compromised app device (lost/stolen phone) | Biometric bypass, keychain extraction (jailbroken), shoulder surf | Medium | High (remote revoke, biometric gate, short tokens) |
| T-3 | Network attacker (Wi-Fi MITM, DNS spoof) | TLS downgrade, cert spoof, WS token sniff | Medium | High (TLS 1.3, pinning, WS token short-lived) |
| T-4 | Malicious actor with temporary device access (spouse/colleague) | Operates app while unlocked, destructive actions | Medium | High (read-only mode, confirm-typing, audit log) |
| T-5 | Server-side attacker (compromised agent host) | Reads tokens from agent disk, abuses Docker socket | Medium | Critical (tokens hashed; Docker already root-equivalent; defense: least privilege + isolate agent) |
| T-6 | Supply chain (malicious dependency / release tamper) | Poisoned dependency, fake release | Low | Critical (SBOM, signed releases, dependency scanning) |
| T-7 | Replay / race attacker | Replay access token, reuse refresh token, race enrollment | Low | Medium (short TTL, rotation + reuse detection, one-time tokens) |
| T-8 | Phishing / social engineering | Trick user into visiting malicious "qwe1" tool, fake QR | Medium | High (out-of-band fingerprint verification, never auto-trust) |

### 2.3 Attack surface inventory

- **Agent:** HTTP/WS listener (publicly reachable by design when user exposes it); enroll/auth endpoints; docker/terminal/fs modules; config parser; TLS layer.
- **App:** networking stack, deep links, file pickers, secure storage, notification handling, biometrics.

---

## 3. Transport security (TLS & pinning)

1. **Protocols:** TLS 1.3 only; TLS 1.2 as fallback; **no** TLS < 1.2, **no** SSL, **no** plaintext HTTP by default.
2. **Ciphers:** forward-secret suites only (ECDHE), AEAD (AES-256-GCM / ChaCha20-Poly1305). Agent config validated at start; insecure config rejected.
3. **Certificate:** agent generates a **self-signed leaf + local CA** at first run. No external CA dependency (user-owned trust domain).
4. **Pinning (TOFU + confirmation):**
   - At enrollment, app records the agent's **certificate SHA-256 fingerprint**.
   - The fingerprint is displayed for **out-of-band comparison** (SC-17) — the user confirms it matches what the server printed.
   - Every connection verifies the leaf cert against the recorded fingerprint (pinning) **plus** OS-chain validation.
5. **Fingerprint change:** any mismatch → hard block (SC-05 style), never silent accept. User must explicitly confirm a changed fingerprint (documented as a deliberate, user-visible action) or re-enroll.
6. **WS security:** WSS (wss://) only; access token in connect query (short-lived, ≤ 15m), connection tied to device identity.
7. **DNS/SNI:** agent IP/URL entered by user; no reliance on public DNS trust (pinning covers it). mDNS discovery (NTH) must still require fingerprint confirmation — never auto-trust.

---

## 4. Key storage

| Key | Storage | Mechanism |
|-----|---------|-----------|
| Agent private key (signing) | Server disk | `0600`, owned by agent user; regenerable via `qwe1-agent init`; optional TPM-backed `[OPEN]` |
| App access token | Memory | Riverpod state; cleared on lock |
| App refresh token | `flutter_secure_storage` | iOS Keychain (`kSecAttrAccessibleAfterFirstUnlock`), Android EncryptedSharedPreferences backed by Android Keystore |
| App encryption key (DB) | OS-managed | Keychain/Keystore; not app-visible (see [12](./12-database-design.md)) |
| Enrollment token | Transient | Server terminal + app memory during flow; TTL 10m |

**Rules:** No secret in SQLite, no secret in logs, no secret in crash reports, no secret in `SharedPreferences` (plain), no secret in config files.

---

## 5. Session management

| Concern | Policy |
|---------|--------|
| Access token TTL | 15 minutes |
| Refresh token TTL | 30 days (rolling; sliding activity resets) |
| Rotation | Every refresh issues new refresh token; old invalidated; **reuse detection** → revoke device + audit |
| Max devices | Configurable per agent (default 8) |
| Concurrent sessions | Terminal sessions capped (default 4); WS connections capped |
| Session end | Lock (biometric), remote logout, agent restart (tokens survive agent restart by design — hash-persisted), app clear data |
| Clock skew | `iat`/`exp` enforced with ≤ 60s skew |

---

## 6. Device registration & identity

- Each enrolled device has a unique `deviceId` (server-generated at enrollment), carried in every JWT (`sub`) and on every refresh.
- **Device fingerprint** (anonymized, local) binds app install → device; used for biometric prompt decisions.
- **Revocation:** `/auth/revoke` kills all tokens + WS for that device; app "Remove server" best-effort revokes then wipes local state.
- **Lost phone:** revoke from another enrolled device (v1.1) or re-run `qwe1-agent enroll --revoke-all` on the server (v1).

---

## 7. Biometric authentication

- **Purpose:** local gate to the app (SC-19), not a substitute for agent auth. Prevents shoulder-surf / lost-phone misuse.
- **Enrollment:** optional, opt-in, stored as a secure-storage flag. Uses platform `local_auth` (Face ID / Touch ID / Android Biometric).
- **Fallback:** device PIN/pattern (platform). **In-app PIN (custom)** is explicitly NOT implemented (custom PINs are weaker and introduce their own storage).
- **Policy:** fail-closed on biometric error; app stays locked; "Unlock" retry with hysteresis (max 5 attempts per 30s, then require device unlock).
- **Android strong-auth consideration:** use `BIOMETRIC_STRONG` when available; `BIOMETRIC_WEAK` optional but flagged.

---

## 8. Read-only mode & role-based permissions

- **v1 model:** one operator (the enrolling device) + optional per-server **read-only mode** toggle.
- **Enforcement:**
  1. **UI:** hides/disables mutating actions.
  2. **Client API layer:** refuses to dispatch mutating calls (defense in depth, not security).
  3. **Agent middleware:** **authoritative** — mutating routes return `403 READ_ONLY` even if a compromised client calls them.
- Mutating routes set: docker mutations (start/stop/restart/pause/kill/remove), fs writes (write/mkdir/rename/delete/upload), terminal **input** (read-only PTY allowed? No — terminal is inherently mutating; disabled entirely in read-only), alert threshold writes, audit is read-only.
- **RBAC (multi-user roles)** is v2; the auth/authorization layer is designed to add roles without refactor (token claims carry an `aud`/scope list — reserved).

---

## 9. Remote logout & revocation

- `/auth/revoke` (per device) and `qwe1-agent enroll --revoke-all` (server-side) both:
  - Invalidate all refresh tokens (hashed store) for the device(s).
  - Terminate active WS sessions for those devices.
  - Record audit entries.
- App-side "Remove server" = best-effort revoke + local wipe (profiles, cache, secure-storage tokens, biometric flag).

---

## 10. Audit logging

| Event class | Examples | Retention |
|-------------|----------|-----------|
| Auth lifecycle | enroll, refresh rotation, reuse-detection, revoke, lockout | Agent ring (default 1000), configurable |
| Mutations | container start/stop/restart/kill/remove, fs delete/rename/write/upload, threshold change | same |
| Sessions | terminal create/close, WS connect/disconnect | same |
| Read-only violations | attempted mutating call in read-only | same |

- Entry: `ts, actor(deviceId), action, target, result, ip`. No payload contents.
- Exposed read-only to app (SC-20) and optionally to `/metrics`.

---

## 11. Brute-force protection & rate limiting

- **Enrollment:** max 5 attempts/10min/IP → 30min lockout; exponential backoff on the printed token display.
- **Refresh:** 30/10min/device; reuse → immediate revoke.
- **All authed:** 300/min/token; WS connect 10/min.
- **Uploads:** 20/hr.
- Enforcement: token-bucket per (IP, deviceId); `Retry-After` + `X-RateLimit-*` headers; 429 responses.
- **DDoS note:** agent is user-operated; documented hardening = run behind firewall/VPN, `read_only`, and optional reverse proxy. We harden correctness, not nation-state DDoS.

---

## 12. Replay protection

| Vector | Control |
|--------|---------|
| Access token replay | 15m TTL + optional IP binding `[OPEN v1.1]`; `jti` per token; agent rejects duplicate `jti` within window |
| Refresh token replay | Single-use rotation; reuse → revoke |
| Enrollment token replay | One-time, TTL 10m, high entropy (≥ 128 bits) |
| WS frame replay | TLS-level integrity (no app-level replay surface); idempotency keys on mutations |

---

## 13. Secrets management

- **Agent:** no secrets in YAML config; tokens generated/printed at runtime; private key `0600`; env-var injection for webhook auth tokens (e.g., `QWE1_WEBHOOK_TOKEN`) not logged.
- **App:** secure storage only; secrets excluded from backups? — iOS Keychain is excluded from iCloud backup by default for `AfterFirstUnlock` items; Android encrypted prefs are app-private.
- **CI:** no real secrets in CI; test fixtures only; secret scanning (gitleaks) in CI.
- **Docker env masking:** container `inspect` response masks values of env vars matching `/^(PASSWORD|SECRET|TOKEN|KEY|AUTH|MYSQL|POSTGRES|REDIS)/i`.

---

## 14. Secure update mechanism

- **App:** OS stores only (App Store / Play / F-Droid). No self-update. Code signatures handled by platform.
- **Agent:** **no self-update** (user control). Updates via user's package manager, install script (SHA-256 checksum verified), or Docker image (digest-pinned recommended). Releases **signed** (see §15).
- **Release integrity:** GitHub releases with signed checksums (`cosign`/`minisign`); SBOM generated per release; docs recommend users verify.

---

## 15. Supply chain

- Dependency scanning (Dependabot/Renovate + `govulncheck` for Go, `flutter pub outdated` + OSV scanner).
- Reproducible builds for the agent where practical `[OPEN]`.
- SBOM per release (Syft/cyclonedx).
- Signed release artifacts + checksums.

---

## 16. OWASP Mobile Top 10 (2024) mapping

| OWASP | Control reference |
|-------|-------------------|
| M1 Improper Credential Usage | §4–6 (secure storage, short tokens, rotation, hashing) |
| M2 Inadequate Supply Chain Security | §15 (SBOM, scanning, signed releases) |
| M3 Insecure Authentication/Authorization | §5–8, [13](./13-authentication.md) |
| M4 Insufficient Input/Output Validation | Agent: path normalization, size caps, body limits; App: deep-link validation |
| M5 Insecure Communication | §3 (TLS 1.3, pinning) |
| M6 Inadequate Privacy Controls | §18 (zero telemetry by default) |
| M7 Insufficient Binary Protections | Platform hardening: no root/jailbreak reliance, RASP optional `[OPEN]` |
| M8 Security Misconfiguration | Agent config validation (`--check`), fail-closed defaults |
| M9 Insecure Data Storage | §4, [12](./12-database-design.md) (two-store rule) |
| M10 Insufficient Cryptography | §3, §4 (modern algorithms only; no custom crypto) |

---

## 17. Security requirements checklist (gate for release)

- [ ] TLS 1.3+ with pinning; no plaintext mode in default config
- [ ] Access tokens ≤ 15m; refresh rotation with reuse detection
- [ ] Secrets only in secure storage (no DB secrets)
- [ ] Read-only enforced in agent middleware
- [ ] Rate limits + lockout active on enroll/auth
- [ ] Audit log enabled with bounded retention
- [ ] Docker env masking active
- [ ] Path allow-list with symlink-safe normalization
- [ ] Body/size limits + WS backpressure
- [ ] Dependency + secret scanning green in CI
- [ ] No telemetry by default (§18)
- [ ] Release artifacts signed + SBOM attached
- [ ] OWASP MAS checklist items above each have a test

## 18. Privacy engineering

- **Default:** zero outbound network calls except to configured agents + user-configured webhooks. No analytics, no crash-send, no phone-home.
- **Opt-in diagnostics:** crash reports / usage metrics are: aggregate, anonymized, self-hostable, and off by default with explicit consent screen.
- **Data on device:** profiles, cached metrics (bounded), alert history. Cleared on server removal or "Clear data".
- **App store metadata:** transparency ("No account required. No data leaves your devices.")

## 19. Security team & process (v1)

- **Coordinated disclosure:** `SECURITY.md` (repo root) with GPG contact; 90-day disclosure window.
- **Release security review:** every release runs the §17 checklist; critical changes get a second reviewer.
- **Bug bounty:** `[OPEN]` — consider a small program post-GA (likely too early for v1).
