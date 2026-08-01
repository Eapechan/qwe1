# 11 — API Design

**Project:** qwe1 — Agent ↔ App contract
**Status:** `[DECIDED]`
**Owner:** Backend / App

> **Base URL:** `https://<agent-host>:9443`
> **API version:** `v1` — every request MUST include header `X-Api-Version: 1`. Agent responds `426 Upgrade Required` with `X-Api-Version` on major mismatch.
> **Auth:** `Authorization: Bearer <accessToken>` on all routes except `GET /status` and `POST /auth/enroll`.
> **Content type:** `application/json` (WS frames binary/JSON per §9).

---

## 1. Conventions

### 1.1 Status codes
| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created |
| `204` | No content |
| `400` | Bad request (validation) |
| `401` | Unauthorized (missing/expired token) |
| `403` | Forbidden (read-only / permission / not enrolled) |
| `404` | Not found |
| `409` | Conflict (e.g., container already stopped) |
| `413` | Payload too large (upload/log bounds) |
| `426` | API version mismatch |
| `429` | Rate limited (with `Retry-After`) |
| `500` | Internal error |
| `503` | Dependency unavailable (docker socket down) |

### 1.2 Error envelope
```json
{
  "error": {
    "code": "READ_ONLY",
    "message": "Action denied in read-only mode",
    "detail": { "action": "container.stop" }
  },
  "requestId": "req_7f3a..."
}
```
- `code` is stable, machine-readable; `message` is user-facing; `detail` optional.
- App maps `code` → localized copy; never parses free text.

### 1.3 Pagination
List endpoints accept `limit` (default 100, max 500) and `cursor` (opaque). Response:
```json
{ "items": [...], "nextCursor": "opaque-string-or-null", "total": 42 }
```

### 1.4 Idempotency
Mutating POSTs accept `Idempotency-Key`. Agent caches result for the key (TTL 10m) to prevent double-restarts on retry storms.

---

## 2. Authentication

### POST `/auth/enroll`
Exchange a one-time enrollment token for device credentials.

**Request**
```json
{
  "enrollmentToken": "qwe1-XXXXXXXXXXXX",
  "device": {
    "name": "Alex's iPhone",
    "platform": "ios",
    "appVersion": "1.0.0",
    "publicKey": "-----BEGIN PUBLIC KEY-----..." 
  }
}
```
> `publicKey` is optional in v1 (not used for mTLS by default; reserved for future). Fingerprint of agent cert is delivered **in the response** for out-of-band verification.

