# Contributing to qwe1

First off, thanks for being here. qwe1 is a community project — every contribution counts, from a docs typo to a security review.

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before participating. We expect it to be followed in all spaces.

## What kind of contributions we welcome

- 🐛 Bug reports and reproductions
- ✨ Features
- 📝 Documentation and guides
- 🔐 Security analysis and audits
- 🎨 Design and UX improvements
- 🧪 Tests
- 💬 Helping triage issues and answer questions

## Before you start

1. **Read the docs.** Start with [README.md](README.md) and [GETTING_STARTED.md](GETTING_STARTED.md). Most "how do I..." questions are answered there.
2. **Check open issues/discussions** to avoid duplicating work.
3. **Ask first for anything big** — open a Discussion or comment on the issue before writing hundreds of lines.

## Development setup

### Prerequisites

- Flutter (pinned via `fvm` — see `app/fvm.yaml`)
- Go 1.22+
- Docker (for agent integration tests)
- Git

### App

```sh
cd app
fvm install        # install the pinned SDK
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

### Agent

```sh
cd agent
go mod download
go build ./...
go vet ./...
go test ./...
```

### API contract

The contract lives at `api/openapi.yaml`. Both sides validate against it in CI. If you change the API, update the contract in the same PR and run `make contract`.

## Branching & commits

- Work on a short-lived branch: `feat/<feature>`, `fix/<bug>`, `docs/<topic>`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org): `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `perf:`, `security:`.
- Keep PRs small and focused (typically under ~400 lines). Split large changes.

## Pull request process

1. Create a PR against `main`.
2. Fill in the [PR template](.github/PULL_REQUEST_TEMPLATE.md).
3. Make sure path-scoped CI is green (app/agent/contract/security).
4. Add or update tests — keep coverage in line with existing package tests.
5. Update docs in the same PR where the behavior is user-facing.
6. Wait for review. One approving review is required (two for `api/`, `agent/internal/auth*`, `agent/internal/terminal*`, `agent/internal/files*`, and security-relevant files).
7. Squash-merge is used to keep `main` clean.

## RFC process for architecture decisions

Any significant architecture change goes through an RFC:

1. Open an issue with the `rfc` label (use the [RFC template](.github/ISSUE_TEMPLATE/rfc.md)).
2. Discuss context/decision/consequences with maintainers and the community.
3. Record the decision as an ADR when accepted.

## Labels you'll see

`good-first-issue` — great starting points, with pointers in comments.
`help-wanted` — needs a dedicated owner.
`needs-triage` — awaiting maintainer review.
`P0`–`P3` — priority.

## Recognition

Contributors are credited in release notes. We maintain a `CONTRIBUTORS.md`.

## Getting help

- GitHub Discussions for questions and RFCs
- `@maintainers` for triage issues
- Check [GETTING_STARTED.md](GETTING_STARTED.md) for troubleshooting and setup

Thanks for contributing to qwe1.
