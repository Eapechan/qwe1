# 18 — GitHub Planning

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Maintainers / Community

---

## 1. Repository setup

- **Location:** `github.com/qwe1/qwe1` (monorepo, see [16-folder-structure.md](./16-folder-structure.md)).
- **Topics:** `flutter`, `go`, `self-hosted`, `homelab`, `docker`, `linux`, `mobile`, `monitoring`, `open-source`, `privacy`.
- **Default branch:** `main` (protected).
- **Public by default.** Issues enabled; Discussions enabled (RFCs/announcements); Projects used for milestone tracking.

## 2. Branching strategy

**Trunk-based development** with short-lived feature branches.

```
main (protected)
 ├── feat/<feature>          # short-lived, from main
 ├── fix/<bug>               # from main
 ├── docs/<topic>            # from main
 └── release/v<major>.<minor>  # cut from main at release time (tag-only after)
```

- PRs required to merge to `main`; no direct pushes to `main`.
- Require: CI green (path-scoped checks), ≥ 1 approving review (2 for security/API), no unresolved threads.
- Release branches exist only to patch a released version; most work merges to `main` and is cherry-picked if needed.
- **Semantic versioning** of tags on `main`.

## 3. Branch protection rules (main)

| Rule | Value |
|------|-------|
| Require PR | ✅ |
| Required reviews | 1 (2 for files in `api/`, `**/security*`, auth/terminals/fs modules) |
| Status checks | `ci-app`, `ci-agent`, `contract`, `security` (path-scoped) |
| Dismiss stale reviews | ✅ |
| Enforce admins | ✅ |
| Linear history / squash | Squash merges (clean main, one commit per PR) |
| Delete head branches | ✅ |

## 4. Labels

| Category | Labels |
|----------|--------|
| Type | `bug`, `feature`, `enhancement`, `docs`, `refactor`, `test`, `chore`, `rfc`, `security` |
| Area | `app`, `agent`, `api`, `terminal`, `docker`, `files`, `alerts`, `auth`, `ui`, `ci` |
| Priority | `P0` (critical), `P1` (high), `P2` (normal), `P3` (low) |
| Status | `needs-triage`, `needs-design`, `good-first-issue`, `help-wanted`, `in-progress`, `blocked`, `duplicate`, `wontfix`, `needs-repro`, `backport` |
| Release | `release/v1.x` |

Label automation: `needs-triage` on new issues; `in-progress` when assigned+linked; `needs-repro` on unconfirmed bugs.

## 5. Milestones

Milestones mirror [17-roadmap.md](./17-roadmap.md) plus release milestones:

| Milestone | Description |
|-----------|-------------|
| `M0 Discovery` | setup/CI/contract |
| `M1 Foundation` | auth/profiles/dashboard |
| `M2 Realtime` | streams/alerts/docker-live |
| `M3 Operations` | docker actions/terminal/files |
| `M4 Hardening` | security/offline/polish |
| `M5 Beta` | beta stabilization |
| `M6 GA v1.0.0` | release |

Rules: issues closed only via PR merge; milestone closed with release notes; backlog groomed weekly.

## 6. Issues

- **Templates** (`.github/ISSUE_TEMPLATE/`):
  - `bug_report.md` — environment (OS/Flutter/agent versions), steps, expected/actual, logs, severity.
  - `feature_request.md` — problem, proposed solution, alternatives, priority ask.
  - `rfc.md` — for `[OPEN]` architecture decisions (template with context/decision/consequences).
  - `config.yml` — triage labels + contacts.
- **Bug quality gate:** bugs need `needs-repro` resolved or a clear root-cause before fixing; security bugs → [SECURITY.md](../SECURITY.md) process (no public issue for 0-days until fixed).
- **Triage cadence:** label `needs-triage` → reviewed within 48h by a maintainer → priority + milestone assigned.

## 7. Pull requests

- **Template:** summary (why/what), test plan, screenshots (UI), checklist (docs updated, tests added, security considered, changelog entry).
- **Conventional Commits** (squash message): `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `perf:`, `security:`.
- **Review expectations:** small PRs (< 400 lines typical), focused scope, CI green, no unreviewed `[OPEN]` decisions.
- **Dependabot/Renovate:** weekly dependency PRs; auto-merge only for non-breaking minors with CI green.
- **CODEOWNERS:** `api/`, `agent/internal/auth*`, `agent/internal/terminal*`, `agent/internal/files*`, `**/14-security*` require security-capable maintainer review.

## 8. Releases

- **Flow:** tag `v<major>.<minor>.<patch>` on `main` → `release.yml` runs goreleaser (agent binaries: amd64/arm64/armv7, darwin; checksums; SBOM; signed via cosign) + draft GitHub Release.
- **App releases:** manual via CI workflow (TestFlight/Play internal) on milestone tags; public store releases on `v1.x.0` GA tags.
- **Release notes:** generated from Conventional Commits + manually curated "highlights / breaking changes / upgrade path".
- **Semver rules:**
  - `MAJOR`: breaking API (agent ↔ app contract), breaking agent behavior.
  - `MINOR`: features, backwards-compatible additions.
  - `PATCH`: bugfixes, security fixes.
  - Pre-releases: `-beta.N`, `-rc.N`.
- **Paired compatibility note** in every release (min agent version for app release and vice versa).

## 9. Semantic versioning enforcement

- Conventional Commits lint in CI (commitlint) drives changelog + tag suggestions.
- `api/openapi.yaml` changes that break clients → require MAJOR bump; additive → MINOR.
- `SECURITY` note: security fixes released as PATCH (or MINOR if feature involved), announced via GitHub Security Advisories.

## 10. Governance (v1, minimal)

- **Maintainers:** 2–3 initial; documented in `GOVERNANCE.md` (repo + docs).
- **Decision process:** issues → discussion → ADR/RFC (docs/) for architecture; maintainer consensus; recorded in changelog.
- **Communication:** GitHub Discussions for RFCs; maintainers available on the community chat (self-hosted).
- **Onboarding contributors:** `good-first-issue` pool maintained; mentorship documented in [21-open-source.md](./21-open-source.md).
