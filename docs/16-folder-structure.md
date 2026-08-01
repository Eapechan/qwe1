# 16 — Project Folder Structure

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Architecture

> Target layout for the implementation phase. v1 is a **monorepo**: `app/` (Flutter) + `agent/` (Go) + `docs/` (planning). Docs-only at present.

---

## 1. Monorepo root

```
qwe1/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
├── .gitignore
├── .editorconfig
├── .pre-commit-config.yaml          # local lints before CI
├── Makefile                          # top-level: build/test/lint/contract
├── go.work                            # workspace for agent
├── docs/                              # planning + product docs (this repo)
├── api/
│   └── openapi.yaml                   # single source of truth for the v1 contract
├── app/                               # Flutter mobile app
├── agent/                             # Go server agent
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── workflows/                     # CI/CD
│   └── CODEOWNERS
└── scripts/                           # release, install, tooling
```

## 2. App (`app/`) — Flutter

```
app/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── fvm.yaml                            # pinned Flutter SDK
├── lib/
│   ├── main.dart                       # bootstrap: DI, router, themes
│   ├── app.dart                        # MaterialApp + go_router wiring
│   ├── core/                           # cross-cutting
│   │   ├── error/                      # app errors, error mapper (API → UX)
│   │   ├── config/                     # build-time config (flags, feature toggles)
│   │   ├── utils/                      # formatting, units, fingerprint
│   │   └── platform/                   # platform-channel wrappers (bio, notify, pickers)
│   ├── data/
│   │   ├── sources/
│   │   │   ├── remote/                 # dio client, WS client, DTOs
│   │   │   └── local/                  # Drift DB, DAOs, secure storage wrapper
│   │   ├── repositories/               # repo implementations
│   │   └── models/                     # data models (freezed)
│   ├── domain/
│   │   ├── entities/                   # pure domain models
│   │   ├── repositories/               # interfaces
│   │   └── usecases/                   # business logic
│   ├── state/                          # Riverpod providers/notifiers
│   │   ├── servers/
│   │   ├── docker/
│   │   ├── terminal/
│   │   ├── files/
│   │   ├── alerts/
│   │   └── settings/
│   ├── ui/
│   │   ├── theme/                      # tokens → ThemeData (07-design-system)
│   │   ├── widgets/                    # shared components (cards, buttons, charts)
│   │   ├── screens/                    # SC-* screens
│   │   └── router/                     # go_router config + deep links
│   └── l10n/                           # ARB files
├── test/
│   ├── unit/                           # domain + providers
│   ├── data/                           # repo/DAO tests
│   ├── widget/                         # screen widget tests
│   ├── golden/                         # golden tests
│   └── fixtures/                       # JSON fixtures, mocks
├── integration_test/                   # end-to-end
└── assets/                             # icons, illustrations, fonts (if any)
```

## 3. Agent (`agent/`) — Go

```
agent/
├── go.mod
├── go.sum
├── cmd/
│   └── qwe1-agent/main.go              # entrypoint (flags, enroll CLI, serve)
├── internal/
│   ├── server/                         # HTTP/WS server, router, middleware, handlers
│   │   ├── server.go                   # wiring, routes, lifecycle
│   │   ├── authmw.go                   # authn/authz, read-only gate, audit
│   │   ├── respond.go                  # middleware (recovery/requestID/logging/ip-ratelimit)
│   │   ├── handlers.go                 # REST handlers
│   │   ├── types.go                    # shared API types
│   │   └── ws.go                       # WS multiplexer, hub, terminal/logs/events
│   ├── auth/                           # enrollment, tokens, rotation, hashing, store, attempts
│   ├── certs/                          # self-signed CA + leaf, fingerprint
│   ├── host/                           # metrics collectors (gopsutil + sysfs temps)
│   ├── docker/                         # docker client wrapper
│   ├── terminal/                       # PTY session manager (+ sysproc per-OS)
│   ├── files/                          # allow-listed FS ops, path safety
│   ├── alerts/                         # alert engine, rules, buffer
│   ├── audit/                          # audit ring
│   ├── ratelimit/                      # token-bucket limiter
│   └── config/                         # config schema + validation
├── scripts/                            # install.sh, Dockerfile helpers
├── Dockerfile
└── .goreleaser.yaml
```

## 4. Docs & assets

```
docs/            # planning docs (this repo) — see docs/README.md
assets/          # branding, screenshots for README (no user data)
```

## 5. GitHub workflows (`.github/workflows/`)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci-app.yml` | PR + push main | flutter analyze, test, build (android/ios matrix, Linux smoke) |
| `ci-agent.yml` | PR + push main | go vet/staticcheck/test, govulncheck, build matrix (linux amd64/arm64/armv7, darwin) |
| `contract.yml` | PR | OpenAPI validation + contract tests (app & agent) |
| `security.yml` | PR + nightly | gitleaks, dependency scan (OSV), govulncheck |
| `release.yml` | tag `v*` | goreleaser (agent), app store builds (manual trigger), SBOM, checksums, GitHub Release |
| `docs.yml` | PR + push | docs lint (markdown, links), build site preview |

## 6. .github community files

- `ISSUE_TEMPLATE/`: `bug_report.md`, `feature_request.md`, `rfc.md`, `config.yml`
- `PULL_REQUEST_TEMPLATE.md`
- `CODEOWNERS` (initial maintainers)
- Community health: `CODE_OF_CONDUCT.md` (Contributor Covenant), `CONTRIBUTING.md`, `SECURITY.md`

## 7. Monorepo tradeoffs (recorded decision)

| Pro | Con | Mitigation |
|-----|-----|-----------|
| Paired app/agent releases | Single CI pipeline can be slow | Path-scoped CI (only changed dirs build fully) |
| Shared API contract in one PR | — | OpenAPI as contract; codegen both sides |
| One place for docs+code | Large clone for contributors | Sparse checkout docs (`git sparse-checkout`) |
| v1 velocity | — | Revisit split at v3 scale (recorded in [22](./22-future-roadmap.md)) |

## 8. Path-scoped CI

- `app/**` changes → run `ci-app` (+ contract if API changed).
- `agent/**` changes → run `ci-agent` (+ contract).
- `api/**` or `docs/**` changes → run `contract` + `docs`.
- Merge blocked unless required checks for changed paths pass.
