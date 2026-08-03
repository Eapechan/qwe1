#!/usr/bin/env bash
set -euo pipefail

# ─── qwe1 single run script ───
# Usage:
#   ./run.sh              Full flow: git pull → build → token+QR → run agent
#   ./run.sh --force      Force rebuild even if binary is current
#   ./run.sh --no-pull    Skip git pull
#   ./run.sh --foreground Run agent in foreground (stream logs)
#   ./run.sh stop         Stop the background agent
#   ./run.sh status       Show agent status
#   ./run.sh token        Regenerate token + QR (stops agent → enroll → restart)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AGENT_BIN="./agent/qwe1-agent"
CONFIG="config.yaml"
PID_FILE="agent.pid"
LOG_FILE="agent.log"
QR_FILE="enroll-qr.png"

# ─── Helpers ────────────────────────────────────────────────────
red()    { printf '\033[1;31m%s\033[0m\n' "$*"; }
green()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$*"; }
info()   { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()    { red "Error: $*" >&2; exit 1; }

parse_port() {
  grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g' || echo "9443"
}

get_port() {
  local port
  port=$(parse_port)
  [ -z "$port" ] && port=9443
  echo "$port"
}

check_go() {
  command -v go >/dev/null 2>&1 || die "Go is not installed. Install Go >= 1.25: https://go.dev/dl/"
  local ver
  ver=$(go version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  local major minor
  major=$(echo "$ver" | cut -d. -f1)
  minor=$(echo "$ver" | cut -d. -f2)
  if [ "$major" -lt 1 ] || { [ "$major" -eq 1 ] && [ "$minor" -lt 25 ]; }; then
    die "Go $ver found, but >= 1.25 is required. Install: https://go.dev/dl/"
  fi
  info "Go $ver detected"
}

git_pull() {
  if [ ! -d .git ]; then
    yellow "Not a git repo — skipping pull"
    return
  fi
  info "Pulling latest from origin main..."
  if ! git pull --ff-only origin main 2>&1; then
    yellow "git pull failed or no updates — continuing with current code"
  fi
}

ensure_config() {
  if [ -f "$CONFIG" ]; then
    info "Config found: $CONFIG"
    return
  fi
  # config.yaml missing — write a minimal working HTTP config.
  # Do NOT copy config.example.yaml: its TLS paths point to certs that
  # don't exist and would prevent the agent from starting.
  info "config.yaml not found — creating minimal HTTP config"
  cat > "$CONFIG" <<'EOF'
serverName: my-server
listenHost: 0.0.0.0
listenPort: 9443
tlsCertPath: ""
tlsKeyPath: ""
advertiseUrl: ""
advertiseTailscaleUrl: ""
auth:
  accessTokenTTL: 900
  refreshTokenTTL: 2592000
  enrollmentTTL: 3600
docker:
  enabled: false
  socketPath: /var/run/docker.sock
host:
  metricsInterval: 5
terminal:
  maxSessions: 4
  idleTimeout: 300
files:
  allowedRoots:
    - /home
    - /var/log
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
EOF
  info "Created $CONFIG (HTTP mode — set tlsCertPath/tlsKeyPath for HTTPS)"
}

needs_build() {
  [ ! -f "$AGENT_BIN" ] || [ agent/cmd/qwe1-agent/main.go -nt "$AGENT_BIN" ] || \
    find agent -name '*.go' -newer "$AGENT_BIN" -print -quit | grep -q .
}

build_agent() {
  check_go
  if [ "${FORCE:-0}" -ne 1 ] && ! needs_build; then
    info "Agent binary is current — skipping build (use --force to rebuild)"
    return
  fi
  info "Building agent..."
  cd agent
  CGO_ENABLED=0 go build -trimpath -o qwe1-agent ./cmd/qwe1-agent
  cd ..
  local size
  size=$(du -h "$AGENT_BIN" | cut -f1)
  green "Built: $AGENT_BIN ($size)"
}

enroll() {
  [ -f "$AGENT_BIN" ] || die "Agent binary not found at $AGENT_BIN — run build first"
  info "Generating enrollment token + QR code..."
  echo ""
  "$AGENT_BIN" --enroll --config "$CONFIG"
  echo ""
  if [ -f "$QR_FILE" ]; then
    info "QR code saved: $QR_FILE"
  fi
}

kill_stray_agents() {
  # Kill any qwe1-agent processes not managed by this PID file.
  local stray_pids
  stray_pids=$(pgrep -f 'qwe1-agent' 2>/dev/null || true)
  if [ -n "$stray_pids" ]; then
    info "Killing stray agent process(es): $stray_pids"
    pkill -f 'qwe1-agent' 2>/dev/null || true
    sleep 1
  fi
}

start_agent() {
  [ -f "$AGENT_BIN" ] || die "Agent binary not found at $AGENT_BIN"
  local port
  port=$(get_port)

  # If our PID file says it's alive, stop first.
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    info "Agent already running (PID $(cat "$PID_FILE")) — stopping first"
    stop_agent
  fi

  # Kill any stray processes holding the port.
  kill_stray_agents

  info "Starting agent..."
  nohup "$AGENT_BIN" --config "$CONFIG" >> "$LOG_FILE" 2>&1 &
  local pid=$!
  echo "$pid" > "$PID_FILE"
  sleep 1

  # Check if the process survived.
  if kill -0 "$pid" 2>/dev/null; then
    green "Agent started (PID $pid)"
  else
    # Check if the port was busy (the most common cause).
    if grep -qi 'address already in use' "$LOG_FILE" 2>/dev/null; then
      yellow "Port $port was busy — retrying after cleanup"
      kill_stray_agents
      sleep 1
      nohup "$AGENT_BIN" --config "$CONFIG" >> "$LOG_FILE" 2>&1 &
      pid=$!
      echo "$pid" > "$PID_FILE"
      sleep 1
      if kill -0 "$pid" 2>/dev/null; then
        green "Agent started (PID $pid)"
      else
        red "Agent failed to start after cleanup — check $LOG_FILE"
        tail -20 "$LOG_FILE"
        rm -f "$PID_FILE"
        exit 1
      fi
    else
      red "Agent failed to start — check $LOG_FILE"
      tail -20 "$LOG_FILE"
      rm -f "$PID_FILE"
      exit 1
    fi
  fi

  # Health check with retries.
  local ok=0
  for i in 1 2 3 4 5; do
    if curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1; then
      ok=1
      break
    fi
    sleep 0.5
  done
  if [ "$ok" -eq 1 ]; then
    green "Health check OK (port $port)"
  else
    yellow "Agent started but health check failed — check $LOG_FILE"
  fi
}

stop_agent() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      info "Stopping agent (PID $pid)..."
      kill "$pid" 2>/dev/null || true
      sleep 1
      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null || true
      fi
      green "Agent stopped"
    else
      yellow "Agent not running (stale PID file)"
    fi
    rm -f "$PID_FILE"
  fi

  # Kill any stragglers not tracked by PID file.
  local stray_pids
  stray_pids=$(pgrep -f 'qwe1-agent' 2>/dev/null || true)
  if [ -n "$stray_pids" ]; then
    info "Stopping remaining agent process(es): $stray_pids"
    pkill -f 'qwe1-agent' 2>/dev/null || true
    sleep 1
  fi

  [ ! -f "$PID_FILE" ] || rm -f "$PID_FILE"
  green "Agent stopped"
}

status_agent() {
  local port
  port=$(get_port)
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    local pid
    pid=$(cat "$PID_FILE")
    green "Agent running (PID $pid)"
    curl -sf "http://127.0.0.1:${port}/status" 2>/dev/null | python3 -m json.tool 2>/dev/null || \
      curl -sf "http://127.0.0.1:${port}/status" 2>/dev/null
  else
    yellow "Agent not running"
  fi
}

print_summary() {
  local port
  port=$(get_port)
  echo ""
  green "═══════════════════════════════════════════════"
  green "  qwe1 Agent — Ready"
  green "═══════════════════════════════════════════════"
  echo ""
  echo "  Agent PID : $(cat "$PID_FILE" 2>/dev/null || echo 'not running')"
  echo "  URL       : http://0.0.0.0:${port}"
  echo "  Log       : $LOG_FILE"
  [ -f "$QR_FILE" ] && echo "  QR code   : $QR_FILE"
  echo ""
  echo "  Scan the QR code with the qwe1 app to pair."
  echo "  Token is valid for 1 hour and reusable."
  echo ""
  echo "  Commands:"
  echo "    ./run.sh status    — check agent health"
  echo "    ./run.sh stop      — stop the agent"
  echo "    ./run.sh token     — regenerate token + QR"
  echo "    ./run.sh --help    — show all flags"
  echo ""
}

# ─── Main ───────────────────────────────────────────────────────
FORCE=0
NO_PULL=0
FOREGROUND=0
ACTION="full"

for arg in "$@"; do
  case "$arg" in
    --force)      FORCE=1 ;;
    --no-pull)    NO_PULL=1 ;;
    --foreground) FOREGROUND=1 ;;
    --help|-h)
      echo "Usage: ./run.sh [--force] [--no-pull] [--foreground] [stop|status|token]"
      echo ""
      echo "Flags:"
      echo "  --force       Force rebuild even if binary is current"
      echo "  --no-pull     Skip git pull"
      echo "  --foreground  Run agent in foreground (stream logs)"
      echo ""
      echo "Commands:"
      echo "  (default)     Full flow: pull → build → token+QR → start"
      echo "  stop          Stop the background agent (including stragglers)"
      echo "  status        Check agent health"
      echo "  token         Stop agent → regenerate token+QR → restart"
      exit 0
      ;;
    stop)   ACTION="stop" ;;
    status) ACTION="status" ;;
    token)  ACTION="token" ;;
    *)      die "Unknown argument: $arg" ;;
  esac
done

case "$ACTION" in
  stop)
    stop_agent
    ;;
  status)
    status_agent
    ;;
  token)
    check_go
    ensure_config
    build_agent
    # Stop agent first to avoid two-process auth-store write race.
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      info "Stopping agent before regenerating token..."
      stop_agent
    fi
    # Also kill strays that might hold the port.
    kill_stray_agents
    enroll
    # Restart agent with fresh token.
    start_agent
    print_summary
    ;;
  full)
    if [ "$NO_PULL" -ne 0 ]; then
      yellow "Skipping git pull (--no-pull)"
    else
      git_pull
    fi
    ensure_config
    build_agent
    enroll
    if [ "$FOREGROUND" -ne 0 ]; then
      exec "$AGENT_BIN" --config "$CONFIG"
    else
      start_agent
      print_summary
    fi
    ;;
esac
