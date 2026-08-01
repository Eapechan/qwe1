# 05 — Complete User Flow

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Product / UX

> Every journey from cold start to expert operation. Screen names reference [08-screens.md](./08-screens.md) (e.g., `SC-01 Dashboard`).

---

## 1. First launch (cold start)

```
Install (App Store / Play Store / F-Droid)
   │
   ▼
[SC-13 Splash] (branded, < 1s, logo + version)
   │
   ▼
[SC-14 Onboarding: Welcome]
   ├── 3 swipeable slides: "Your servers in your pocket" /
   │    "Monitor, manage, secure" / "No cloud. Your data stays yours."
   │    CTAs: [Get started] [Learn more ▸ opens docs]
   │
   ▼
[SC-15 Permissions request]  (sequential, contextual, minimal)
   ├── Notifications (for alerts) — required? No. Optional.
   ├── Biometrics (for app lock) — optional, skip allowed
   ├── (Uploads use system file picker — no broad storage permission needed)
   │
   ▼
[SC-16 First-run state: Empty state — "No servers yet"]
   │  Illustration + "Add your first server" + "How it works" (docs)
   │
   ▼
[SC-04 Add Server] flow (see §3)
   │
   ▼
[SC-01 Dashboard] first server appears → metrics load
   │  Confetti-free, but positive confirmation: server card "Connected ✓"
```

**Design rules:** every step has a visible progress affordance; user can always skip optional steps; no forced sign-up anywhere.

---

## 2. Authentication

**App-level:**
- Biometric lock (if enabled): on launch/resume, `SC-19 Lock` shows; success → app opens; failure → retry; 5 failures → PIN fallback (device-provided).
- No account, no password, no cloud auth. The "identity" is the enrolled device + its tokens.

**Server-level (enrollment):** see §3 and [13-authentication.md](./13-authentication.md).
- Flow: `[SC-04 Add Server]` → QR scan of `qwe1-agent enroll` token → exchange → verify fingerprint → token store → done.

**Re-auth on expiry:**
- Access token expires → silent refresh via refresh token → success: continue.
- Refresh fails (revoked) → `[SC-05 Server Connection Error]` with "Re-authenticate / Remove server" actions.

---

## 3. Adding a server

```
[SC-04 Add Server]
   ├── Option A: QR pairing (recommended)
   │    1. User runs on the server:
   │         curl -fsSL get.qwe1.sh | sh          (or docker run ...)
   │    2. On server:  qwe1-agent enroll
   │         → prints a QR to the terminal (and/or one-time code)
   │    3. Tap [Scan QR] → camera → decode → connect to the URL in the QR
   │    4. [SC-17 Fingerprint Verification]:
   │         "Confirm this fingerprint matches your server"
   │         (show SHA-256 of agent cert + spoken/typed token from step 2)
   │    5. Verify → token exchange → [Save]
   │
   ├── Option B: Manual
   │    1. Enter agent URL (https://host:port), name, optional group
   │    2. Paste enrollment token
   │    3. Same fingerprint verification
   │
   ▼
[SC-04a Connection Test] spinner → success → [SC-01 Dashboard] with the new server
```

**Error handling:** wrong token → inline error "Invalid enrollment token"; unreachable host → "Could not reach agent at {url} — check network/VPN"; fingerprint mismatch → hard block with warning.

---

## 4. Connecting

- App opens → checks each profile → attempts connection in parallel (≤ 4 concurrent).
- States surfaced per server card: `Connecting…` / `Connected` / `Offline` / `Auth expired` / `Error`.
- Reconnect: exponential backoff (1s, 2s, 4s … max 60s) with jitter; on WebSocket drop → re-subscribe to metric stream; full state re-sync.
- App in background → connection suspended (mobile OS limits) → on foreground, resync + surface missed alerts.

---

## 5. Dashboard (core journey)

```
[SC-01 Dashboard]
   ├── Header: "Good evening" + network status + refresh control
   ├── Server list (cards, grouped):
   │     Card shows: name, status dot, CPU% , RAM%, disk% , temp (if any), uptime
   ├── Tap card → [SC-02 Server Detail]
   │     ├── Live chart strip (CPU/RAM/Network tabs)
   │     ├── Quick actions: Containers / Terminal / Files / Logs / Alerts
   │     └── Pull-to-refresh + live auto-update
   │
   └── Global FAB (+): add server
```

**Design rule:** glanceability first — a user should know "is everything okay" in under 2 seconds from the dashboard.

---

## 6. Managing Docker

```
[SC-06 Container List] (per server)
   ├── Filter chips: All / Running / Stopped / Healthy
   ├── Search box
   ├── Each row: name, status chip, image, CPU/mem mini-bars
   │
   ├── Tap row → [SC-07 Container Detail]
   │     ├── Actions bar: ▶ Start / ■ Stop / ⟳ Restart / II Pause
   │     ├── [More]: Kill, Remove
   │     ├── Tabs: Logs | Inspect | Resources
   │
   ├── Action → [SC-18 Confirm Sheet]
   │     Stop/Restart: "Restart 'db'?" [Cancel] [Restart]
   │     Kill/Remove: type container name to enable [Remove]
   │
   └── Result → inline toast/snackbar: "db restarted ✓" ; on failure: error with detail
```