**Response `201`**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "rt_...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "refreshExpiresIn": 2592000,
  "serverFingerprint": "ab:cd:...:ef"
}
```
- One-time token invalidated after use.
- Errors: `400` invalid format, `429`/`401` on brute force.

### POST `/auth/refresh`
**Request**
```json
{ "refreshToken": "rt_..." }
```
**Response `200`** — same shape as enroll (new access + **rotated** refresh; old refresh invalidated).
Errors: `401` invalid/expired/revoked → app shows "re-enroll".

### POST `/auth/revoke`
Revoke current device (remote logout). **Request/Response:** `{}` → `204`. Kills all tokens + active WS sessions.

### GET `/auth/me`
Returns device id, server name/version, capabilities, read-only flag, agent version.

---

## 3. Server status & capabilities

### GET `/status` *(public)*
Unauthenticated ping used for reachability during add-server.
```json
{
  "name": "nuc-01",
  "agentVersion": "1.0.0",
  "apiVersion": 1,
  "caps": {
    "docker": true,
    "terminal": true,
    "files": true,
    "tempSensors": true
  }
}
```

---

## 4. Metrics

### GET `/metrics/latest`
```json
{
  "timestamp": "2026-07-31T18:00:00Z",
  "host": {
    "hostname": "nuc-01",
    "uptimeSeconds": 482913,
    "load": [0.42, 0.31, 0.25],
    "cpu": { "percent": 23.4, "perCore": [12.0, 34.2] },
    "memory": { "total": 17179869184, "used": 6553600000, "percent": 38.1, "swapPercent": 1.2 },
    "disk": [
      { "mount": "/", "total": 512110190592, "used": 214748364800, "percent": 41.9 }
    ],
    "network": { "rxBytesPerSec": 204800, "txBytesPerSec": 102400 },
    "temp": { "sensors": [ { "name": "coretemp", "celsius": 47.5 } ] }
  }
}
```
- Numeric sizes in bytes; rates in bytes/sec.

### GET `/metrics/history?range=1h&resolution=1m`
Server-side history for gap-filling (agent keeps a small ring buffer). Returns array of snapshots.

---

## 5. Docker

### GET `/docker/containers?filters=running`
```json
{ "items": [
  {
    "id": "abc123...",
    "name": "plex",
    "image": "plexinc/pms-docker:latest",
    "state": "running",
    "status": "Up 3 days",
    "health": "healthy",
    "ports": [ { "host": "32400", "container": "32400", "protocol": "tcp" } ],
    "cpuPercent": 1.2,
    "memoryBytes": 524288000,
    "createdAt": "2026-07-01T10:00:00Z"
  }
], "nextCursor": null, "total": 12 }
```

### POST `/docker/containers/{id}/start|stop|restart|pause|unpause|kill`
- Request: `{}` (+ optional `signal` for kill). Response `204`.
- Errors: `404`, `409` (already in target state), `403` read-only, `503` docker down.

### POST `/docker/containers/{id}/remove?force=true&v=true`
- **Read-only** → `403`. Returns `204`. Confirmation is client-side (agent trusts typed action; audit-logged).

### GET `/docker/containers/{id}/inspect`
Full inspect JSON (agent strips/hides env keys matching secret patterns — see security §13 of [14](./14-security-architecture.md)).

### GET `/docker/containers/{id}/logs?tail=200&follow=false`
- `tail` ≤ 2000 lines default 200.
- `follow=true` → streaming (see §9). Response format per frame:
  - Stream header: `{"type":"logs","container":"id"}`
  - Data frames: raw bytes (with optional `[stderr]` prefix encoding).

---

## 6. Terminal

### POST `/terminal`
Creates a PTY session.
```json
{ "cols": 80, "rows": 24, "shell": "", "env": {} }
```
**Response `201`**
```json
{ "sessionId": "term_9x", "wsUrl": "/ws?channels=terminal:term_9x" }
```

### DELETE `/terminal/{sessionId}`
Force-kill session + process group. `204`.

### WS terminal frames
- **Client → agent:** binary (raw input), JSON control: `{"op":"resize","cols":80,"rows":24}`.
- **Agent → client:** binary (raw output), JSON: `{"op":"closed","reason":"idle_timeout"}`.

---

## 7. Filesystem

### GET `/fs/list?path=/home/alex&hidden=false`
```json
{ "items": [
  { "name": "docker-compose.yml", "isDir": false, "size": 4821,
    "mode": "-rw-r--r--", "modified": "2026-07-30T09:00:00Z" }
] }
```
Traversal outside roots → `403` `code:"PATH_FORBIDDEN"`.

### GET `/fs/read?path=...&maxBytes=1048576`
Raw body (text/image). `Range` supported for partial reads. Bounds: text 2MB, image 8MB default (configurable).

### POST `/fs/upload?path=...&name=...`
`multipart/form-data`; size cap 500MB default, streamed to disk with temp file + atomic rename. `201` with metadata.

### POST `/fs/mkdir`, `POST /fs/write`
Create directory / write file (JSON body or raw). `201`.

### PATCH `/fs/rename`
```json
{ "from": "/home/alex/a.txt", "to": "/home/alex/b.txt" }
```
`204`.

### DELETE `/fs?path=...&recursive=false`
`204`. Recursive deletes require `recursive=true` and are audit-logged.

---

## 8. Alerts

### GET `/alerts?severity=critical&since=...`
```json
{ "items": [
  { "id": "al_1", "severity": "critical", "type": "host.cpu",
    "message": "CPU above 90% for 5m", "at": "2026-07-31T17:55:00Z",
    "acked": false, "context": { "serverId": "local" } }
], "nextCursor": null }
```

### PUT `/alerts/{id}/ack` → `204`

### GET `/alerts/thresholds` / `PUT /alerts/thresholds`
```json
{
  "host": {
    "cpuPercent": { "value": 90, "forSeconds": 60 },
    "memPercent": { "value": 90, "forSeconds": 60 },
    "diskPercent": { "value": 85, "forSeconds": 300 },
    "tempCelsius": { "value": 75, "forSeconds": 300 }
  },
  "docker": { "containerDown": true }
}
```

---

## 9. WebSocket protocol (multiplexed)

### Connect
`GET /ws?channels=metrics,alerts,docker,logs,terminal:term_9x&token=accessToken`
- Token passed in query (WebSocket headers not available in browser context) — MUST be short-lived; the token is also pinned to the connection IP/device in v1.1 `[OPEN]`.

### Frame envelope
```json
{ "ch": "metrics", "type": "data", "data": { ... } }
```
- `ch`: `metrics | alerts | docker | logs | terminal:<sessionId>`
- `type`: `data | control`
- **metrics** data: `/metrics/latest` snapshot shape.
- **alerts** data: alert object; `type:"control"` data `{"op":"ack","id":...}`.
- **docker** data: docker event (`{"type":"event","action":"die","name":"plex"}`) or stats batch.
- **logs** data: `{ "container": "id", "line": "...", "stream": "stdout|stderr", "seq": 123 }`.
- **terminal** data: binary frames (§6).

### Delivery guarantees
- Per-channel ordering guaranteed; channels independent.
- Backpressure: agent pauses per-channel sends when client buffer full; client applies flow control (`control: {"op":"flow","ack":seq}`) for logs/terminal.

### Heartbeat
Ping/pong every 30s; agent closes idle > 120s (`control: {"op":"closed","reason":"idle"}`).

---

## 10. Audit

### GET `/audit?limit=100`
```json
{ "items": [
  { "ts": "...", "actor": "device_1", "action": "container.restart",
    "target": "plex", "result": "ok", "ip": "192.168.1.20" }
] }
```

---

## 11. Rate limits

| Endpoint | Limit |
|----------|-------|
| `/auth/enroll` | 5 / 10 min per IP; lockout 30 min after 5 fails |
| `/auth/refresh` | 30 / 10 min per device |
| All authed | 300 / min per token |
| WS connect | 10 / min per token |
| Upload | 20 / hour per token |

Responses include `Retry-After` and `X-RateLimit-*` headers.

---

## 12. OpenAPI

- **Artifact:** `api/openapi.yaml` (OpenAPI 3.1) generated from the Go handlers (via `ogen` or hand-maintained with schema tests).
- **Contract tests:** every app/agent CI run validates requests/responses against the OpenAPI doc (see [19-testing-strategy.md](./19-testing-strategy.md)).

---

## 13. Design decisions & challenged alternatives

| Decision | Choice | Alternative rejected | Why |
|----------|--------|----------------------|-----|
| Auth header vs WS query token | Bearer header for REST; short-lived token in WS query | Cookie-based | Cookies are awkward cross-platform in mobile WS; bearer is standard |
| Multiplexed WS vs per-feature sockets | Multiplexed | One socket per feature | Fewer connections, ordered channels, simpler lifecycle |
| REST + WS vs pure WS | REST for CRUD, WS for streams | All-WS (Action-msg style) | REST is debuggable, cacheable, testable; WS only where realtime matters |
| Idempotency keys | Yes for mutations | None | Prevents double-restarts from app retries |
| Server-side history for metrics | Small ring buffer | Client-only history | Agent is authoritative; client gaps fill from server |
