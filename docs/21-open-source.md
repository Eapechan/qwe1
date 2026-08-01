# 21 — Open Source Readiness

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Maintainers / Community

> How qwe1 attracts, welcomes, and retains contributors — and keeps the project healthy.

---

## 1. Project health foundations

1. **Clear mission & scope** — [01-vision.md](./01-vision.md) + [03-prd.md](./03-prd.md) tell contributors *what we are and are not*.
2. **Real roadmap** — [17-roadmap.md](./17-roadmap.md) and milestones make it obvious where help is needed.
3. **Small, reviewable PRs** — engineering culture enforces focused changes (see [18](./18-github-planning.md) §7).
4. **Low barrier to first commit** — `good-first-issue` pool with mentor notes, docs fixes count.

## 2. Issue templates & triage

- Templates in `.github/ISSUE_TEMPLATE/`: bug, feature, RFC (see [18](./18-github-planning.md) §6).
- **Triage SLA:** 48h to first maintainer response; `needs-triage` label auto-applied; weekly triage session.
- **First-timer welcome:** automated `welcome` comment linking to CONTRIBUTING + good-first-issues; no question is "too basic".
- **RFCs** for any `[OPEN]` architecture decision — decisions are public, recorded, and reversible (ADR log).

## 3. Code quality as a recruitment tool

- Consistent linting enforced in CI (`very_good_analysis`, `staticcheck`, markdownlint) → newcomers see clear standards.
- Conventional Commits + PR checklist → predictable process.
- Architecture docs that *are* the onboarding: a contributor can read [09-architecture.md](./09-architecture.md) and understand the system in an afternoon.

## 4. Documentation culture

- Docs updated in the same PR as code (DoD).
- "Docs-first" for new features: describe the intended behavior before implementation (ties to PRD acceptance criteria).
- Contribution guide is friendly and specific: setup, branch naming, test commands, review expectations.

## 5. Community standards

- **CODE_OF_CONDUCT** (Contributor Covenant 2.1) enforced; maintainer contact for reports.
- **GOVERNANCE.md:** maintainer roles, decision process, conflict resolution, bus-factor plan (≥ 2 maintainers per area).
- **Recognize contributions:** release notes credit contributors; `CONTRIBUTORS.md`/GitHub Sponsors button (if/once legal structure exists).
- **Communication:** GitHub Discussions (default); community chat optional and self-hostable. All decisions mirrored back to GitHub (no decision-only channels).

## 6. Contribution workflow (summary)

```
1. Find an issue (good-first-issue) or open a bug/RFC discussion
2. Ask/assign → branch from main → make focused change
3. Add/update tests + docs; run local lint/tests
4. Open PR (template) → CI (path-scoped) → review (1–2) → squash merge
5. Changelog entry; credit in release notes
```

Full version in `CONTRIBUTING.md`.

## 7. Contributor onboarding checklist

- [ ] `CONTRIBUTING.md` with exact setup commands verified by a fresh contributor
- [ ] `good-first-issue` pool (≥ 5 tagged issues at all times)
- [ ] Architecture tour doc (from [09](./09-architecture.md))
- [ ] Dev environment documented (fvm, Go, Docker for agent tests)
- [ ] Mentorship: maintainers offer pairing on first PR

## 8. Metrics & health checks (opt-in, aggregate)

- Monthly: new/active contributors, median issue-to-response, PR merge time, first-timer success rate.
- Warning signs watched: PR merge time creeping up, response SLA misses, bus-factor < 2 in an area.

## 9. Sustainability roadmap

- v1: maintainers donate time; zero funding required to run (all infra: GitHub Actions free tier, self-hostable docs).
- v2 considerations `[OPEN]`: sponsorship (GitHub Sponsors), consulting/advisory, dual-license discussion for enterprise features (must respect AGPL core). Funding decisions documented and transparent.