**Rules:** every destructive action requires confirmation; `kill`/`remove` require typing the name; agent enforces permissions independently of UI.

---

## 7. Viewing Logs

```
[SC-08 Logs] (container or host, tail stream)
   ├── Open → shows last N lines (configurable, default 200)
   ├── Live stream toggle (WS) → appends
   ├── Level filter: all/error/warn/info/debug (from agent-annotated stream)
   ├── Search: highlight + jump
   ├── Pause/Resume stream; Copy to clipboard; Share/export (NTH)
   │
   └── Large volumes: agent sends bounded batches; UI virtualizes list; memory capped
```

**Error handling:** connection drop → "Reconnecting…" banner; buffer bounded (last 1000 lines) to avoid OOM.

---

## 8. SSH / Terminal

```
[SC-10 Terminal]
   ├── Entry: from Server Detail → Terminal, or container → exec (NTH)
   ├── Connects via agent PTY (WebSocket) — NOT an SSH client (architecture: [09](./09-architecture.md))
   ├── UI: shell view, input handled by hardware keyboard bar
   │     - on-screen modifier keys row (ESC, TAB, CTRL, arrows) for mobile keyboards
   │     - theme + font size controls in app bar
   ├── Session lifecycle: create → stream I/O → background (session persists agent-side briefly) → foreground → reattach
   ├── Close: [X] confirms "Close terminal session?" (warns if processes may be running)
   │
   └── Special: force-close via agent API kills the PTY (handles hung processes)
```

**Latency rules:** LAN < 200ms round trip; jitter buffer; backpressure when app pauses.

---

## 9. File Browser

```
[SC-11 File Browser]
   ├── Root: configured allow-list roots shown as "home", "srv", etc.
   ├── Navigate directories → listing (dirs first, then files; sorted)
   ├── Row actions:
   │     file → preview (text/image) or download
   │     dir → open
   │     long-press → multi-select → download / delete / rename
   ├── Create: New folder / New file; Upload (system picker → upload to cwd)
   ├── Delete: confirm (typing name for destructive bulk? — yes for >3 items)
   │
   └── Security: agent enforces allow-list; traversal attempts → 403; hidden files toggled off by default
```

---

## 10. Notifications & alerts

```
Agent detects breach (CPU > 90% for 60s, disk > 85%, container down, etc.)
   │
   ├── Alert buffered agent-side (with timestamp + severity)
   │
   ├── App connected → pushes alert over WS → local notification + [SC-09 Alerts] updated
   │
   └── App offline → on reconnect, sync backlog → notifications + history
        (optional: agent forwards to user webhook/ntfy when configured)
```

```
[SC-09 Alerts]
   ├── List: severity color-coded, time, source, message
   ├── Tap alert → context (server detail / container)
   ├── Filter: per server / severity / type
   └── Actions: acknowledge, silence-threshold (adjust threshold)
```

**Expectation setting:** v1 delivers alerts when the app is reachable; always-on push requires user-configured relay (documented in-app + docs).

---

## 11. Settings

```
[SC-12 Settings]
   ├── Appearance: theme (light/dark/system), accent
   ├── Security: app lock (biometric), read-only per server (also on server card)
   ├── Alerts: default thresholds, notification channel, webhook config
   ├── Servers: manage profiles, remove, fingerprint review, remote logout
   ├── Data: cache size, clear cache, export/import config (NTH)
   ├── About: version, licenses, open-source links, GitHub
   └── Privacy: explicit statement "no telemetry by default", opt-in diagnostics
```

---

## 12. Error handling (cross-cutting)

| Error | UX treatment | Underlying |
|-------|--------------|------------|
| Unreachable host | Card shows Offline; tap → "Retry" + hint (VPN?) | connection timeout |
| Auth expired | Inline banner; auto re-auth attempt; manual option | refresh fail |
| Revoked / remote logout | Blocked state; "Re-enroll" CTA | token revocation |
| Action rejected (permission) | Toast "Not permitted (read-only)" | agent RBAC |
| Action failed (e.g., container start) | Error sheet with detail + "Copy error" | agent error payload |
| Rate limited | "Too many attempts — try in Xs" | agent limiter |
| Certificate mismatch (MITM-style) | Hard block; "Fingerprint changed" + verify out-of-band | pinning |
| Malformed/unsupported API version | "Update the app/agent" + version info | API contract |
| Offline queued action (server op) | Disabled state with explanation (only config edits queue) | offline policy |
| Large log / huge file | Progressive loading; "truncated" notices | payload limits |

All errors render via the design system's error states ([07-design-system.md](./07-design-system.md) §8) — never raw stack traces.

---

## 13. Deep links

Supported v1 deep links (go_router):

| Route | Target |
|-------|--------|
| `/servers` | Dashboard (server list) |
| `/servers/:id` | Server detail |
| `/servers/:id/containers/:cid/logs` | Container logs |
| `/servers/:id/terminal` | Terminal session |
| `/servers/:id/files?path=` | File browser at path |
| `/alerts` | Alerts screen |

Deep-link payloads must be validated and scoped to the user's own server profiles (no arbitrary-host terminal spawning from a link). Full rules in [06-information-architecture.md](./06-information-architecture.md).
