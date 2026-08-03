# qwe1 API Reference

**Project:** qwe1 — Self-Hosted Server Management Platform
**Component:** Backend (Go Agent)
**Version:** v1
**Base URL:** `https://<agent-host>:9443`
**Last Updated:** 2026-08-03

---

## Conventions

| Convention | Value |
|------------|-------|
| API version header | `X-Api-Version: 1` |
| Content type | `application/json` |
| Auth header | `Authorization: Bearer <accessToken>` |
| Error envelope | `{ "error": { "code": "...", "message": "..." } }` |
| Success response | Structured JSON with appropriate HTTP status |
| Pagination | `limit` (default 100, max 500) + `cursor` (opaque) |
| Idempotency | `Idempotency-Key` header on mutating POSTs |

---

## Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created |
| `204` | No content |
| `400` | Bad request (validation) |
| `401` | Unauthorized (missing/expired token) |
| `403` | Forbidden (read-only / permission) |
| `404` | Not found |
| `409` | Conflict |
| `413` | Payload too large |
| `426` | API version mismatch |
| `429` | Rate limited (with `Retry-After`) |
| `500` | Internal error |
| `503` | Dependency unavailable |

---

## Authentication

### POST `/auth/enroll`

Exchange a one-time enrollment token for device credentials.

**Request**

```json
{
  "enrollmentToken": "qwe1-XXXXXXXXXXXX",
  "device": {
    "name": "Alex's iPhone",
    "platform": "ios"
  }
}
```

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

**Errors:** `400` invalid format, `401` invalid/expired token, `429` rate limited.

---

### POST `/auth/refresh`

Rotate the refresh token and issue a new access token.

**Request**

```json
{ "refreshToken": "rt_..." }
```

