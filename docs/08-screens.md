# 08 — Complete Screen List

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Product / UX / Eng

> IDs referenced across all planning docs. "Required APIs" point to [11-api-design.md](./11-api-design.md); "Required permissions" are device permissions.

---

## SC-01 Dashboard (Servers tab)

- **Purpose:** Glanceable multi-server health. The app's home.
- **Widgets:** App bar ("Servers", add button); server cards (status, CPU/RAM/disk/temp/uptime); FAB (+) Add Server; pull-to-refresh; connection banner.
- **Navigation:** → Server Detail; → Add Server; → Alerts/Settings via bottom nav.
- **Interactions:** tap card → detail; long-press card → quick actions (read-only toggle, remove); pull-to-refresh; reconnect all.
- **Required APIs:** `GET /api/v1/metrics/summary` (per server, aggregated), `GET /api/v1/status`, WS `metrics` stream subscribe. List is assembled locally across profiles.
- **Required permissions:** (none on device).

## SC-02 Server Detail

- **Purpose:** Full health + entry point to all server tooling.
- **Widgets:** Header (name, status, fingerprint short, read-only badge); live metric strip (CPU/RAM/Network tabs with charts); uptime & load; quick-action cards (Containers, Terminal, Files, Alerts); action menu (Edit, Read-only, Remote logout, Remove).
- **Navigation:** → Containers, Terminal, Files, Alerts (scoped).
- **Interactions:** tab charts; tap quick actions; pull-to-refresh; live update toggle.
- **Required APIs:** `GET /api/v1/metrics/latest`, WS `metrics`; `GET /api/v1/host/info` (uptime, kernel, hostname).
- **Required permissions:** (none).

## SC-03 Server Edit

- **Purpose:** Modify profile metadata (name, group, labels, agent URL, read-only, thresholds).
- **Widgets:** Form fields; save/cancel; delete server (destructive, confirm-typing).
- **Navigation:** ← Server Detail / Settings.
- **Interactions:** validate URL, save, delete, fingerprint re-verify (re-enroll path).
- **Required APIs:** local DB only; `POST /api/v1/auth/refresh` used to re-validate.
- **Required permissions:** (none).

## SC-04 Add Server

- **Purpose:** Onboard a new server.
- **Widgets:** Two modes: QR scan / manual entry. Fields: name, agent URL, enrollment token (manual), group. Test & Save.
- **Navigation:** → fingerprint verification → Dashboard.
- **Interactions:** camera QR; paste token; connectivity test spinner; save.
- **Required APIs:** `POST /api/v1/auth/enroll` (token exchange).
- **Required permissions:** Camera (QR scan only; optional permission prompt).

## SC-04a Connection Test

- **Purpose:** Validate reachability during add.
- **Widgets:** Progress, inline success/error states.
- **Navigation:** transient; back on failure.
- **Required APIs:** `GET /api/v1/status` (unauthenticated ping) + `GET /api/v1/auth/me` (authed check).
- **Required permissions:** (none).

## SC-05 Server Connection Error

- **Purpose:** Clear recovery for unreachable/expired servers.
- **Widgets:** Illustration, cause-specific copy, Retry / Re-enroll / Remove.
- **Navigation:** ← context; → Dashboard.
- **Interactions:** retry loop; re-enroll (goes to SC-04); remove.
- **Required APIs:** as SC-04a.
- **Required permissions:** (none).

## SC-06 Container List

- **Purpose:** All containers for a server.
- **Widgets:** Filter chips (All/Running/Stopped), search, rows (name, status chip, image, mini CPU/mem bars), count header.
- **Navigation:** → Container Detail.
- **Interactions:** filter/search; pull-to-refresh; tap row.
- **Required APIs:** `GET /api/v1/docker/containers`, WS `docker:events` for live status.
- **Required permissions:** (none).

## SC-07 Container Detail

- **Purpose:** Full container ops.
- **Widgets:** Header (name, image, state, health), action bar (Start/Stop/Restart/Pause, More: Kill/Remove), tabs (Logs | Inspect | Resources).
- **Navigation:** Logs tab embeds SC-08; Inspect → fields; back to list.
- **Interactions:** actions → confirm sheets (SC-18); destructive require typing name; resource tab shows live CPU/mem charts.
- **Required APIs:** `POST /api/v1/docker/containers/{id}/start|stop|restart|pause|unpause|kill|remove`, `GET .../inspect`, WS for resources.
- **Required permissions:** (none).

## SC-08 Logs

- **Purpose:** Tail and stream container/host logs.
- **Widgets:** Virtualized log view (mono), level filter chips, search, Live toggle, copy/export actions, timestamp toggle.
- **Navigation:** embedded in Container Detail; standalone for host logs from Server Detail.
- **Interactions:** stream on/off; filter/search; pause/resume; scroll to end.
- **Required APIs:** `GET /api/v1/docker/containers/{id}/logs` (tail), WS `logs` stream.
- **Required permissions:** (none).

## SC-09 Alerts

- **Purpose:** All alerts, global and per-server.
- **Widgets:** Filter (server/severity/type), alert rows (severity color, time, source, message), acknowledge actions.
- **Navigation:** → context (server detail or container); → threshold settings.
- **Interactions:** filter; acknowledge; tap to navigate; "adjust threshold" deep-link.
- **Required APIs:** `GET /api/v1/alerts` (history), WS `alerts` stream, `GET/PUT /api/v1/alerts/thresholds`.
- **Required permissions:** Local notifications.

