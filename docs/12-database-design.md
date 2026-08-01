# 12 — Database Design

**Project:** qwe1 — On-device storage (Flutter app)
**Status:** `[DECIDED]`
**Owner:** App / Architecture

> The **only** persistent storage in v1 is **on-device** (the agent is stateless-by-design except for tokens, alert buffer, and audit ring — see [10-backend-planning.md](./10-backend-planning.md) §4.5/4.6).

---

## 1. Storage policy (the two-store rule)

1. **Secrets** (tokens, enrollment material, fingerprints) → **`flutter_secure_storage`** (Keychain on iOS, EncryptedSharedPreferences/Keystore on Android). NEVER in SQLite.
2. **Everything else** (server metadata, cached metrics, alerts, offline queue) → **Drift** (SQLite). Encrypted at rest where OS-backed encryption is available (iOS Data Protection; Android direct boot-aware encryption); clear-cache supported.

Rationale: SQLite is fast and queryable for the app's cache/config needs; secrets get hardware-backed encryption from the OS rather than a homemade crypto scheme. No custom encryption of the DB in v1 — the database contains no secrets by construction.

---

## 2. Schema (Drift / SQLite)

```mermaid
erDiagram
    SERVER ||--o{ SERVER_LABEL : has
    SERVER ||--o{ METRIC_SAMPLE : records
    SERVER ||--o{ ALERT : produces
    SERVER ||--o{ OFFLINE_OP : queues
    SERVER ||--o{ THRESHOLD_OVERRIDE : has
    SERVER ||--o{ CONTAINER_SNAPSHOT : caches
    SERVER ||--o{ SESSION : tracks

    SERVER {
        TEXT id PK
        TEXT name
        TEXT agentUrl
        TEXT groupName
        INTEGER readOnly
        TEXT fingerprintHash
        TEXT status
        TEXT deviceId
        INTEGER lastSeenAt
        INTEGER createdAt
        TEXT agentVersion
        TEXT capsJson
    }
    SERVER_LABEL {
        TEXT serverId FK
        TEXT label
        TEXT value
    }
    METRIC_SAMPLE {
        INTEGER id PK
        TEXT serverId FK
        INTEGER ts
        REAL cpuPercent
        REAL memPercent
        REAL diskPercent
        REAL netRxBps
        REAL netTxBps
        REAL tempCelsius
        REAL load1
    }
    ALERT {
        TEXT id PK
        TEXT serverId FK
        TEXT alertType
        TEXT severity
        TEXT message
        INTEGER at
        INTEGER acked
        TEXT contextJson
    }
    OFFLINE_OP {
        INTEGER id PK
        TEXT serverId FK
        TEXT kind
        TEXT payloadJson
        INTEGER createdOrder
        INTEGER state
    }
    THRESHOLD_OVERRIDE {
        TEXT serverId PK FK
        TEXT key
        REAL value
        INTEGER forSeconds
    }
    CONTAINER_SNAPSHOT {
        TEXT serverId FK
        TEXT containerId
        TEXT name
        TEXT image
        TEXT state
        TEXT health
        INTEGER updatedAt
        REAL cpuPercent
        REAL memBytes
    }
    SESSION {
        TEXT id PK
        TEXT serverId FK
        TEXT kind
        TEXT payloadJson
        INTEGER lastActiveAt
    }
```

### Table notes
- **SERVER** — profile metadata; `fingerprintHash` (SHA-256 of agent cert, for pin comparison) is *not* a secret (fingerprint is public info), but kept here for display/verify.
- **METRIC_SAMPLE** — bounded retention: keep **7 days at 1-sample/60s** then roll up to **30 days at 1-sample/5m**, then delete. Implemented by a scheduled cleanup + `PRAGMA`-friendly deletes.
- **ALERT** — mirrors agent history for offline viewing; `acked` synced back.
- **OFFLINE_OP** — only **config mutations** queue (threshold overrides, profile edits, ack). Server ops (docker/fs/terminal) are never queued; they require connectivity (deliberate — silently queuing a `rm` would be dangerous).
- **SESSION** — terminal session registry for reattach (kind `terminal`); payload holds session id and reattach info.
- **CONTAINER_SNAPSHOT** — last-known container state so the list is instantly populated offline.

