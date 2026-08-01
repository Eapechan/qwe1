# qwe1 Governance

**Status:** v1 minimal governance
**Owner:** Maintainers

## Roles

### Maintainers
- 2–3 initial maintainers (bus-factor ≥ 2 per area).
- Responsibilities: triage, review, merge, release, roadmap, community health, security.
- Appointed by maintainer consensus; recorded in this document.

### Committers / Contributors
- Anyone with merged contributions. No formal distinction in v1.

### Community
- Everyone using, discussing, and contributing to qwe1.

## Decision process

1. **Normal changes:** issues + PR review (see [CONTRIBUTING.md](CONTRIBUTING.md)).
2. **Architecture decisions** (anything marked `[OPEN]` or significant): **RFC** via GitHub Discussion/issue → maintainer consensus → recorded as an ADR in `docs/adr/`.
3. **Security-sensitive changes:** require review from a security-capable maintainer (CODEOWNERS enforced).
4. **License/legal decisions:** full community discussion; no unilateral changes.

## Roadmap ownership

- Product owner maintains [17-roadmap.md](docs/17-roadmap.md) and [22-future-roadmap.md](docs/22-future-roadmap.md).
- Milestones on GitHub reflect the roadmap; contributors can propose additions via RFC.

## Conflict resolution

- Disagreements are resolved by maintainer discussion; if unresolved, the topic goes to a public RFC with a decision deadline.
- No single maintainer holds veto over a change that has majority maintainer support.

## Releases

- Follow [18-github-planning.md](docs/18-github-planning.md) §8 (semver, tags, paired compatibility).
- Release notes credit all contributors.

## Funding & sustainability

- v1: no funding required (GitHub Actions free tier, self-hostable docs).
- Future: sponsorship and licensing options are discussed transparently (see [21-open-source.md](docs/21-open-source.md) §9 and [01-vision.md](docs/01-vision.md) §9). The AGPL core is not negotiable.

## Amendments

- Governance changes are proposed as RFCs and adopted by maintainer consensus.
