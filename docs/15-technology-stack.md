# 15 — Technology Stack

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Architecture

> Decisions marked `[OPEN]` are final during implementation planning. Every choice includes reasoning and the rejected alternative.

---

## 1. Client (mobile app)

| Concern | Choice | Alternative rejected | Why |
|---------|--------|----------------------|-----|
| Framework | **Flutter (stable, ≥ 3.22)** | React Native, Swift/Kotlin native, KMP | Single codebase for iOS+Android with a single high-performance rendering model; first-class platform channels for biometrics/notifications/pickers; strong widget ecosystem for terminal/charts; fast iteration |
| Language | **Dart (3.x)** | TypeScript (RN) | Native to Flutter; sound null safety; strong typing for the domain layer |
| State management | **Riverpod (v2+)** | Bloc, Provider, GetX | Compile-safe, testable DI; providers compose for derived state (live metrics vs offline cache); less boilerplate than Bloc; larger ecosystem than GetX; predictable lifecycle |
| Navigation | **go_router** | AutoRoute, Navigator 2.0 raw | Declarative routing + deep links (IA §5) + state restoration; well-maintained; URI-based routes match our server/container context model |
| Networking | **dio** + `web_socket_channel` | http package, grpc | dio: interceptors (auth, retry), timeouts, uploads w/ progress, OpenAPI-friendly; web_socket_channel: standard WS for streams |
| Local DB | **Drift** | Isar, Hive, ObjectBox | See [12-database-design.md](./12-database-design.md) §9 |
| Secure storage | **flutter_secure_storage** | Custom crypto, sqlcipher | Keychain/Keystore-backed; platform-correct; audited by community |
| Serialization | **freezed + json_serializable** | built_value, manual | Codegen models with exhaustive `when` patterns; balanced between safety and speed |
| Terminal widget | **xterm-like renderer**: `flutter_xterm` (or in-house) `[OPEN]` | no terminal (skipped) | Must be performant on mobile; decision between mature package vs. owning our own (PWA-style) renderer for theme/reflow control |
| Charts | **fl_chart** (+ custom sparklines) | syncfusion, graphview | Lightweight, permissively licensed, customizable; avoid heavy/commercial chart libs |
| Biometrics | **local_auth** | Manual TouchID/FaceID | Official plugin |
| Notifications | **flutter_local_notifications** | — | Local (offline-first) notifications; no push SDK in v1 |
| Codegen / lint | **build_runner**, **dart_analyzer**, **very_good_analysis** | plain analysis_options | Consistent style; stricter defaults catch issues in CI |
| Testing | **flutter_test**, **mocktail**, **golden_toolkit**, **integration_test** | — | Pyramid in [19-testing-strategy.md](./19-testing-strategy.md) |

## 2. Agent (backend)

