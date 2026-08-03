#!/usr/bin/env bash
set -euo pipefail

# qwe1 development agent runner — everything in ONE terminal.
#
# Builds the agent, starts it, and generates the enrollment token — so you can
# copy the token straight into the app without opening a second terminal.
#
# Modes:
#   ./scripts/dev.sh                start agent + print enrollment token (stays attached)
#   ./scripts/dev.sh --daemon       start agent in background, return to shell
#   ./scripts/dev.sh --exchange     ALSO exchange the token for an access token
#   ./scripts/dev.sh --test         full pipeline: vet + unit tests + E2E API checks
#   ./scripts/dev.sh --stop         stop the daemon started with --daemon
#
# Options:
#   --port 9443    use a specific port (default 9443)
#   --days 30      enrollment token validity in days (default 365)
#   --no-pull      skip git pull
#
# Requires: bash 4+, curl, git, go 1.22+. jq optional (python3 fallback).

CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${REPO_DIR}/agent"
BRANCH="main"
PORT="9443"
DAYS=365
RUNTIME_DIR="${REPO_DIR}/scripts/.runtime"
CONFIG_FILE="${RUNTIME_DIR}/config.yaml"
BIN="${RUNTIME_DIR}/qwe1-agent"
PID_FILE="${RUNTIME_DIR}/agent.pid"
LOG_FILE="${RUNTIME_DIR}/agent.log"
MODE="live"
DO_PULL=1
DO_EXCHANGE=0
DO_DOCKER=0

log()  { echo -e "${CYAN}[dev]${NC} $*"; }
good() { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}!!${NC} $*"; }

usage() {
    sed -n '2,20p' "${BASH_SOURCE[0]}"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)      PORT="$2"; shift 2 ;;
        --days)      DAYS="$2"; shift 2 ;;
        --no-pull)   DO_PULL=0; shift ;;
        --daemon)    MODE="daemon"; shift ;;
        --exchange)  DO_EXCHANGE=1; shift ;;
        --test)      MODE="test"; shift ;;
        --stop)      MODE="stop"; shift ;;
        --docker)    DO_DOCKER=1; shift ;;
        -h|--help)   usage ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

require() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing required command: $cmd" >&2
        exit 1
    fi
}

require curl
require git
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

stop_agent() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid="$(cat "$PID_FILE")"
        if kill -0 "$pid" 2>/dev/null; then
            log "stopping agent (pid $pid)"
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
}

# ---------------------------------------------------------------- --stop
if [[ "$MODE" == "stop" ]]; then
    stop_agent
    good "agent stopped"
    exit 0
fi

# ---------------------------------------------------------------- pull
if [[ "$DO_PULL" -eq 1 ]]; then
    log "pulling origin/${BRANCH}"
    git -C "$REPO_DIR" fetch origin "$BRANCH"
    git -C "$REPO_DIR" checkout "$BRANCH"
    git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"
fi

# ---------------------------------------------------------------- build
mkdir -p "$RUNTIME_DIR/files"
log "building agent"
( cd "$AGENT_DIR" && go build -o "$BIN" ./cmd/qwe1-agent )

write_config() {
    cat > "$CONFIG_FILE" <<EOF
serverName: qwe1-dev
listenHost: 0.0.0.0
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
    - ${RUNTIME_DIR}/files
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
EOF
}

