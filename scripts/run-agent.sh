#!/usr/bin/env bash
set -euo pipefail

# qwe1 agent runner — run this ON the Linux server (terminal 1).
#
# Pulls git, builds the agent, and starts it in a shared runtime directory so
# that ./scripts/token.sh (terminal 2) can generate tokens against the same
# auth store.
#
# Usage:
#   ./scripts/run-agent.sh             # pull main, build, start agent (foreground)
#   ./scripts/run-agent.sh --port 9443 # use a specific port
#   ./scripts/run-agent.sh --daemon    # start in background (logs to scripts/.runtime/agent.log)
#   ./scripts/run-agent.sh --no-pull   # skip git pull
#
# Requires: bash 4+, curl, git, go 1.22+.

CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
NC=$'\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${REPO_DIR}/agent"
BRANCH="main"
PORT="9443"
RUNTIME_DIR="${REPO_DIR}/scripts/.runtime"
CONFIG_FILE="${RUNTIME_DIR}/config.yaml"
BIN="${RUNTIME_DIR}/qwe1-agent"
DAEMON=0
DO_PULL=1

log() { echo -e "${CYAN}[agent]${NC} $*"; }
good() { echo -e "${GREEN}==>${NC} $*"; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-pull) DO_PULL=0; shift ;;
        --port)    PORT="$2"; shift 2 ;;
        --daemon)  DAEMON=1; shift ;;
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

cat > "$CONFIG_FILE" <<EOF
serverName: qwe1-runtime
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

# ---------------------------------------------------------------- run
if [[ "$DAEMON" -eq 1 ]]; then
    log "starting agent in background (port ${PORT})"
    ( cd "$RUNTIME_DIR" && exec nohup "$BIN" --config "$CONFIG_FILE" >> "${RUNTIME_DIR}/agent.log" 2>&1 ) &
    echo $! > "${RUNTIME_DIR}/agent.pid"
    sleep 1
    if curl -s -o /dev/null "http://127.0.0.1:${PORT}/status"; then
        good "agent running (pid $(cat "${RUNTIME_DIR}/agent.pid"), port ${PORT})"
        good "in another terminal run: ./scripts/token.sh --port ${PORT}"
        good "stop with: kill \$(cat scripts/.runtime/agent.pid)"
    else
        log "agent failed to start — see scripts/.runtime/agent.log"
        cat "${RUNTIME_DIR}/agent.log" >&2
        exit 1
    fi
else
    good "starting agent on 0.0.0.0:${PORT} (press Ctrl-C to stop)"
    good "in another terminal run: ./scripts/token.sh --port ${PORT}"
    ( cd "$RUNTIME_DIR" && exec "$BIN" --config "$CONFIG_FILE" )
fi