| Concern | Choice | Alternative rejected | Why |
|---------|--------|----------------------|-----|
| Language | **Go 1.22+** | Rust, Node, Python, C++ | Single static binary, trivial cross-compile (armv7/arm64/amd64), excellent concurrency for streams/PTYs, memory-safe, huge ecosystem; Rust rejected for iteration speed + smaller PTY/websocket ecosystem; Node/Python rejected for footprint + runtime deps |
| HTTP server | **stdlib `net/http`** (Go 1.22 pattern routing) | gin, echo, chi | Zero-dep, fast, adequate; avoids framework lock-in and supply-chain surface |
| WebSocket | **`github.com/coder/websocket`** (nhooyr) | gorilla/websocket | Context-aware, clean API, active maintenance; gorilla in maintenance mode |
| Docker client | **`github.com/docker/docker` (client)** | raw HTTP to socket | Official, typed, handles auth/socket |
| PTY | **`github.com/creack/pty`** | os/exec alone | Correct PTY semantics (resize, signals, process groups) |
| Host metrics | **`github.com/shirou/gopsutil/v3`** + native sysfs temperature reads | hostd, go-sysinfo | Cross-platform cpu/mem/disk/net/load/uptime; temperature via `/sys/class/thermal` on Linux, graceful empty elsewhere |
| QR enrollment | **`github.com/skip2/go-qrcode`** | manual string tokens | Terminal QR for `qwe1-agent enroll` (docs/05 §3) |
| Config | **YAML (gopkg.in/yaml.v3)** + flags + env | TOML, JSON | Human-editable for self-hosters; YAML familiarity |
| Logging | **`log/slog`** (stdlib) | zap, logrus | Structured JSON, zero-dep |
| Metrics | optional Prometheus-format `/metrics` via `prometheus/client_golang` | — | Interop; default off |
| Notifications | HTTPS webhook + **ntfy** client | SMTP, Telegram-bot | ntfy is self-hostable, simple; webhook generic |
| Testing | stdlib `testing` + `testcontainers-go` | — | Integration tests against real docker socket |
| Build | **Makefile** + GitHub Actions; cross-compile matrix | — | Reproducible multi-arch builds |
| Release | **goreleaser** | manual | Signed multi-platform artifacts + SBOM |

## 3. Data & infra

| Concern | Choice | Why |
|---------|--------|-----|
| App DB | Drift/SQLite (device) | §2 of this table + [12](./12-database-design.md) |
| Agent state | in-memory + small file-backed stores (tokens hashed, alert ring, audit ring) | No DB dependency on the server; survives restart |
| No cloud services | — | Core principle; enforced in architecture review |
| CI/CD | **GitHub Actions** | Co-located with GitHub planning ([18](./18-github-planning.md)); runners for Linux/macOS (iOS build); self-hosted runner optional |
| Repos | Monorepo (`app/` + `agent/` + `docs/`) | v1: single repo simplifies cross-cutting changes (API versioning, docs, releases). **Tradeoff:** larger CI surface. Split decision documented in [16](./16-folder-structure.md) §7 |

## 4. Testing toolchain

- **App:** `flutter test`, `mocktail`, `golden_toolkit`, `integration_test` (device farm via Firebase Test Lab / BrowserStack — opt-in).
- **Agent:** `go test ./...`, `testcontainers-go`, `go vet`, `staticcheck`, `govulncheck`, fuzzing (Go built-in) on path/input parsers.
- **Contract:** OpenAPI validation in both CI pipelines.

## 5. Documentation & DX

- **mkdocs** (or VitePress `[OPEN]`) for the public docs site (self-hostable, static).
- **Conventional Commits** + `commitlint` for changelog automation.
- **AsciiDoc/Mermaid** in-repo for architecture (already used here).

## 6. Version compatibility matrix

See [09-architecture.md](./09-architecture.md) §6. Pin policy:
- Flutter: pin to a specific stable build for CI reproducibility (via `fvm`).
- Go: minimum `go 1.22` in `go.mod`.
- Dart/Flutter deps: locked by `pubspec.lock`; Renovate for updates.

## 7. Challenged decisions (and why we keep them)

| Decision | Challenge | Verdict |
|----------|-----------|---------|
| Flutter vs native | Flutter adds ~10–20MB; native is lighter | Accept. Cross-platform velocity + single codebase outweigh footprint for v1; footprint watch-listed |
| go_router vs AutoRoute | AutoRoute has codegen-first ergonomics | Keep go_router: explicit routes match deep-link model, fewer codegen layers |
| Drift vs Isar | Isar faster for pure key-value | Keep Drift: relational cache queries + migrations matter more; speed is fine for our volumes |
| stdlib http vs chi | chi has nicer routing/middleware ergonomics | Keep stdlib: Go 1.22 patterns cover our needs; zero-dep wins on security posture |
| Monorepo vs polyrepo | Polyrepo isolates agent/app | Keep monorepo for v1 velocity (shared API specs, paired releases); revisit at v3 scale |
