#!/usr/bin/env bash
set -euo pipefail

# qwe1 agent token generator — run this ON the Linux server (terminal 2).
#
# Generates an enrollment token and exchanges it for an access token against
# the agent started by ./scripts/run-agent.sh. Uses the same shared runtime
# directory (scripts/.runtime) so the token lands in the running agent's store.
#
# Usage:
#   ./scripts/token.sh                   # generate + exchange (default port 9443)
#   ./scripts/token.sh --port 9443       # use a specific port
#   ./scripts/token.sh --enroll-only     # just print the enrollment token
#   ./scripts/token.sh --days 30         # enrollment token validity in days
#
# Requires: bash 4+, curl, git, go 1.22+.

CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${REPO_DIR}/agent"
PORT="9443"
DAYS=365
RUNTIME_DIR="${REPO_DIR}/scripts/.runtime"
CONFIG_FILE="${RUNTIME_DIR}/config.yaml"
BIN="${RUNTIME_DIR}/qwe1-agent"
ENROLL_ONLY=0

cleanup() {
    rm -f "${RUNTIME_DIR}/.enroll.out"
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)         PORT="$2"; shift 2 ;;
        --days)         DAYS="$2"; shift 2 ;;
        --enroll-only)  ENROLL_ONLY=1; shift ;;
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

# If the runtime config is missing, build one (mirrors run-agent.sh).
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "${YELLOW}[token]${NC} no runtime config found — creating scripts/.runtime"
    mkdir -p "$RUNTIME_DIR/files"
    cat > "$CONFIG_FILE" <<EOF
serverName: qwe1-runtime
listenHost: 0.0.0.0
listenPort: ${PORT}
tlsCertPath: ""
tlsKeyPath: ""
EOF
fi

# Build the agent if the binary is missing.
if [[ ! -x "$BIN" ]]; then
    echo "${CYAN}[token]${NC} building agent"
    ( cd "$AGENT_DIR" && go build -o "$BIN" ./cmd/qwe1-agent )
fi

echo "${CYAN}[token]${NC} generating enrollment token"
ENROLL_OUT="$(cd "$RUNTIME_DIR" && "$BIN" --enroll --enroll-days "$DAYS" --config "$CONFIG_FILE" 2>/dev/null)"
ENROLL_TOKEN="$(echo "$ENROLL_OUT" | grep -oE "Enrollment Token: [A-Za-z0-9_-]+" | awk '{print $3}')"
if [[ -z "$ENROLL_TOKEN" ]]; then
    echo "Failed to generate enrollment token" >&2
    exit 1
fi

echo ""
echo "${GREEN}==========================================${NC}"
echo "${GREEN}  qwe1 enrollment token${NC}"
echo "${GREEN}==========================================${NC}"
echo "$ENROLL_OUT"
echo ""
echo "${GREEN}Enrollment token:${NC} $ENROLL_TOKEN"

if [[ "$ENROLL_ONLY" -eq 1 ]]; then
    exit 0
fi

# Exchange for an access token (requires the agent running).
SERVER="127.0.0.1:${PORT}"
echo ""
echo "${CYAN}[token]${NC} exchanging enrollment token for access token at ${SERVER}"
if RESP="$(curl -s --max-time 5 -X POST "http://${SERVER}/auth/enroll" \
    -H 'Content-Type: application/json' \
    -d "{\"enrollmentToken\":\"${ENROLL_TOKEN}\",\"device\":{\"name\":\"cli-token\",\"platform\":\"cli\"}}")"; then
    ACCESS="$(json_get "$RESP" ".accessToken")"
    if [[ -n "$ACCESS" ]]; then
        echo ""
        echo "${GREEN}Access token:${NC} $ACCESS"
        echo "${YELLOW}Use:${NC} curl -H \"Authorization: Bearer $ACCESS\" http://${SERVER}/metrics/latest"
        exit 0
    fi
    echo "${YELLOW}Note:${NC} could not exchange token — is the agent running? Response:"
    echo "$RESP"
fi

exit 1
