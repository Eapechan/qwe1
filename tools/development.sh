#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$PATH:/Users/binu/flutter/bin"
export JAVA_HOME="$HOME/java/current"

AGENT_BIN="$REPO_ROOT/agent/qwe1-agent"
CONFIG="$REPO_ROOT/config.yaml"
PID_FILE="$REPO_ROOT/agent.pid"
LOG_FILE="$REPO_ROOT/agent.log"

RED()    { printf '\033[1;31m%s\033[0m\n' "$*"; }
GREEN()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
YELLOW() { printf '\033[1;33m%s\033[0m\n' "$*"; }
INFO()   { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

is_linux=true
if [[ "$(uname -s)" == "Darwin" ]]; then
    is_linux=false
    INFO "Running on macOS — Docker validation will be skipped"
fi

exit_with_error() {
    RED "✗ FAIL: $1"
    echo "Suggested fix: $2"
    exit 1
}

check_go() {
    if ! command -v go >/dev/null 2>&1; then
        exit_with_error "Go is not installed" "Install Go >= 1.25: https://go.dev/dl/"
    fi
    local ver major minor
    ver=$(go version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    major=$(echo "$ver" | cut -d. -f1)
    minor=$(echo "$ver" | cut -d. -f2)
    if [ "$major" -lt 1 ] || { [ "$major" -eq 1 ] && [ "$minor" -lt 25 ]; }; then
        exit_with_error "Go $ver found, but >= 1.25 is required" "Upgrade Go: https://go.dev/dl/"
    fi
    INFO "Go $ver detected"
}

ensure_config() {
    if [ ! -f "$CONFIG" ]; then
        INFO "Config not found — creating minimal HTTP config"
        cat > "$CONFIG" << 'EOF'
serverName: qwe1
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
  enabled: true
  socketPath: /var/run/docker.sock
host:
  metricsInterval: 5
  temperaturePath: /sys/class/thermal
terminal:
  maxSessions: 4
  idleTimeout: 300
files:
  allowedRoots:
    - /home
    - /var/log
  maxUpload: 524288000
alerts:
  enabled: false
  bufferSize: 1000
EOF
        INFO "Created $CONFIG (HTTP mode)"
    else
        INFO "Config found: $CONFIG"
    fi
}

needs_build() {
    [ ! -f "$AGENT_BIN" ] && return 0
    find agent -name '*.go' -newer "$AGENT_BIN" -print -quit | grep -q .
}

build_agent() {
    check_go
    if [ ! -f "$AGENT_BIN" ] || needs_build; then
        INFO "Building agent..."
        cd agent
        CGO_ENABLED=0 go build -trimpath -o qwe1-agent ./cmd/qwe1-agent
        cd ..
        local size
        size=$(du -h "$AGENT_BIN" | cut -f1)
        GREEN "✓ PASS: Built $AGENT_BIN ($size)"
    else
        INFO "Agent binary is current — skipping build"
    fi
}

check_port() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    if command -v ss >/dev/null 2>&1; then
        if ss -tln 2>/dev/null | grep -q ":${port} "; then
            exit_with_error "Port $port is already in use" "Run: sudo kill \$(lsof -ti :$port) or change listenPort in config.yaml"
        fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -tln 2>/dev/null | grep -q ":${port} "; then
            exit_with_error "Port $port is already in use" "Run: sudo kill \$(lsof -ti :$port) or change listenPort in config.yaml"
        fi
    fi
}

start_agent() {
    [ -f "$AGENT_BIN" ] || exit_with_error "Agent binary not found at $AGENT_BIN" "Run build first"

    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        INFO "Agent already running (PID $(cat "$PID_FILE")) — stopping first"
        stop_agent
    fi

    if [ "$is_linux" = false ]; then
        INFO "macOS detected — not checking Docker socket"
    else
        if [ ! -S /var/run/docker.sock ]; then
            YELLOW "WARNING: Docker socket not found at /var/run/docker.sock"
            YELLOW "Docker validation will be skipped. Agent may fail at startup."
        fi
    fi

    INFO "Starting agent..."
    nohup "$AGENT_BIN" --config "$CONFIG" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    sleep 1

    if kill -0 "$pid" 2>/dev/null; then
        GREEN "✓ PASS: Agent started (PID $pid)"
    else
        RED "✗ FAIL: Agent failed to start"
        if grep -qi 'address already in use' "$LOG_FILE" 2>/dev/null; then
            YELLOW "Port $port was busy — retrying after cleanup"
            rm -f "$PID_FILE" 2>/dev/null
            pkill -f 'qwe1-agent' 2>/dev/null || true
            sleep 1
            nohup "$AGENT_BIN" --config "$CONFIG" >> "$LOG_FILE" 2>&1 &
            pid=$!
            echo "$pid" > "$PID_FILE"
            sleep 1
            if kill -0 "$pid" 2>/dev/null; then
                GREEN "✓ PASS: Agent started (PID $pid)"
            else
                RED "✗ FAIL: Agent still failed to start after cleanup"
                tail -20 "$LOG_FILE"
                exit 1
            fi
        else
            tail -20 "$LOG_FILE"
            exit 1
        fi
    fi

    local ok=0
    for i in 1 2 3 4 5; do
        if curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1; then
            ok=1
            break
        fi
        sleep 0.5
    done
    if [ "$ok" -eq 1 ]; then
        GREEN "✓ PASS: Health check OK (port $port)"
    else
        YELLOW "⚠ WARNING: Agent started but health check failed"
        YELLOW "Check $LOG_FILE for details"
    fi
}

stop_agent() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            INFO "Stopping agent (PID $pid)..."
            kill "$pid" 2>/dev/null || true
            sleep 1
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
            GREEN "✓ PASS: Agent stopped"
        else
            YELLOW "⚠ WARNING: Agent not running (stale PID file)"
        fi
        rm -f "$PID_FILE"
    fi

    local stray_pids
    stray_pids=$(pgrep -f 'qwe1-agent' 2>/dev/null || true)
    if [ -n "$stray_pids" ]; then
        INFO "Stopping remaining agent process(es): $stray_pids"
        pkill -f 'qwe1-agent' 2>/dev/null || true
        sleep 1
    fi
    [ ! -f "$PID_FILE" ] || rm -f "$PID_FILE"
    GREEN "✓ PASS: Agent stopped"
}