**Response `200`**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "rt_...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "refreshExpiresIn": 2592000
}
```

**Errors:** `401` invalid/expired/revoked token. Reuse of a refresh token revokes the entire device.

---

### POST `/auth/revoke`

Revoke the current device (remote logout). Requires authentication.

**Request:** `{}`

**Response `204`**

Kills all tokens and active WebSocket sessions for the device.

---

### GET `/auth/me`

Returns device identity, server info, capabilities, and read-only flag. Requires authentication.

**Response `200`**

```json
{
  "deviceId": "abc123...",
  "serverName": "nuc-01",
  "agentVersion": "1.0.0",
  "capabilities": {
    "docker": true,
    "terminal": true,
    "files": true,
    "tempSensors": true
  },
  "readOnly": false
}
```

---

## Server Status

### GET `/status` *(public)*

Unauthenticated ping for reachability checks during server addition.

**Response `200`**

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

## Metrics

### GET `/metrics/latest`

Returns the latest host metrics snapshot. Requires authentication.

**Response `200`**

```json
{
  "timestamp": "2026-08-03T12:00:00Z",
  "hostname": "nuc-01",
  "uptimeSeconds": 482913,
  "load": [0.42, 0.31, 0.25],
  "cpu": {
    "percent": 23.4,
    "perCore": [12.0, 34.2],
    "cores": 8
  },
  "memory": {
    "total": 17179869184,
    "used": 6553600000,
    "percent": 38.1,
    "swapPercent": 1.2
  },
  "disk": [
    {
      "mount": "/",
      "total": 512110190592,
      "used": 214748364800,
      "percent": 41.9
    }
  ],
  "network": {
    "rxBytesPerSec": 204800,
    "txBytesPerSec": 102400
  },
  "temp": {
    "sensors": [
      { "name": "coretemp", "celsius": 47.5 }
    ]
  }
}
```

### GET `/metrics/history`

Server-side history for gap-filling. Returns an array of snapshots.

**Query params:** `range` (e.g. `1h`), `resolution` (e.g. `1m`)

**Response `200`**

```json
[]
```

> **Status:** Stubbed — returns empty array.

---

## Docker

### GET `/docker/containers`

List all containers.

**Query params:** `withStats` (boolean, default false)

**Response `200`**

```json
{
  "items": [
    {
      "id": "abc123...",
      "name": "plex",
      "image": "plexinc/pms-docker:latest",
      "state": "running",
      "status": "Up 3 days",
      "health": "healthy",
      "ports": [
        { "host": "32400", "container": "32400", "protocol": "tcp" }
      ],
      "cpuPercent": 1.2,
      "memoryBytes": 524288000,
      "createdAt": "2026-07-01T10:00:00Z"
    }
  ],
  "nextCursor": null,
  "total": 12
}
```

### POST `/docker/containers/{id}/start`

Start a container.

**Response `204`**

**Errors:** `404` not found, `409` already running, `403` read-only, `503` docker down.

---

### POST `/docker/containers/{id}/stop`

Stop a container (10s timeout).

**Response `204`**

**Errors:** `404`, `409`, `403`, `503`.

---

### POST `/docker/containers/{id}/restart`

Restart a container (10s timeout).

**Response `204`**

**Errors:** `404`, `409`, `403`, `503`.

---

### POST `/docker/containers/{id}/pause`

Pause a running container.

**Response `204`**

---

### POST `/docker/containers/{id}/unpause`

Resume a paused container.

**Response `204`**

---

### POST `/docker/containers/{id}/kill`

Send a signal to a container (default SIGKILL).

**Request**

```json
{ "signal": "KILL" }
```

**Response `204`**

---

### DELETE `/docker/containers/{id}`

Remove a container.

**Query params:** `force` (boolean), `v` (boolean, remove volumes)

**Response `204`**

**Errors:** `403` read-only, `404`, `409`.

---

### GET `/docker/containers/{id}/inspect`

Inspect a container. Secret-pattern env keys are masked.

**Response `200`** — Raw Docker inspect JSON with secrets masked.

---

### GET `/docker/containers/{id}/logs`

Get container logs.

**Query params:** `tail` (integer, default 200, max 2000), `follow` (boolean, default false)

**Response `200`**

```json
{
  "items": [
    { "stream": "stdout", "line": "hello world", "seq": 1 }
  ]
}
```

---

## Terminal

### POST `/terminal`

Create a PTY session.

**Request**

```json
{ "cols": 80, "rows": 24 }
```

**Response `201`**

```json
{
  "sessionId": "term_9x",
  "wsUrl": "/ws?channels=terminal:term_9x"
}
```

### DELETE `/terminal/{id}`

Force-kill a terminal session and its process group.

**Response `204`**

---

## Filesystem

### GET `/fs/list`

List directory contents.

**Query params:** `path` (relative to allowed roots; empty defaults to first root)

**Response `200`**

```json
{
  "items": [
    {
      "name": "docker-compose.yml",
      "isDir": false,
      "size": 4821,
      "mode": "-rw-r--r--",
      "modified": "2026-07-30T09:00:00Z"
    }
  ]
}
```

### GET `/fs/read`

Read a file.

**Query params:** `path` (required)

**Response `200`** — Raw file content (binary or text).

### POST `/fs/upload`

Upload a file.

**Content-Type:** `multipart/form-data`

**Fields:** `file` (file), `path` (destination path, optional — defaults to filename)

**Response `201`**

```json
{ "path": "/home/user/uploaded.txt", "name": "uploaded.txt", "size": 1024 }
```

### POST `/fs/mkdir`

Create a directory.

**Request**

```json
{ "path": "/home/user/newdir" }
```

**Response `201`**

### POST `/fs/write`

Write/overwrite a file.

**Request**

```json
{ "path": "/home/user/file.txt", "content": "hello world" }
```

**Response `200`**

```json
{ "path": "/home/user/file.txt" }
```

### PATCH `/fs/rename`

Rename or move a file/directory.

**Request**

```json
{ "from": "/home/user/old.txt", "to": "/home/user/new.txt" }
```

**Response `204`**

### DELETE `/fs`

Delete a file or directory.

**Query params:** `path` (required), `recursive` (boolean, default false)

**Response `204`**

---

## Alerts

### GET `/alerts`

List alerts, newest first.

**Query params:** `severity` (optional filter: `critical`, `warning`, `info`), `limit` (default 100)

**Response `200`**

```json
{
  "items": [
    {
      "id": "al_1",
      "severity": "critical",
      "type": "host.cpu",
      "message": "CPU above 90% for 5m",
      "at": "2026-07-31T17:55:00Z",
      "acked": false,
      "context": { "percent": 95.2 }
    }
  ]
}
```

### PUT `/alerts/{id}/ack`

Acknowledge an alert.

**Response `204`**

### GET `/alerts/thresholds`

Get current alert threshold rules.

**Response `200`**

```json
{}
```

> **Status:** Stubbed — returns empty object.

### PUT `/alerts/thresholds`

Update alert threshold rules.

**Request**

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

**Response `200`**

> **Status:** Stubbed — no-op.

---

## Audit

### GET `/audit`

List audit log entries, newest first.

**Query params:** `limit` (default 100)

**Response `200`**

```json
{
  "items": [
    {
      "ts": "2026-08-03T12:00:00Z",
      "actor": "device_1",
      "action": "container.restart",
      "target": "plex",
      "result": "ok",
      "ip": "192.168.1.20"
    }
  ]
}
```

> **Status:** Stubbed — returns empty array.

---

## WebSocket

### Connect

`WSS://<agent-host>:9443/ws?channels=metrics,alerts,docker,logs,terminal:term_9x`

**Channels:**
- `metrics` — live host metrics
- `alerts` — alert events
- `docker` — container state-change events
- `logs` — container log lines
- `terminal:<sessionId>` — PTY I/O for a specific session

### Frame Envelope

```json
{ "ch": "metrics", "type": "data", "data": { ... } }
```

| Field | Values |
|-------|--------|
| `ch` | `metrics`, `alerts`, `docker`, `logs`, `terminal:<id>` |
| `type` | `data`, `control` |
| `data` | Channel-specific payload |

### Control Frames

**Client → Agent:**

```json
{ "op": "ping" }
{ "op": "subscribe", "channel": "metrics" }
{ "op": "unsubscribe", "channel": "metrics" }
{ "op": "resize", "cols": 80, "rows": 24 }
```

**Agent → Client:**

```json
{ "op": "pong" }
{ "op": "closed", "reason": "idle_timeout" }
```

### Heartbeat

Ping/pong every 30 seconds. Agent closes idle connections after 120 seconds.

---

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| `/auth/enroll` | 10 / minute per IP |
| `/auth/refresh` | 30 / minute per device |
| All authenticated | 300 / minute per token |
| WS connect | 10 / minute per token |
| Upload | 20 / hour per token |

Responses include `Retry-After` header on `429`.