---

## 3. Relationships & referential integrity

- All child tables FK → `SERVER(id)` with `ON DELETE CASCADE` (removing a server wipes its cache — including cached alerts and container snapshots).
- `THRESHOLD_OVERRIDE` uses `(serverId, key)` composite PK.
- No cross-server relationships.

## 4. Indexes

| Table | Index | Rationale |
|-------|-------|-----------|
| `METRIC_SAMPLE` | `(serverId, ts)` | Time-range queries for charts |
| `METRIC_SAMPLE` | `(serverId)` partial on retention sweep | Cleanup scans |
| `ALERT` | `(serverId, at DESC)` | Per-server alert list |
| `ALERT` | `(acked, at DESC)` | Unacknowledged badge queries |
| `CONTAINER_SNAPSHOT` | `(serverId, state)` | Filter chips (All/Running/Stopped) |
| `OFFLINE_OP` | `(state, createdOrder)` | FIFO flush |

## 5. Caching strategy

| Data | Cache | Invalidation |
|------|-------|--------------|
| Server status/caps | SERVER columns | On each successful `/status`/connect |
| Latest metrics | Recurring METRIC_SAMPLE row per poll interval | Append on live stream |
| Metric history charts | Rolled-up samples | TTL-based sweep |
| Container list | CONTAINER_SNAPSHOT | On WS docker events + list refresh |
| Alerts | ALERT | On WS alert push + poll reconcile |

- **Freshness marker:** every cached entity carries a timestamp; UI renders stale state with "Updated Xs ago" (SC design in [07-design-system.md](./07-design-system.md) §8).

## 6. Offline strategy

- **Reads:** serve last-known from cache with stale markers. Never block UI on network for reads.
- **Writes (allowed offline):** profile edits, threshold overrides, alert acks → `OFFLINE_OP` queue, flushed FIFO on reconnect (idempotent via `Idempotency-Key`).
- **Writes (blocked offline):** docker mutations, fs mutations, terminal ops → disabled UI with explanatory empty/error state.
- **Reconnect:** on WS reconnect → resync alert backlog, re-pull `/metrics/latest`, replay offline ops, reconcile container snapshots.

## 7. Encryption

- **At rest:** OS-provided. iOS: Data Protection `NSFileProtectionCompleteUntilFirstUserAuthentication` (default) for DB file; Keychain items `kSecAttrAccessibleAfterFirstUnlock`. Android: SQLite DB in app-private dir (FBE `DEVICE_ENCRYPTED`/`CREDENTIAL_ENCRYPTED` semantics), secrets in Keystore-backed EncryptedSharedPreferences.
- **In transit:** TLS 1.3 + pinning ([14-security-architecture.md](./14-security-architecture.md) §3).
- **Secrets:** only in `flutter_secure_storage`. On biometric failure, app lock (SC-19) gates access; DB remains encrypted by the OS keychain until auth.

## 8. Migrations

- Drift schema versioning + `MigrationStrategy`. Migrations are additive; destructive changes behind app-store "version gate" only after backup of profile list.
- **Export/import of server list** (minus secrets) is `[NTH v1.1]` to ease device migration.

## 9. Challenged alternatives

| Decision | Choice | Alternative rejected | Why |
|----------|--------|----------------------|-----|
| Engine | Drift (SQLite) | Isar/Hive, ObjectBox | SQLite is standard, Drift has first-class migrations/streams; Hive lacks relational queries; Isar stability concerns at decision time |
| Secrets store | flutter_secure_storage | Encrypted SQLite via sqlcipher | Native Keychain/Keystore is the platform-correct, audited answer; custom sqlcipher adds attack surface for no benefit since DB holds no secrets |
| Metrics retention | Tiered 7d/30d | Unlimited | Bounded disk; matches glance/trend needs |
| Offline ops | Config-only queue | Full op queue | Safety: never silently queue destructive server ops |
