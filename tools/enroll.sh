#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT_BIN="$REPO_ROOT/agent/qwe1-agent"
CONFIG="$REPO_ROOT/config.yaml"
QR_FILE="$REPO_ROOT/enroll-qr.png"

RED()    { printf '\033[1;31m%s\033[0m\n' "$*"; }
GREEN()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
YELLOW() { printf '\033[1;33m%s\033[0m\n' "$*"; }
INFO()   { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

is_linux=true
if [[ "$(uname -s)" == "Darwin" ]]; then
    is_linux=false
fi

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
    fi
}

build_agent() {
    INFO "Building agent..."
    cd agent
    CGO_ENABLED=0 go build -trimpath -o qwe1-agent ./cmd/qwe1-agent
    cd ..
    GREEN "✓ PASS: Agent built"
}

start_agent_if_needed() {
    if [ -f "$REPO_ROOT/agent.pid" ] && kill -0 "$(cat "$REPO_ROOT/agent.pid")" 2>/dev/null; then
        INFO "Agent already running"
        return 0
    fi

    if [ ! -f "$AGENT_BIN" ]; then
        INFO "Agent binary not found — building first"
        build_agent
    fi

    ensure_config

    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    INFO "Starting agent..."
    nohup "$AGENT_BIN" --config "$CONFIG" >> "$REPO_ROOT/agent.log" 2>&1 &
    echo $! > "$REPO_ROOT/agent.pid"
    sleep 1

    if kill -0 "$!" 2>/dev/null; then
        GREEN "✓ PASS: Agent started"
    else
        RED "✗ FAIL: Agent failed to start"
        tail -10 "$REPO_ROOT/agent.log"
        exit 1
    fi
}

generate_token() {
    INFO "Generating enrollment token..."
    "$AGENT_BIN" --enroll --config "$CONFIG" 2>&1 | tee /tmp/enroll_output.txt

    if [ ! -f "$QR_FILE" ]; then
        RED "✗ FAIL: QR code was not generated"
        exit 1
    fi

    GREEN "✓ PASS: QR code saved to $QR_FILE"
}

print_urls() {
    local lan_url=""
    local ts_url=""
    local token=""
    local expiry=""

    lan_url=$(grep -E '^\s*LAN URL' /tmp/enroll_output.txt 2>/dev/null | sed 's/.*LAN URL[:]* //' | xargs || true)
    ts_url=$(grep -E '^\s*Tailscale URL' /tmp/enroll_output.txt 2>/dev/null | sed 's/.*Tailscale URL[:]* //' | xargs || true)
    token=$(grep -E '^\s*Enrollment Token' /tmp/enroll_output.txt 2>/dev/null | sed 's/.*Enrollment Token[:]* //' | xargs || true)
    expiry=$(grep -E '^\s*Expires' /tmp/enroll_output.txt 2>/dev/null | sed 's/.*Expires[:]* //' | xargs || true)

    echo ""
    GREEN "═══════════════════════════════════════════════"
    GREEN "  qwe1 Enrollment — QR Code Generated"
    GREEN "═══════════════════════════════════════════════"
    echo ""

    if [ -n "$lan_url" ]; then
        INFO "LAN URL:      $lan_url"
    else
        YELLOW "⚠ LAN URL:     could not be detected (set advertiseUrl in config.yaml)"
    fi

    if [ -n "$ts_url" ]; then
        INFO "Tailscale URL: $ts_url"
    else
        YELLOW "⚠ Tailscale URL: not configured (set advertiseTailscaleUrl in config.yaml)"
    fi

    if [ -n "$token" ]; then
        INFO "Token:        $token"
    fi

    if [ -n "$expiry" ]; then
        INFO "Expires:      $expiry"
    fi

    echo ""
    INFO "QR code saved to: $QR_FILE"
    INFO "Scan the QR code with the qwe1 app to pair."
    echo ""
}

verify_agent() {
    local port
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443

    INFO "Verifying agent is running..."
    if curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1; then
        GREEN "✓ PASS: Agent is running and responding"
    else
        YELLOW "⚠ WARNING: Agent is not responding on port $port"
        YELLOW "The enrollment token was still generated — start the agent with:"
        YELLOW "  tools/development.sh start"
    fi
}

main() {
    ensure_config
    start_agent_if_needed
    generate_token
    print_urls
    verify_agent
}

main "$@"