# ---------------------------------------------------------------- --test
if [[ "$MODE" == "test" ]]; then
    TEST_WORK="$(mktemp -d)"
    TEST_BIN="${TEST_WORK}/qwe1-agent"
    TEST_CFG="${TEST_WORK}/config.yaml"
    AGENT_PID=""
    PASS=0
    FAIL=0
    SKIP=0

    ok()   { echo -e "${GREEN}PASS${NC}  $*"; PASS=$((PASS + 1)); }
    bad()  { echo -e "${RED}FAIL${NC}  $*"; FAIL=$((FAIL + 1)); }
    skip() { echo -e "${YELLOW}SKIP${NC}  $*"; SKIP=$((SKIP + 1)); }

    cleanup() {
        if [[ -n "$AGENT_PID" ]] && kill -0 "$AGENT_PID" 2>/dev/null; then
            kill "$AGENT_PID" 2>/dev/null || true
            wait "$AGENT_PID" 2>/dev/null || true
        fi
        rm -rf "$TEST_WORK"
    }
    trap cleanup EXIT

    log "running go vet + unit tests"
    ( cd "$AGENT_DIR" && go vet ./... && go test ./... -count=1 )

    log "building test agent"
    ( cd "$AGENT_DIR" && go build -o "$TEST_BIN" ./cmd/qwe1-agent )

    mkdir -p "$TEST_WORK/files"
    cat > "$TEST_CFG" <<EOF
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
    - ${TEST_WORK}/files
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
EOF

    BASE_URL="http://127.0.0.1:${PORT}"
    log "generating enrollment token"
    ENROLL_OUT="$(cd "$TEST_WORK" && "$TEST_BIN" --enroll --config "$TEST_CFG" 2>/dev/null | grep -oE "Enrollment Token: [A-Za-z0-9_-]+" | awk '{print $3}')"
    if [[ -z "$ENROLL_OUT" ]]; then
        bad "enrollment token generation"
        exit 1
    fi
    ok "enrollment token generated"

    log "starting agent on ${BASE_URL}"
    ( cd "$TEST_WORK" && exec "$TEST_BIN" --config "$TEST_CFG" > "$TEST_WORK/agent.log" 2>&1 ) &
    AGENT_PID=$!
    sleep 1

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
        cat "$TEST_WORK/agent.log" >&2
        exit 1
    fi
    ok "agent ready"

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
    check_status "GET /status (public)"     200 "$(http_code "${BASE_URL}/status")"
    check_status "GET /status (with token)" 200 "$(http_code -H "$AUTH" "${BASE_URL}/status")"
    check_status "GET /metrics/latest no auth -> 401" 401 "$(http_code "${BASE_URL}/metrics/latest")"
    check_status "GET /auth/me"             200 "$(http_code -H "$AUTH" "${BASE_URL}/auth/me")"

    METRICS="$(curl -s -H "$AUTH" "${BASE_URL}/metrics/latest")"
    if echo "$METRICS" | grep -qE '"(cache|buffers|diskIO|perInterface|processes)"'; then
        ok "metrics include expanded fields (cache/buffers/diskIO/perInterface/processes)"
    else
        bad "metrics missing expanded fields"
    fi

    WRITE_CODE="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" -H 'Content-Type: application/json' \
        -d '{"path":"hello.txt","content":"qwe1 e2e"}' "${BASE_URL}/fs/write")"
    check_status "POST /fs/write" 200 "$WRITE_CODE"
    check_status "GET /fs/list" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/fs/list?path=")"
    COPY_CODE="$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" -H 'Content-Type: application/json' \
        -d '{"from":"hello.txt","to":"hello-copy.txt"}' "${BASE_URL}/fs/copy")"
    check_status "POST /fs/copy" 201 "$COPY_CODE"
    check_status "GET /fs/search" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/fs/search?q=hello")"

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

    check_status "GET /debug/pprof/" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/debug/pprof/")"
    check_status "GET /debug/pprof/profile" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/debug/pprof/profile?seconds=1")"
    check_status "GET /metrics/history (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/metrics/history")"
    check_status "GET /alerts/thresholds (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/alerts/thresholds")"
    check_status "GET /audit (stubbed)" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" "${BASE_URL}/audit")"

    if [[ "$DO_DOCKER" -eq 1 ]]; then
        log "running Docker lifecycle checks"
        if [[ "$DOCKER_CODES" != "200" ]]; then
            skip "Docker socket unreachable — lifecycle checks skipped"
        else
            IMG="alpine:latest"
            log "pulling ${IMG}"
            check_status "POST /docker/images/alpine:latest/pull" 202 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/images/${IMG}/pull")"
            CONTAINERS="$(curl -s -H "$AUTH" "${BASE_URL}/docker/containers")"
            CID="$(echo "$CONTAINERS" | python3 -c 'import sys,json
