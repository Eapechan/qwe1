# 13 — Authentication

**Project:** qwe1
**Status:** `[DECIDED]` — recommendation locked for v1
**Owner:** Architecture / Security

---

## 1. The question

How does a phone prove it is authorized to talk to a self-hosted agent on a user's Linux server — securely, with no cloud, minimal friction, and a mobile-first enrollment UX?

## 2. Candidate comparison

| Scheme | Strengths | Weaknesses | Fit for qwe1 |
|--------|-----------|------------|--------------|
| **SSH keys / SSH agent** | Ubiquitous, strong, already trusted by admins | Mobile SSH client = larger app surface; key handling on phone; no per-API granularity; pairs poorly with REST/WS API auth; UX of provisioning phone keys is clunky | Poor primary. qwe1's agent already owns the transport — SSH keys would be redundant to the app's own authZ |
| **JWT (agent-issued)** | Stateless, short-lived, refreshable, standard, revocable via rotation; easy per-device identity | Requires token storage discipline; needs rotation for safety | **Excellent** — chosen as the core |
| **OAuth 2.0 / OIDC (external IdP)** | Standard, SSO-ready, enterprise-friendly | Requires an identity provider (Keycloak/Entra…) → cloud or heavy local infra; violates "zero cloud" default; overkill for single-operator v1 | Poor for v1 default; **documented for Enterprise (v3)** via pluggable token verification |
| **API keys (static)** | Trivial | Static keys are unrotatable-in-practice, long-lived, leak-prone; no per-session identity; no biometric tie | Poor — falls short of v1 security bar |
| **Mutual TLS (client certs)** | Strongest cryptographic binding; no bearer tokens to leak | Complex enrollment (cert lifecycle on phone); browser/OS friction; WS client-cert support is inconsistent on mobile; harder recovery | Good as an *optional hardening layer*; poor as the only mechanism |
| **Short-lived enrollment token + device binding** | Out-of-band trust, replay-safe, good UX | Requires careful one-time-token handling | **Chosen** — enrollment mechanism |

## 3. Recommended architecture

**Short-lived JWT (agent-issued, RS256) + rotating refresh tokens, bootstrapped by a one-time enrollment token with out-of-band fingerprint verification. Optional mTLS as a hardening toggle.**

### 3.1 Flow

```
1. Out-of-band (terminal on the server):
     qwe1-agent enroll   → prints one-time token + QR + agent cert fingerprint

2. In-app:
     scan QR → app POSTs /auth/enroll with the one-time token
     agent verifies token (one-time), issues:
       accessToken   = JWT, TTL 15m, signed RS256 by agent's key
       refreshToken  = opaque random, TTL 30d, rotated on every refresh
     agent returns its cert fingerprint for out-of-band display
     app shows fingerprint → user confirms it matches the server's
     (TOFU + explicit confirmation = certificate pinning baseline)

3. Steady state:
     app calls REST/WS with accessToken
     near expiry or on 401 → POST /auth/refresh with refreshToken
       → new access + NEW refresh (old one invalidated = rotation)
     revocation (remote logout / remove server) → /auth/revoke kills all
```

### 3.2 Why this combination

- **Zero cloud** — the agent is its own identity authority; no external IdP.
- **Short-lived access** limits blast radius if a token leaks (15 min window).
- **Refresh rotation** means a leaked refresh token is single-use; stealing it doesn't grant persistence without replaying at the exact rotation instant (with in-app detection of reuse → revoke device).
- **Enrollment token is one-time** → replay-proof bootstrap; **fingerprint confirmation** anchors trust (pinning) without shipping CA infrastructure to the phone.
- **Device identity** (`deviceId` on every token) enables per-device revocation, remote logout, and future multi-user RBAC with minimal change.
- **Optional mTLS** hardens high-trust LAN deployments for users who want it; not the default because mobile WS client-cert support is uneven and enrollment/revocation UX suffers.

### 3.3 What we deliberately do NOT do

- **No passwords on the agent** — password auth invites brute force and phishing; token-only surface is simpler and safer (rate limiting is still on tokens).
- **No OAuth by default** — external IdP adds infra against the zero-cloud principle. Kept as an enterprise hook.
- **No raw API keys** — unrotatable by design.
- **No SSH-key-based API auth** — the app is not an SSH client (see [09-architecture.md](./09-architecture.md)); keys stay on the server where they belong.

## 4. Token lifecycle details

| Aspect | Value |
|--------|-------|
| Access token | JWT, RS256, `iss=agent hostname`, `sub=deviceId`, `aud=qwe1-app`, TTL **15m** |
| Refresh token | Opaque 256-bit random, stored hashed on agent, TTL **30d**, rotated each use |
| Rotation window | Single-use; reuse detection → immediate device revoke + audit entry |
| Clock | Agent rejects JWTs with `iat` in future / `exp` exceeded (clock skew ≤ 60s) |
| Storage (app) | access: memory; refresh: secure storage only ([12](./12-database-design.md)) |
| Revocation | `/auth/revoke` per device; remove-server in app calls it best-effort then deletes local state |

## 5. WS auth

- Access token passed in WS connect query; tokens are short-lived so exposure risk is bounded.
- WS connection is bound to the device identity; disconnect on revocation.

## 6. Threat posture (summary)

See [14-security-architecture.md](./14-security-architecture.md) for the full model. Key mitigations relevant to auth:

- Enrollment token: high entropy (≥ 128 bits), one-time, TTL 10m, brute-force lockout.
- Access token: short TTL + optional IP binding `[OPEN: v1.1]`.
- Refresh token: single-use + rotation + reuse detection.
- Device: secure-storage-only persistence, biometric gate, remote revoke.
- Transport: TLS 1.3 + pinning (fingerprint confirmed at enroll).

## 7. Metrics for auth health (opt-in, aggregate only)

- Enrollment success/failure rates; refresh reuse events; revocations; lockouts. All opt-in and self-hostable; default off.
