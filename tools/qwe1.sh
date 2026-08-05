#!/usr/bin/env bash
#
# qwe1.sh - Unified management script for the qwe1 agent
#
# Single entry point for all development, deployment, and operations.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_DIR="$REPO_ROOT/agent"
AGENT_BIN="$AGENT_DIR/qwe1-agent"
CONFIG="$REPO_ROOT/config.yaml"
PID_FILE="$REPO_ROOT/agent.pid"
LOG_FILE="$REPO_ROOT/agent.log"
QR_FILE="$REPO_ROOT/enroll-qr.png"
ENROLL_OUTPUT="/tmp/qwe1_enroll_output.txt"
VERSION="1.0.0"

HOST_OS="$(uname -s)"
HOST_ARCH="$(uname -m)"
IS_LINUX=false
[[ "$HOST_OS" == "Linux"* ]] && IS_LINUX=true

C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_RESET='\033[0m'

RED()    { printf "${C_RED}%s${C_RESET}\n" "$*"; }
GREEN()  { printf "${C_GREEN}%s${C_RESET}\n" "$*"; }
YELLOW() { printf "${C_YELLOW}%s${C_RESET}\n" "$*"; }
BLUE()   { printf "${C_BLUE}%s${C_RESET}\n" "$*"; }
INFO()   { printf "${C_BLUE}==>${C_RESET} %s\n" "$*"; }
PASS()   { GREEN "  PASS: $1"; }
FAIL()   { RED "  FAIL: $1"; }
WARN()   { YELLOW "  WARN: $1"; }
HEADER() { echo ""; BLUE "=========================================="; BLUE "  $1"; BLUE "=========================================="; echo ""; }

exit_with_error() {
    FAIL "$1"
    [[ -n "${2:-}" ]] && YELLOW "  Fix: $2"
    exit 1
}

get_port() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    echo "${port:-9443}"
}

hash_file() {
    local file="$1"
    [[ -f "$file" ]] || { echo ""; return; }
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        stat -c '%Y' "$file" 2>/dev/null || stat -f '%m' "$file" 2>/dev/null || echo "0"
    fi
}

