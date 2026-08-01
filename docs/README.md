# qwe1 — Planning Documentation

> Privacy-first, open-source mobile app for managing self-hosted Linux servers.
> This repository currently contains **planning and architecture documentation only** — no source code.

## Reading order

New engineers, contributors, and reviewers should read the documents in the order below. Each document builds on the previous one.

| # | Document | What it answers |
|---|----------|-----------------|
| 1 | [01-vision.md](./01-vision.md) | Why does qwe1 exist? |
| 2 | [02-market-research.md](./02-market-research.md) | What already exists, and where is the gap? |
| 3 | [03-prd.md](./03-prd.md) | What exactly are we building? |
| 4 | [04-feature-planning.md](./04-feature-planning.md) | What ships in v1, and in what priority order? |
| 5 | [05-user-flows.md](./05-user-flows.md) | How does a user move through the product? |
| 6 | [06-information-architecture.md](./06-information-architecture.md) | How is navigation organized? |
| 7 | [07-design-system.md](./07-design-system.md) | What does it look and feel like? |
| 8 | [08-screens.md](./08-screens.md) | What are all the screens? |
| 9 | [09-architecture.md](./09-architecture.md) | How is the system built at a high level? |
| 10 | [10-backend-planning.md](./10-backend-planning.md) | How does the server agent work? |
| 11 | [11-api-design.md](./11-api-design.md) | What are the exact API contracts? |
| 12 | [12-database-design.md](./12-database-design.md) | What is stored on-device and how? |
| 13 | [13-authentication.md](./13-authentication.md) | How is identity established and verified? |
| 14 | [14-security-architecture.md](./14-security-architecture.md) | How do we defend the system? |
| 15 | [15-technology-stack.md](./15-technology-stack.md) | Which technologies and why? |
| 16 | [16-folder-structure.md](./16-folder-structure.md) | Where does every file live? |
| 17 | [17-roadmap.md](./17-roadmap.md) | When is it done? |
| 18 | [18-github-planning.md](./18-github-planning.md) | How is the project run on GitHub? |
| 19 | [19-testing-strategy.md](./19-testing-strategy.md) | How do we prove it works? |
| 20 | [20-documentation.md](./20-documentation.md) | What docs must ship with the product? |
| 21 | [21-open-source.md](./21-open-source.md) | How do we attract and keep contributors? |
| 22 | [22-future-roadmap.md](./22-future-roadmap.md) | What comes after v1? |

## Status legend

Every planning document uses a status marker so readers know how settled the content is.

| Marker | Meaning |
|--------|---------|
| `[DECIDED]` | Accepted decision; treat as binding unless an RFC changes it |
| `[OPEN]` | Decision pending; flagged for an RFC or milestone planning session |
| `[DEFERRED]` | Explicitly pushed to a later version |

## Repo root artifacts

| File | Purpose |
|------|---------|
| `README.md` | Public-facing project landing page (drafted at repo root) |
| `LICENSE` | AGPL-3.0 (see [01-vision.md](./01-vision.md#license-strategy)) |
| `CONTRIBUTING.md` | Contribution workflow for contributors |
| `SECURITY.md` | Vulnerability reporting policy |
| `.github/` | Issue/PR templates and community health files |

## Repository philosophy

This repository is a **planning-first** repository. During the planning phase it contains only:

- Planning and architecture documents (`docs/`)
- Community and governance files (`.github/`, `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`)

The implementation phase introduces two code repositories or monorepo subprojects as described in [16-folder-structure.md](./16-folder-structure.md):

- `app/` — the Flutter mobile application
- `agent/` — the Go server agent

## How to maintain this documentation

- One document per topic. Do not create a `docs/misc` or `docs/notes`.
- When a decision changes, update the document AND the index table above.
- Decisions that affect security must be reviewed against [14-security-architecture.md](./14-security-architecture.md).
- API contract changes must update [11-api-design.md](./11-api-design.md) and, once implementation starts, the API version header rules in [09-architecture.md](./09-architecture.md).
