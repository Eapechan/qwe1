# 20 — Documentation

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Technical Writing / Docs

> What documentation must exist, where it lives, and its review cycle. Public docs site is static + self-hostable.

---

## 1. Docs map

| Doc | Audience | Location | Format | Owner | Priority |
|-----|----------|----------|--------|-------|----------|
| README | Everyone | repo root | MD | maintainers | must |
| Installation Guide | Users (server + app) | docs site | MD/mkdocs | writing | must |
| Architecture Guide | Engineers | `docs/09`, repo `docs/` | MD+Mermaid | arch | must |
| Developer Guide | Contributors | repo `docs/` + site | MD | writing/eng | must |
| API Docs | Integrators | `api/openapi.yaml` → generated site | OpenAPI | backend | must |
| Contribution Guide | Contributors | repo `CONTRIBUTING.md` | MD | community | must |
| Security Policy | Security researchers | repo `SECURITY.md` | MD | security | must |
| License | Everyone | repo `LICENSE` | AGPL-3.0 | legal | must |
| Roadmap | Everyone | `docs/17`, site | MD | product | must |
| User Guide (feature walkthroughs) | End users | site | MD | writing | should |
| Troubleshooting | End users | site | MD | support | should |
| FAQ | Everyone | site | MD | product | should |
| Migration/Upgrade notes | Users | site + release notes | MD | eng | should |
| Admin guide (agent config) | Users | site | MD | backend | must |
| Governance | Contributors | repo `GOVERNANCE.md` | MD | maintainers | should |
| QA checklist | QA | `docs/qa-checklist.md` | MD | QA | should |

## 2. Audience-first principles

- **End-user docs** avoid jargon, assume Linux novice for install guide, assume Docker basics for docker guide.
- **Engineer docs** assume Go/Dart proficiency and reference the planning docs by ID.
- **Everything links to `docs/README.md` index** ([docs index](./README.md)).

## 3. Standards & tooling

- **Markdown** + Mermaid for architecture diagrams (already used throughout this repo).
- **docs site:** static via `mkdocs` (or VitePress `[OPEN]`, resolved in M0). Self-hostable; published to GitHub Pages by default.
- **Linting:** markdownlint (line length, headings, links), link-checker in `docs.yml`.
- **Spelling:** codespell in CI.
- **API docs:** generated from `api/openapi.yaml` (Redocly/Swagger UI) and versioned per API version.

## 4. Doc requirements per doc (abstracts)

### README
Hero (logo, tagline), badges, quickstart (agent install + app link), features, screenshots, docs link, community links, license.

### Installation Guide
- Agent: one-liner script, Docker, manual; prerequisites (Linux, archs); uninstall; upgrade; reverse-proxy note; config reference.
- App: store links (iOS/Android/F-Droid), manual install, permissions explanation.

### Architecture Guide
Public version of [09-architecture.md](./09-architecture.md): components, data flow, security summary, API versioning, compatibility matrix.

### Developer Guide
Setup (fvm, Go toolchain), repo layout ([16](./16-folder-structure.md)), how to run app/agent, how to run tests ([19](./19-testing-strategy.md)), coding standards, how to add a feature end-to-end, how to update the API contract.

### API Docs
Generated OpenAPI (endpoints, schemas, errors, WS protocol), plus a human "quick start" for integration.

### Contribution Guide
Code of conduct, dev setup, PR workflow, review expectations, label meanings, good-first-issues, RFC process for `[OPEN]` decisions.

### Security Policy
Responsible disclosure: GPG contact, scope, response SLO (48h ack, fix timeline), no-0day-public-before-fix rule, supported versions.

### License
AGPL-3.0-or-later (full text + summary), per [01-vision.md](./01-vision.md) §9.

### Roadmap
Public-facing version of [17-roadmap.md](./17-roadmap.md) + [22-future-roadmap.md](./22-future-roadmap.md): milestones, what's in/out, release cadence.

## 5. Lifecycle & review

- **Definition of Done** (from [01-vision.md](./01-vision.md) §10) requires docs update with each feature.
- PRs touching features must reference the doc diff; docs-only PRs are welcome.
- Quarterly docs review: accuracy vs current release, dead-link sweep, readability pass.
- Every release runs the docs CI + links check; broken links block release.

## 6. Docs for v1 GA gate

- [ ] README
- [ ] Installation Guide (agent + app)
- [ ] Admin guide (agent config)
- [ ] Architecture Guide (public)
- [ ] API Docs (generated, versioned)
- [ ] User Guide (feature walkthroughs)
- [ ] Contribution Guide + CODE_OF_CONDUCT
- [ ] Security Policy
- [ ] License
- [ ] Roadmap
- [ ] Troubleshooting + FAQ
- [ ] QA checklist
