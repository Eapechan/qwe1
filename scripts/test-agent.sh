#!/usr/bin/env bash
set -euo pipefail

# qwe1 agent automated test script.
#
# Usage:
#   ./scripts/test-agent.sh            # pull main, build, unit tests, E2E API checks
#   ./scripts/test-agent.sh --no-pull  # skip git pull (use local code)
#   ./scripts/test-agent.sh --docker   # also run Docker lifecycle checks (requires Docker)
#
# Requires: bash 4+, curl, jq, go 1.22+.

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${REPO_DIR}/agent"
BRANCH="main"
PORT="9443"
BASE_URL="http://127.0.0.1:${PORT}"
WORK_DIR="$(mktemp -d)"
CONFIG_FILE="${WORK_DIR}/config.yaml"
AUTH_FILE="${WORK_DIR}/qwe1-test.auth.json"
BIN="${WORK_DIR}/qwe1-agent"
AGENT_PID=""
DO_PULL=1
DO_DOCKER=0
PASS=0
FAIL=0
SKIP=0

log()  { echo -e "${CYAN}[test]${NC} $*"; }
ok()   { echo -e "${GREEN}PASS${NC}  $*"; PASS=$((PASS + 1)); }
bad()  { echo -e "${RED}FAIL${NC}  $*"; FAIL=$((FAIL + 1)); }
skip() { echo -e "${YELLOW}SKIP${NC}  $*"; SKIP=$((SKIP + 1)); }

for arg in "$@"; do
    case "$arg" in
        --no-pull) DO_PULL=0 ;;
        --docker)  DO_DOCKER=1 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

cleanup() {
    if [[ -n "$AGENT_PID" ]] && kill -0 "$AGENT_PID" 2>/dev/null; then
        log "stopping agent (pid $AGENT_PID)"
        kill "$AGENT_PID" 2>/dev/null || true
        wait "$AGENT_PID" 2>/dev/null || true
    fi
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

require() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing required command: $cmd" >&2
        exit 1
    fi
}

require curl
require go

# Minimal JSON field extractor. Uses jq when available, otherwise python3.
json_get() {
    local json="$1" path="$2"
    if command -v jq >/dev/null 2>&1; then
        echo "$json" | jq -r "$path // empty"
    else
        python3 - "$json" "$path" <<'PYEOF'
import sys, json
data = json.loads(sys.argv[1])
path = sys.argv[2]
for part in path.strip(".").split("."):
    if not part:
        continue
    if isinstance(data, dict) and part in data:
        data = data[part]
    else:
        data = None
        break
print(data if data is not None else "")
PYEOF
    fi
}

# ---------------------------------------------------------------- pull
if [[ "$DO_PULL" -eq 1 ]]; then
    log "pulling origin/${BRANCH}"
    git -C "$REPO_DIR" fetch origin "$BRANCH"
    git -C "$REPO_DIR" checkout "$BRANCH"
    git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"
fi

# ---------------------------------------------------------------- unit tests
log "running go vet + unit tests"
(
    cd "$AGENT_DIR"
    go vet ./...
    go test ./... -count=1
)

# ---------------------------------------------------------------- build
log "building agent"
( cd "$AGENT_DIR" && go build -o "$BIN" ./cmd/qwe1-agent )

# ---------------------------------------------------------------- config
mkdir -p "$WORK_DIR/files"
cat > "$CONFIG_FILE" <<EOF
serverName: qwe1-test
listenHost: 127.0.0.1
listenPort: ${PORT}
tlsCertPath: ""
tlsKeyPath: ""
auth:
  tokenLength: 16
  accessTokenTTL: 900
  refreshTokenTTL: 2592000
  maxAttempts: 5
  lockoutDuration: 1800
docker:
  enabled: true
  socketPath: /var/run/docker.sock
host:
  metricsInterval: 2
files:
  allowedRoots:
    - ${WORK_DIR}/files
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
EOF

# ---------------------------------------------------------------- enrollment token
log "generating enrollment token"
ENROLL_OUT="$(cd "$WORK_DIR" && "$BIN" --enroll --config "$CONFIG_FILE" 2>/dev/null | grep -oE "Enrollment Token: [A-Za-z0-9_-]+" | awk '{print $3}')"
if [[ -z "$ENROLL_OUT" ]]; then
    bad "enrollment token generation"
    exit 1
fi
ok "enrollment token generated"

# ---------------------------------------------------------------- start agent
log "starting agent on ${BASE_URL}"
( cd "$WORK_DIR" && "$BIN" --config "$CONFIG_FILE" > "$WORK_DIR/agent.log" 2>&1 ) &
AGENT_PID=$!
sleep 1

# Wait for /status
log "waiting for agent to be ready"
READY=0
for i in $(seq 1 30); do
    if curl -s -o /dev/null "${BASE_URL}/status"; then
        READY=1
        break
    fi
    sleep 1
done
if [[ "$READY" -ne 1 ]]; then
    bad "agent did not become ready"
    cat "$WORK_DIR/agent.log" >&2
    exit 1
fi
ok "agent ready"

