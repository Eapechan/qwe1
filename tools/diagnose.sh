#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT_BIN="$REPO_ROOT/agent/qwe1-agent"
CONFIG="$REPO_ROOT/config.yaml"
PID_FILE="$REPO_ROOT/agent.pid"
LOG_FILE="$REPO_ROOT/agent.log"

PASS()  { printf '\033[1;32m✓ PASS\033[0m %s\n' "$*"; }
WARN()  { printf '\033[1;33m⚠ WARNING\033[0m %s\n' "$*"; }
FAIL()  { printf '\033[1;31m✗ FAIL\033[0m %s\n' "$*"; }
INFO()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

is_linux=true
if [[ "$(uname -s)" == "Darwin" ]]; then
    is_linux=false
fi

port=9443
if [ -f "$CONFIG" ]; then
    port=$(grep -E '^\s*listenPort:' "$CONFIG" 2>/dev/null | head -1 | sed 's/[^0-9]//g')
    [ -z "$port" ] && port=9443
fi

echo ""
INFO "qwe1 Diagnostic Report"
INFO "Running on $(uname -s) $(uname -m)"
echo ""

# 1. Go installation
INFO "Checking Go installation..."
if command -v go >/dev/null 2>&1; then
    local_ver=$(go version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    PASS "Go installed: $local_ver"
else
    FAIL "Go is not installed" "Install Go >= 1.25: https://go.dev/dl/"
fi

# 2. Agent binary
INFO "Checking agent binary..."
if [ -f "$AGENT_BIN" ]; then
    size=$(du -h "$AGENT_BIN" | cut -f1)
    PASS "Agent binary found: $AGENT_BIN ($size)"
else
    FAIL "Agent binary not found at $AGENT_BIN" "Run: tools/development.sh or build manually"
fi

# 3. Config
INFO "Checking config..."
if [ -f "$CONFIG" ]; then
    PASS "Config found: $CONFIG"
else
    FAIL "Config not found at $CONFIG" "Run: tools/development.sh to create a default config"
fi

# 4. Port
INFO "Checking port $port..."
if command -v ss >/dev/null 2>&1; then
    if ss -tln 2>/dev/null | grep -q ":${port} "; then
        PASS "Port $port is in use (agent is listening)"
    else
        WARN "Port $port is not in use (agent may not be running)"
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tln 2>/dev/null | grep -q ":${port} "; then
        PASS "Port $port is in use (agent is listening)"
    else
        WARN "Port $port is not in use (agent may not be running)"
    fi
else
    WARN "Cannot check port (ss and netstat not available)"
fi

# 5. Status endpoint
INFO "Checking /status endpoint..."
if curl -sf "http://127.0.0.1:${port}/status" >/dev/null 2>&1; then
    PASS "/status endpoint is responding"
else
    FAIL "/status endpoint is not responding" "Ensure the agent is running: tools/development.sh start"
fi

# 6. Metrics endpoint
INFO "Checking /metrics/latest endpoint..."
if curl -sf "http://127.0.0.1:${port}/metrics/latest" >/dev/null 2>&1; then
    PASS "/metrics/latest endpoint is responding"
else
    FAIL "/metrics/latest endpoint is not responding" "Check agent logs: tail -f agent.log"
fi

# 7. WebSocket
INFO "Checking WebSocket /ws endpoint..."
if timeout 2 bash -c '</dev/tcp/127.0.0.1/9443' 2>/dev/null; then
    PASS "WebSocket port is open"
else
    WARN "WebSocket port check inconclusive" "Agent may still be working; check logs"
fi

# 8. Docker (Linux only)
if [ "$is_linux" = true ]; then
    INFO "Checking Docker availability..."
    if [ -S /var/run/docker.sock ]; then
        PASS "Docker socket found at /var/run/docker.sock"
    else
        FAIL "Docker socket not found at /var/run/docker.sock" "Start Docker: sudo systemctl start docker"
    fi

    if command -v docker >/dev/null 2>&1; then
        PASS "Docker CLI is installed"
    else
        FAIL "Docker CLI not found" "Install Docker: https://docs.docker.com/get-docker/"
    fi

    if docker version >/dev/null 2>&1; then
        PASS "Docker daemon is responding"
    else
        FAIL "Docker daemon is not responding" "Check Docker service: sudo systemctl status docker"
    fi
else
    INFO "Docker check — skipped on macOS"
fi

# 9. Tailscale
INFO "Checking Tailscale..."
if command -v tailscale >/dev/null 2>&1; then
    PASS "Tailscale CLI is installed"
    ts_ip=$(tailscale ip -4 2>/dev/null | head -1 || true)
    if [ -n "$ts_ip" ]; then
        PASS "Tailscale IP: $ts_ip"
    else
        WARN "Tailscale is installed but no IP assigned" "Check Tailscale connection: tailscale status"
    fi
else
    WARN "Tailscale CLI not found" "Install Tailscale for remote access: https://tailscale.com/"
fi

# 10. LAN IP
INFO "Checking LAN IP..."
lan_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
if [ -n "$lan_ip" ]; then
    PASS "LAN IP: $lan_ip"
else
    WARN "Could not detect LAN IP" "Check your network configuration"
fi

# 11. Disk usage
INFO "Checking disk usage..."
disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%' || echo "unknown")
if [ "$disk_usage" != "unknown" ]; then
    if [ "$disk_usage" -gt 90 ]; then
        FAIL "Disk usage is ${disk_usage}% (critical)" "Free up disk space"
    elif [ "$disk_usage" -gt 80 ]; then
        WARN "Disk usage is ${disk_usage}% (warning)" "Consider freeing up disk space"
    else
        PASS "Disk usage is ${disk_usage}%"
    fi
else
    WARN "Could not check disk usage"
fi

# 12. Memory
INFO "Checking memory..."
if command -v free >/dev/null 2>&1; then
    mem_total=$(free -m 2>/dev/null | awk 'NR==2 {print $2}' || echo "unknown")
    mem_used=$(free -m 2>/dev/null | awk 'NR==2 {print $3}' || echo "unknown")
    if [ "$mem_total" != "unknown" ]; then
        PASS "Memory: ${mem_used}MB / ${mem_total}MB used"
    else
        WARN "Could not parse memory info"
    fi
else
    WARN "free command not available (macOS?)" "Memory check skipped"
fi

# 13. Firewall
INFO "Checking firewall..."
if command -v ufw >/dev/null 2>&1; then
    if ufw status 2>/dev/null | grep -q "active"; then
        if ufw status 2>/dev/null | grep -q "9443"; then
            PASS "Firewall (ufw) is active and port 9443 is open"
        else
            WARN "Firewall (ufw) is active but port 9443 may be blocked" "Run: sudo ufw allow 9443/tcp"
        fi
    else
        PASS "Firewall (ufw) is inactive"
    fi
elif command -v firewall-cmd >/dev/null 2>&1; then
    if firewall-cmd --state 2>/dev/null | grep -q "running"; then
        PASS "Firewall (firewalld) is running"
        if firewall-cmd --list-ports 2>/dev/null | grep -q "9443"; then
            PASS "Port 9443 is open in firewall"
        else
            WARN "Port 9443 may be blocked in firewall" "Run: sudo firewall-cmd --permanent --add-port=9443/tcp && sudo firewall-cmd --reload"
        fi
    else
        PASS "Firewall (firewalld) is not running"
    fi
else
    WARN "No firewall CLI detected" "Check your OS firewall settings manually"
fi

# 14. Running processes
INFO "Checking running processes..."
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    PASS "qwe1-agent is running (PID $(cat "$PID_FILE"))"
else
    WARN "qwe1-agent is not running (no valid PID file)" "Start with: tools/development.sh start"
fi

# 15. Enrollment system
INFO "Checking enrollment system..."
if [ -f "$REPO_ROOT/enroll-qr.png" ]; then
    PASS "QR code exists at $REPO_ROOT/enroll-qr.png"
else
    WARN "QR code not found" "Run: tools/enroll.sh to generate one"
fi

# 16. QR generation capability
INFO "Checking QR generation capability..."
if command -v qrencode >/dev/null 2>&1; then
    PASS "qrencode is available"
else
    WARN "qrencode not installed" "Install: sudo apt-get install qrencode (Debian/Ubuntu)"
fi

echo ""
INFO "Diagnostic complete"
echo ""