verify_status() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    INFO "Verifying /status endpoint..."
    if curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1; then
        GREEN "✓ PASS: /status endpoint is accessible"
    else
        exit_with_error "/status endpoint is not responding" "Check agent is running and port $port is correct"
    fi
}

verify_metrics() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    INFO "Verifying /metrics/latest endpoint..."
    if curl -sf "http://127.0.0.1:${port}/metrics/latest" >/dev/null 2>&1; then
        GREEN "✓ PASS: /metrics/latest endpoint is accessible"
    else
        exit_with_error "/metrics/latest endpoint is not responding" "Check agent is running and port $port is correct"
    fi
}

verify_websocket() {
    INFO "Verifying WebSocket /ws endpoint..."
    if timeout 2 bash -c '</dev/tcp/127.0.0.1/9443' 2>/dev/null; then
        GREEN "✓ PASS: WebSocket port is open"
    else
        YELLOW "⚠ WARNING: WebSocket port check inconclusive (may be timeout)"
        YELLOW "Note: WebSocket readiness is only visible in the agent logs"
    fi
}

verify_docker() {
    if [ "$is_linux" = true ]; then
        INFO "Verifying Docker availability..."
        if [ ! -S /var/run/docker.sock ]; then
            exit_with_error "Docker socket not found at /var/run/docker.sock" "Ensure Docker is running: sudo systemctl start docker"
        fi

        if ! command -v docker >/dev/null 2>&1; then
            exit_with_error "Docker CLI not found" "Install Docker: https://docs.docker.com/get-docker/"
        fi

        if ! docker version >/dev/null 2>&1; then
            exit_with_error "Docker daemon is not responding" "Check Docker service: sudo systemctl status docker"
        fi

        INFO "Testing Docker container listing..."
        if docker ps >/dev/null 2>&1; then
            GREEN "✓ PASS: Docker API is accessible and listing containers"
        else
            exit_with_error "Docker API failed to list containers" "Check Docker permissions and socket access"
        fi
    else
        INFO "Skipping Docker validation on macOS"
    fi
}

verify_enroll() {
    INFO "Verifying enrollment system..."
    if [ -f "$REPO_ROOT/enroll-qr.png" ]; then
        GREEN "✓ PASS: QR code exists at $REPO_ROOT/enroll-qr.png"
    else
        YELLOW "⚠ WARNING: QR code not found"
        YELLOW "The enrollment system may not be set up yet"
    fi
}

show_summary() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    echo ""
    GREEN "═══════════════════════════════════════════════"
    GREEN "  qwe1 Agent — Development Environment"
    GREEN "═══════════════════════════════════════════════"
    echo ""
    echo "  Agent PID : $(cat "$PID_FILE" 2>/dev/null || echo 'not running')"
    echo "  URL       : http://0.0.0.0:${port}"
    echo "  Log       : $LOG_FILE"
    echo "  Config    : $CONFIG"
    echo ""
    echo "  Running on $(uname -s) ($(uname -m))"
    if [ "$is_linux" = true ]; then
        echo "  Docker    : ✓ available"
    else
        echo "  Docker    : ⚠ skipped on macOS"
    fi
    echo ""
    echo "  Commands:"
    echo "    tools/development.sh  : Start/restart development environment"
    echo "    tools/enroll.sh        : Regenerate enrollment token + QR"
    echo "    tools/diagnose.sh      : Full health check"
    echo ""
}

main() {
    case "${1:-}" in
        start)
            build_agent
            ensure_config
            check_port
            stop_agent
            start_agent
            verify_status
            verify_metrics
            verify_websocket
            verify_docker
            verify_enroll
            show_summary
            ;;
        stop)
            stop_agent
            ;;
        restart)
            stop_agent
            build_agent
            ensure_config
            check_port
            start_agent
            verify_status
            verify_metrics
            verify_websocket
            verify_docker
            verify_enroll
            show_summary
            ;;
        *)
            build_agent
            ensure_config
            check_port
            stop_agent
            start_agent
            verify_status
            verify_metrics
            verify_websocket
            verify_docker
            verify_enroll
            show_summary
            ;;
    esac
}

main "$@"