## SC-10 Terminal

- **Purpose:** Interactive shell session.
- **Widgets:** Terminal view (mono, themeable), tool bar (ESC/TAB/CTRL/arrows, font size, theme, paste, disconnect), session title, connection status.
- **Navigation:** from Server Detail; back = confirm close.
- **Interactions:** hardware keyboard + on-screen modifier row; pinch to resize font (NTH); reconnect to persisted session; force-close.
- **Required APIs:** WS `terminal` (PTY I/O), `POST /api/v1/terminal` (create), `DELETE /api/v1/terminal/{id}` (kill).
- **Required permissions:** (none).

## SC-11 File Browser

- **Purpose:** Browse and operate on server files within allow-list.
- **Widgets:** Path breadcrumbs, listing (dirs first), multi-select toolbar (download/delete/rename), new folder/file, upload button, preview pane (text/image).
- **Navigation:** ← Server Detail; nested dirs.
- **Interactions:** navigate; long-press multi-select; upload via system picker; preview; confirm deletes.
- **Required APIs:** `GET /api/v1/fs/list?path=`, `GET /api/v1/fs/read?path=`, `POST /api/v1/fs/upload`, `POST /api/v1/fs/mkdir|write`, `PATCH /api/v1/fs/rename`, `DELETE /api/v1/fs`.
- **Required permissions:** Camera/Photo picker for uploads (system picker).

## SC-12 Settings

- **Purpose:** App-wide configuration.
- **Widgets:** Sections — Appearance, Security, Alerts, Servers, Data, About, Privacy.
- **Navigation:** 1-level sub-screens; → server management (SC-03 list), fingerprint review.
- **Interactions:** theme toggle, biometric toggle, read-only defaults, thresholds, webhook config, clear cache, version/legal, GitHub links.
- **Required APIs:** local only (agent config endpoints where threshold overrides used).
- **Required permissions:** Biometrics.

## SC-13 Splash

- **Purpose:** Brand + init; <1s.
- **Widgets:** Logo, version tag.
- **Navigation:** → SC-14 (first run) or SC-01 (returning) or SC-19 (locked).
- **Interactions:** none (auto).
- **Required APIs:** none.
- **Required permissions:** none.

## SC-14 Onboarding

- **Purpose:** First-run value pitch.
- **Widgets:** 3 pager slides, page dots, Get Started / Learn more CTAs.
- **Navigation:** → SC-15 (permissions) → SC-16 (empty).
- **Interactions:** swipe; buttons.
- **Required APIs:** none.
- **Required permissions:** none.

## SC-15 Permissions Request

- **Purpose:** Contextual permission grants.
- **Widgets:** Sequential permission cards (Notifications; Biometrics; Camera when adding first server).
- **Navigation:** → SC-16.
- **Interactions:** Allow / Not now per card; skippable.
- **Required APIs:** none.
- **Required permissions:** (grants requested here).

## SC-16 First-Run Empty State

- **Purpose:** Motivate first server add.
- **Widgets:** Illustration, "No servers yet", [Add your first server], [How it works].
- **Navigation:** → SC-04; → docs (web).
- **Interactions:** CTA.
- **Required APIs:** none.
- **Required permissions:** none.

## SC-17 Fingerprint Verification

- **Purpose:** TOFU trust establishment during enrollment.
- **Widgets:** Server address, agent cert SHA-256 fingerprint (chunked for readability), match/verify buttons, "help, where do I find this?".
- **Navigation:** → SC-01 on success; back on mismatch.
- **Interactions:** verify; mismatch hard-block with warning.
- **Required APIs:** `POST /api/v1/auth/enroll` completion.
- **Required permissions:** none.

## SC-18 Confirm Sheet

- **Purpose:** Generic confirmation bottom sheet (all mutating actions).
- **Widgets:** Title, description, resource name typing (for destructive), Cancel/Confirm.
- **Navigation:** overlay on parent.
- **Interactions:** cancel/confirm; type-to-enable for destructive.
- **Required APIs:** n/a.
- **Required permissions:** n/a.

## SC-19 Lock Screen

- **Purpose:** Biometric/PIN gate when app lock enabled.
- **Widgets:** Logo, biometric prompt, "Unlock with Face/Touch ID", fallback to device PIN.
- **Navigation:** → SC-01 on success.
- **Interactions:** biometric verify; retry; fallback.
- **Required APIs:** none.
- **Required permissions:** Biometrics.

## SC-20 Audit Log

- **Purpose:** Recent agent-side admin actions (remote visibility).
- **Widgets:** List of actions (actor, action, target, timestamp, result).
- **Navigation:** from Settings → Security.
- **Interactions:** filter by type; export (NTH).
- **Required APIs:** `GET /api/v1/audit`.
- **Required permissions:** none.

---

## Cross-cutting notes

- **Required device permissions (full inventory):** Camera (QR), Local Notifications, Biometrics, Photo/File picker (system-mediated), Network. No background-location, no contacts, no SMS.
- **APIs referenced:** all documented in [11-api-design.md](./11-api-design.md); screens never call raw sockets directly — they use the repository layer ([09-architecture.md](./09-architecture.md)).
- **State restoration:** screen stacks restore per [06-information-architecture.md](./06-information-architecture.md) §4.