# ---------------------------------------------------------------- enroll via API
log "enrolling via API"
ENROLL_RESP="$(curl -s -X POST "${BASE_URL}/auth/enroll" \
    -H 'Content-Type: application/json' \
    -d "{\"enrollmentToken\":\"${ENROLL_OUT}\",\"device\":{\"name\":\"e2e-test\",\"platform\":\"cli\"}}")"
TOKEN="$(json_get "$ENROLL_RESP" ".accessToken")"
if [[ -z "$TOKEN" ]]; then
    bad "API enrollment"
    echo "$ENROLL_RESP" >&2
    exit 1
fi
ok "API enrollment (access token issued)"

AUTH="Authorization: Bearer ${TOKEN}"

# ---------------------------------------------------------------- checks
check_status() {
    local name="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then
        ok "$name"
    else
        bad "$name (expected HTTP $expected, got $actual)"
    fi
}

http_code() {
    curl -s -o /dev/null -w '%{http_code}' "$@"
}

log "running endpoint checks"

# Public + auth
check_status "GET /status (public)"     200 "$(http_code "${BASE_URL}/status")"
check_status "GET /status (with token)" 200 "$(http_code -H "$AUTH" "${BASE_URL}/status")"
check_status "GET /metrics/latest no auth -> 401" 401 "$(http_code "${BASE_URL}/metrics/latest")"
check_status "GET /auth/me"             200 "$(http_code -H "$AUTH" "${BASE_URL}/auth/me")"

# Metrics (verify expanded fields)
METRICS="$(curl -s -H "$AUTH" "${BASE_URL}/metrics/latest")"
if echo "$METRICS" | grep -qE '"(cache|buffers|diskIO|perInterface|processes)"'; then
    ok "metrics include expanded fields (cache/buffers/diskIO/perInterface/processes)"
else
    bad "metrics missing expanded fields"
fi

# Filesystem round-trip: write -> list -> copy -> search
WRITE_CODE="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" -H 'Content-Type: application/json' \
    -d '{"path":"hello.txt","content":"qwe1 e2e"}' "${BASE_URL}/fs/write")"
check_status "POST /fs/write" 200 "$WRITE_CODE"

LIST_CODE="$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/fs/list?path=")"
check_status "GET /fs/list" 200 "$LIST_CODE"

COPY_CODE="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" -H 'Content-Type: application/json' \
    -d '{"from":"hello.txt","to":"hello-copy.txt"}' "${BASE_URL}/fs/copy")"
check_status "POST /fs/copy" 201 "$COPY_CODE"

SEARCH_CODE="$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/fs/search?q=hello")"
check_status "GET /fs/search" 200 "$SEARCH_CODE"

# Docker (200 when socket present, 503 skip when absent)
check_docker() {
    local name="$1" url="$2"
    local code
    code="$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "$url")"
    if [[ "$code" == "200" ]]; then
        ok "$name"
    elif [[ "$code" == "503" ]]; then
        skip "$name (docker socket unavailable)"
    else
        bad "$name (expected HTTP 200, got $code)"
    fi
}
DOCKER_CODES="$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/docker/images")"
check_docker "GET /docker/images" "${BASE_URL}/docker/images"
check_docker "GET /docker/volumes" "${BASE_URL}/docker/volumes"
check_docker "GET /docker/networks" "${BASE_URL}/docker/networks"

# Profiling
check_status "GET /debug/pprof/" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/debug/pprof/")"
PROFILE_CODE="$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/debug/pprof/profile?seconds=1")"
check_status "GET /debug/pprof/profile" 200 "$PROFILE_CODE"

# Stubbed endpoints (should return 200 with empty body)
check_status "GET /metrics/history (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/metrics/history")"
check_status "GET /alerts/thresholds (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/alerts/thresholds")"
check_status "GET /audit (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/audit")"

# ---------------------------------------------------------------- optional docker lifecycle
if [[ "$DO_DOCKER" -eq 1 ]]; then
    log "running Docker lifecycle checks"
    if [[ "$DOCKER_CODES" != "200" ]]; then
        skip "Docker socket unreachable — lifecycle checks skipped"
    else
        IMG="alpine:latest"
        log "pulling ${IMG}"
        PULL_CODE="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/images/${IMG}/pull")"
        check_status "POST /docker/images/alpine:latest/pull" 202 "$PULL_CODE"

        CID="$(curl -s -H "$AUTH" "${BASE_URL}/docker/containers" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next((c["id"] for c in d.get("items",[]) if "alpine" in c.get("image","")), ""))')"
        if [[ -n "$CID" ]]; then
            check_status "POST /docker/containers/${CID}/start" 200 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/containers/${CID}/start")"
            check_status "POST /docker/containers/${CID}/restart" 200 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/containers/${CID}/restart")"
        else
            skip "no alpine container found to lifecycle-test"
        fi
    fi
fi

# ---------------------------------------------------------------- summary
echo ""
echo "============================================"
echo "  qwe1 agent test summary"
echo "============================================"
echo "  PASS:  $PASS"
echo "  FAIL:  $FAIL"
echo "  SKIP:  $SKIP"
echo "============================================"

if [[ "$FAIL" -gt 0 ]]; then
    echo "Result: ${RED}FAIL${NC}"
    exit 1
fi
echo "Result: ${GREEN}PASS${NC}"