check_go() {
    command -v go >/dev/null 2>&1 || exit_with_error "Go not installed" "Install Go >= 1.25"
    local ver major minor
    ver=$(go version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    major=$(echo "$ver" | cut -d. -f1)
    minor=$(echo "$ver" | cut -d. -f2)
    if [[ "$major" -lt 1 ]] || { [[ "$major" -eq 1 ]] && [[ "$minor" -lt 25 ]]; }; then
        exit_with_error "Go $ver too old" "Upgrade to Go >= 1.25"
    fi
    echo "$ver"
}

ensure_config() {
    [[ -f "$CONFIG" ]] && return 0
    INFO "Creating config.yaml"
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
}

cmd_build() {
    local go_ver
    go_ver=$(check_go)
    HEADER "Build"
    INFO "Go $go_ver, target: linux/amd64"
    rm -f "$AGENT_BIN"
    cd "$AGENT_DIR"
    if [[ "$IS_LINUX" == true ]]; then
        CGO_ENABLED=0 go build -trimpath -o "$AGENT_BIN" ./cmd/qwe1-agent
    else
        GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -o "$AGENT_BIN" ./cmd/qwe1-agent
    fi
    cd "$REPO_ROOT"
    [[ -f "$AGENT_BIN" ]] || exit_with_error "Build failed"
    local size
    size=$(du -h "$AGENT_BIN" | cut -f1)
    PASS "Built $AGENT_BIN ($size)"
}

get_running_pids() { pgrep -f 'qwe1-agent' 2>/dev/null || true; }
get_pid_from_file() { [[ -f "$PID_FILE" ]] && cat "$PID_FILE" || echo ""; }
is_pid_alive() { [[ -n "$1" ]] && kill -0 "$1" 2>/dev/null; }

wait_for_port_free() {
    local port="$1" max="${2:-15}" i=0
    while (( i < max )); do
        (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null || { exec 3>&- 2>/dev/null || true; return 0; }
        exec 3>&- 2>/dev/null || true; sleep 1; ((i++))
    done
    return 1
}

cmd_stop() {
    HEADER "Stop"
    local found=false
    if [[ -f "$PID_FILE" ]]; then
        local pid; pid=$(get_pid_from_file)
        if is_pid_alive "$pid"; then
            INFO "Stopping PID $pid"
            kill "$pid" 2>/dev/null || true; sleep 1
            is_pid_alive "$pid" && kill -9 "$pid" 2>/dev/null
            found=true; PASS "Stopped PID $pid"
        fi
        rm -f "$PID_FILE"
    fi
    local strays; strays=$(get_running_pids)
    for pid in $strays; do
        INFO "Stopping stray PID $pid"
        kill "$pid" 2>/dev/null || true; sleep 0.5
        is_pid_alive "$pid" && kill -9 "$pid" 2>/dev/null || true
        found=true
    done
    local port; port=$(get_port)
    if wait_for_port_free "$port" 10; then
        [[ "$found" == true ]] && PASS "Port $port free" || PASS "No agent running"
    else
        FAIL "Port $port still in use"; return 1
    fi
}

cmd_start() {
    local port; port=$(get_port)
    HEADER "Start"
    [[ -f "$AGENT_BIN" ]] || exit_with_error "No binary" "Run: ./tools/qwe1.sh build"
    ensure_config
    local existing; existing=$(get_running_pids)
    [[ -n "$existing" ]] && { WARN "Already running"; cmd_stop; }
    (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null && { exec 3>&-; exit_with_error "Port $port in use"; }
    exec 3>&- 2>/dev/null || true
    nohup "$AGENT_BIN" --config "$CONFIG" >> "$LOG_FILE" 2>&1 &
    local pid=$!; echo "$pid" > "$PID_FILE"
    local ready=false
    for _ in $(seq 1 10); do
        is_pid_alive "$pid" || { FAIL "Process died"; tail -20 "$LOG_FILE" 2>/dev/null; return 1; }
        curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1 && { ready=true; break; }
        sleep 0.5
    done
    [[ "$ready" == true ]] && PASS "Started PID $pid" || { FAIL "Health check timeout"; return 1; }
}

verify_endpoint() {
    local name="$1" path="$2" expect="${3:-200}"
    local port; port=$(get_port)
    local code; code=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${port}${path}" 2>/dev/null || echo "000")
    if [[ "$code" == "$expect" ]]; then PASS "$name: HTTP $code"; return 0
    elif [[ "$code" == "401" || "$code" == "403" ]]; then PASS "$name: requires auth (HTTP $code)"; return 0
    else FAIL "$name: HTTP $code (expected $expect)"; return 1; fi
}

verify_docker() {
    local port; port=$(get_port)
    INFO "Checking Docker capability..."
    local resp; resp=$(curl -sf "http://127.0.0.1:${port}/status" 2>/dev/null || echo "")
    if echo "$resp" | grep -q '"docker"' ; then
        if echo "$resp" | grep -q 'true'; then PASS "Docker: true"; return 0
        elif [[ "$IS_LINUX" == true ]]; then FAIL "Docker: false on Linux"; return 1
        else WARN "Docker: false (expected on macOS)"; return 0; fi
    fi
    WARN "Docker: unknown"; return 1
}

run_all_checks() {
    HEADER "Verification"
    local f=0
    verify_endpoint "/status" "/status" "200" || ((f++))
    verify_endpoint "/metrics" "/metrics/latest" "200" || ((f++))
    verify_docker || ((f++))
    (( f > 0 )) && RED "$f failed" || GREEN "All passed"
}

cmd_dev() {
    HEADER "Dev Mode"
    check_go >/dev/null
    ensure_config
    echo ""; INFO "1/4 Build"; cmd_build
    echo ""; INFO "2/4 Stop"; cmd_stop 2>/dev/null || true
    echo ""; INFO "3/4 Start"
    if [[ "$IS_LINUX" == true ]]; then cmd_start
    else INFO "macOS: deploy binary to Linux"; fi
    echo ""; INFO "4/4 Verify"
    [[ "$IS_LINUX" == true ]] && run_all_checks
}

cmd_doctor() {
    HEADER "Doctor"
    echo ""; BLUE "Host"; INFO "$HOST_OS $HOST_ARCH"
    echo ""; BLUE "Go"; check_go >/dev/null && PASS "Go installed" || FAIL "Go missing"
    echo ""; BLUE "Binary"; [[ -f "$AGENT_BIN" ]] && PASS "Binary exists" || FAIL "No binary"
    echo ""; BLUE "Config"; [[ -f "$CONFIG" ]] && PASS "Config exists" || FAIL "No config"
    local pids; pids=$(get_running_pids)
    echo ""; BLUE "Process"; [[ -n "$pids" ]] && PASS "Running: $pids" || WARN "Not running"
    local port; port=$(get_port)
    (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null && { exec 3>&-; echo ""; BLUE "Port"; FAIL "Port $port in use"; }
    exec 3>&- 2>/dev/null || true
}

cmd_restart() { HEADER "Restart"; cmd_stop 2>/dev/null || true; echo ""; cmd_build; echo ""; [[ "$IS_LINUX" == true ]] && cmd_start; }

cmd_status() {
    local port; port=$(get_port)
    HEADER "Status"
    local pids; pids=$(get_running_pids)
    [[ -n "$pids" ]] && PASS "PID: $pids" || WARN "Not running"
    [[ -f "$AGENT_BIN" ]] && PASS "Binary: $(du -h "$AGENT_BIN" | cut -f1)" || FAIL "No binary"
    [[ -f "$CONFIG" ]] && PASS "Config: $port" || FAIL "No config"
}

cmd_logs() {
    [[ -f "$LOG_FILE" ]] || { WARN "No log file"; return 1; }
    [[ "${1:-}" == "follow" || "${1:-}" == "-f" ]] && tail -f "$LOG_FILE" || tail -30 "$LOG_FILE"
}

cmd_enroll() {
    HEADER "Enroll"
    ensure_config
    local pids; pids=$(get_running_pids)
    [[ -z "$pids" ]] && { INFO "Starting agent..."; cmd_build; [[ "$IS_LINUX" == true ]] && cmd_start || { WARN "Run on Linux"; return 1; }; }
    INFO "Generating token..."
    "$AGENT_BIN" --enroll --config "$CONFIG" 2>&1 | tee "$ENROLL_OUTPUT"
    [[ -f "$QR_FILE" ]] && PASS "QR saved: $QR_FILE" || FAIL "No QR generated"
}

cmd_clean() {
    HEADER "Clean"
    rm -f "$AGENT_BIN" "$AGENT_DIR/qwe1-agent-linux" "$PID_FILE" "$ENROLL_OUTPUT"
    : > "$LOG_FILE" 2>/dev/null || true
    PASS "Cleaned"
}

cmd_help() {
    echo ""
    BLUE "=========================================="
    BLUE "  qwe1.sh v$VERSION"
    BLUE "=========================================="
    echo ""
    echo "  dev       Build, restart, verify"
    echo "    doctor    Full diagnostics"
    echo "    repair    Auto-fix issues"
    echo "    start     Start agent"
    echo "    stop      Stop agent"
    echo "    restart   Stop, build, start"
    echo "    status    Show status"
    echo "    logs      Show logs"
    echo "    enroll    Generate QR token"
    echo "    clean     Remove temp files"
    echo "    help      Show this help"
    echo ""
}

main() {
    local cmd="${1:-help}"; shift || true
    case "$cmd" in
        dev|d) cmd_dev ;;
        doctor|diag) cmd_doctor ;;
        repair|fix) cmd_restart ;;
        build|b) cmd_build ;;
        start) cmd_start ;;
        stop) cmd_stop ;;
        restart) cmd_restart ;;
        status|s) cmd_status ;;
        logs|log|l) cmd_logs "${1:-}" ;;
        enroll|e) cmd_enroll ;;
        clean|c) cmd_clean ;;
        help|h|--help|-h) cmd_help ;;
        *) RED "Unknown: $cmd"; cmd_help; exit 1 ;;
    esac
}

main "$@"