d=json.load(sys.stdin)
print(next((c["id"] for c in d.get("items",[]) if "alpine" in c.get("image","")), ""))' 2>/dev/null || echo '')"
            if [[ -n "$CID" ]]; then
                check_status "POST /docker/containers/${CID}/start" 200 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/containers/${CID}/start")"
                check_status "POST /docker/containers/${CID}/restart" 200 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$AUTH" "${BASE_URL}/docker/containers/${CID}/restart")"
            else
                skip "no alpine container found to lifecycle-test"
            fi
        fi
    fi

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
    exit 0
fi

# ---------------------------------------------------------------- live / daemon
if [[ "$MODE" == "daemon" ]] && [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    warn "agent already running (pid $(cat "$PID_FILE"), port $(grep -m1 'listenPort' "$CONFIG_FILE" 2>/dev/null | awk '{print $2}'))"
    exit 1
fi

write_config
stop_agent

log "starting agent on 0.0.0.0:${PORT}"
( cd "$RUNTIME_DIR" && exec nohup "$BIN" --config "$CONFIG_FILE" >> "$LOG_FILE" 2>&1 ) &
echo $! > "$PID_FILE"
sleep 1

if ! curl -s -o /dev/null "http://127.0.0.1:${PORT}/status"; then
    bad "agent failed to start — see ${LOG_FILE}"
    cat "$LOG_FILE" >&2
    exit 1
fi
good "agent running (pid $(cat "$PID_FILE"), port ${PORT})"

log "generating enrollment token"
ENROLL_OUT="$(cd "$RUNTIME_DIR" && "$BIN" --enroll --enroll-days "$DAYS" --config "$CONFIG_FILE" 2>/dev/null | grep -oE "Enrollment Token: [A-Za-z0-9_-]+" | awk '{print $3}')"
if [[ -z "$ENROLL_OUT" ]]; then
    bad "failed to generate enrollment token"
    exit 1
fi

echo ""
echo "${GREEN}==============================================${NC}"
echo "${GREEN}  qwe1 enrollment token (single-use)${NC}"
echo "${GREEN}==============================================${NC}"
echo "  Server URL:  http://YOUR_SERVER_IP:${PORT}"
echo "  Token:       ${ENROLL_OUT}"
echo ""
echo "${YELLOW}Paste this token into the qwe1 app — it is single-use,${NC}"
echo "${YELLOW}so do NOT regenerate/exchange it before pairing.${NC}"
echo "${GREEN}==============================================${NC}"
echo ""

if [[ "$DO_EXCHANGE" -eq 1 ]]; then
    warn "exchanging token — this CONSUMES it and it can no longer be used in the app"
    RESP="$(curl -s --max-time 5 -X POST "http://127.0.0.1:${PORT}/auth/enroll" \
        -H 'Content-Type: application/json' \
        -d "{\"enrollmentToken\":\"${ENROLL_OUT}\",\"device\":{\"name\":\"cli\",\"platform\":\"cli\"}}")"
    ACCESS="$(json_get "$RESP" ".accessToken")"
    if [[ -n "$ACCESS" ]]; then
        echo "${GREEN}Access token:${NC} $ACCESS"
        echo "${YELLOW}Use:${NC} curl -H \"Authorization: Bearer $ACCESS\" http://127.0.0.1:${PORT}/metrics/latest"
    else
        warn "could not exchange token — is the agent running? Response:"
        echo "$RESP"
    fi
fi

if [[ "$MODE" == "daemon" ]]; then
    good "agent running in background (logs: ${LOG_FILE})"
    good "stop with: ./scripts/dev.sh --stop"
    exit 0
fi

# Live mode: stay attached to logs; Ctrl-C stops the agent.
good "attached to agent logs — press Ctrl-C to stop the agent"
trap 'log "stopping agent"; stop_agent; exit 0' INT TERM
tail -f "$LOG_FILE"
