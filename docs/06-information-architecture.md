# 06 — Information Architecture

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Product / UX

---

## 1. Navigation model

- **Primary:** a 3-tab bottom navigation bar, present on the "home" hierarchy only:
  - **Servers** (dashboard) — `[SC-01]`
  - **Alerts** — `[SC-09]`
  - **Settings** — `[SC-12]`
- **Secondary:** server-scoped screens (detail, docker, logs, terminal, files) are pushed onto a stack rooted at the Servers tab. Each has a back affordance to its parent server context.
- **Contextual actions:** FAB (+) for "Add server" on the Servers tab; per-screen action bars otherwise.

Rationale: a shallow, consistent 3-tab model keeps everything ≤ 2 taps away (NFR-US-1) and matches platform conventions for utility apps. It avoids a deep nested nav hierarchy that frustrates glanceability.

## 2. Hierarchy

```
Home (3 tabs)
├── Servers (dashboard)                                   [Tab 1]
│   ├── Server Detail                                    [SC-02]
│   │   ├── Metrics / charts                            (embedded)
│   │   ├── Containers  ─► Container Detail              [SC-06/07]
│   │   │   └── Container Logs                           [SC-08]
│   │   ├── Terminal                                     [SC-10]
│   │   ├── File Browser                                 [SC-11]
│   │   └── Alerts (per-server filter)                   [SC-09-scoped]
│   ├── Add Server                                        [SC-04]
│   │   └── QR scan / manual / fingerprint verify         [SC-04a, SC-17]
│   └── (multi-select server cards for grouped ops — NTH)
│
├── Alerts (global)                                       [Tab 2]
│   └── Alert detail (routes to server/container context)
│
└── Settings                                              [Tab 3]
    ├── Appearance / Security / Alerts / Servers / Data / About
    └── (nested single-level screens)
```

## 3. Screen relationships & ownership

| Parent | Child | Relationship |
|--------|-------|--------------|
| Servers tab | Server Detail | push; server-scoped state |
| Server Detail | Containers / Terminal / Files / Logs | push; inherit `serverId` |
| Container List | Container Detail | push; inherit `serverId+containerId` |
| Container Detail | Logs | push or embedded tab (embedded tab preferred) |
| Alerts tab | Alert detail | push; resolves to server/container |
| Settings | sub-screens | push; shallow (1 level) |

Each screen carries an explicit "context" (serverId, containerId, path) so deep links and state restoration are deterministic.

## 4. State restoration & navigation recovery

- go_router routes are data-driven (`serverId` in path).
- On app restart, last route restored if its entities still exist; otherwise fallback to root tab.
- Terminal sessions are the exception: they resume to the session list / session reattach rather than silently reconnecting (user consent, [05-user-flows.md](./05-user-flows.md) §8).

## 5. Deep linking rules

Supported routes (also in [05-user-flows.md](./05-user-flows.md) §13):

| Pattern | Target | Validation |
|---------|--------|------------|
| `/servers` | Dashboard | — |
| `/servers/:serverId` | Server Detail | serverId must exist locally |
| `/servers/:serverId/containers/:containerId/logs` | Logs | both IDs valid |
| `/servers/:serverId/terminal` | Terminal | server valid; session created on demand |
| `/servers/:serverId/files?path=...` | File Browser | path resolved against allow-list; resolved path must stay inside root |

Security rules:
- Unknown/unresolvable IDs → navigate to Dashboard with a toast, never to an error-only screen.
- `path` in file links must resolve to a real path inside the agent's allow-list after normalization (`..` rejected).
- Deep links never carry secrets or tokens.

## 6. Navigation failure policy

- Target unreachable (server offline): show the screen shell with the offline/error state and a Retry — do not block navigation.
- Auth expired mid-flow: inline banner + re-auth sheet; do not throw the user to Settings.
- Malformed link: redirect to root; log locally (no telemetry).

## 7. Information architecture principles

1. **One context at a time** — each pushed screen shows exactly one server's data.
2. **Glanceable first** — the top of every server screen answers "is it healthy?".
3. **Actions adjacent to data** — restart button lives with the container, not in Settings.
4. **Consistent back semantics** — back always returns to the parent context (predictable).
5. **No buried settings** — security and data settings reachable from Settings and, where relevant, from the entity they affect (per-server read-only on the server card's menu).
