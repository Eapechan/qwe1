#!/usr/bin/env bash
set -euo pipefail

# qwe1 agent production setup — run ON the Linux server as a user with sudo.
#
# Installs the agent as a systemd service with TLS certs:
#   /usr/local/bin/qwe1-agent
#   /etc/qwe1/config.yaml
#   /etc/qwe1/certs/{cert.pem,key.pem}
#   /etc/systemd/system/qwe1-agent.service
#
# Usage:
#   ./scripts/setup-production.sh                      # interactive (asks for server name + port)
#   ./scripts/setup-production.sh --server my-server --port 9443
#   ./scripts/setup-production.sh --skip-certs         # use existing certs in /etc/qwe1/certs
#
# Requires: bash 4+, git, curl, go 1.22+, openssl, sudo.

CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

log()  { echo -e "${CYAN}[setup]${NC} $*"; }
good() { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}!!${NC} $*"; }
die()  { echo -e "${RED}ERROR:${NC} $*" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${REPO_DIR}/agent"
SERVER_NAME=""
PORT="9443"
SKIP_CERTS=0
CONFIG_DIR="/etc/qwe1"
CERTS_DIR="${CONFIG_DIR}/certs"
BIN_PATH="/usr/local/bin/qwe1-agent"
SERVICE_FILE="/etc/systemd/system/qwe1-agent.service"
RUN_USER="qwe1"
WORK_DIR="$(mktemp -d)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --server) SERVER_NAME="$2"; shift 2 ;;
        --port)   PORT="$2"; shift 2 ;;
        --skip-certs) SKIP_CERTS=1; shift ;;
        *) die "Unknown option: $1" ;;
    esac
done

for cmd in git curl go openssl sudo; do
    command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
done

sudo -n true 2>/dev/null || warn "sudo will prompt for your password"

if [[ -z "$SERVER_NAME" ]]; then
    read -rp "Server name [$(hostname -s)]: " SERVER_NAME
    SERVER_NAME="${SERVER_NAME:-$(hostname -s)}"
fi

# ---------------------------------------------------------------- build
log "building agent"
( cd "$AGENT_DIR" && go build -o "${WORK_DIR}/qwe1-agent" ./cmd/qwe1-agent )

# ---------------------------------------------------------------- install binary
log "installing binary to ${BIN_PATH}"
sudo install -m 0755 "${WORK_DIR}/qwe1-agent" "${BIN_PATH}"

# ---------------------------------------------------------------- dirs + user
log "creating directories and service user"
sudo mkdir -p "$CERTS_DIR"
if ! id -u "$RUN_USER" >/dev/null 2>&1; then
    sudo useradd --system --home-dir "$CONFIG_DIR" --shell /usr/sbin/nologin "$RUN_USER" \
        || warn "could not create user ${RUN_USER} (may already exist or need sudo)"
fi

# ---------------------------------------------------------------- certs
if [[ "$SKIP_CERTS" -eq 0 ]]; then
    log "generating self-signed TLS cert (valid 10 years)"
    sudo openssl req -x509 -nodes -newkey rsa:2048 -days 3650 -sha256 \
        -subj "/CN=${SERVER_NAME}" \
        -addext "subjectAltName=IP:$(hostname -I | awk '{print $1}'),DNS:${SERVER_NAME}" \
        -keyout "${CERTS_DIR}/key.pem" \
        -out "${CERTS_DIR}/cert.pem"
    sudo chmod 600 "${CERTS_DIR}/key.pem"
    sudo chmod 644 "${CERTS_DIR}/cert.pem"
    good "certs written to ${CERTS_DIR}"
else
    [[ -f "${CERTS_DIR}/cert.pem" && -f "${CERTS_DIR}/key.pem" ]] \
        || die "--skip-certs given but ${CERTS_DIR}/cert.pem or key.pem missing"
    warn "using existing certs in ${CERTS_DIR}"
fi

# ---------------------------------------------------------------- config
log "writing config to ${CONFIG_DIR}/config.yaml"
sudo tee "${CONFIG_DIR}/config.yaml" > /dev/null <<EOF
serverName: ${SERVER_NAME}
listenHost: 0.0.0.0
listenPort: ${PORT}
tlsCertPath: ${CERTS_DIR}/cert.pem
tlsKeyPath: ${CERTS_DIR}/key.pem
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
  enabled: true
  bufferSize: 1000
EOF

sudo chown -R "$RUN_USER:$RUN_USER" "$CONFIG_DIR" || true

# Allow service user to reach the Docker socket if the group exists.
if getent group docker >/dev/null 2>&1; then
    sudo usermod -aG docker "$RUN_USER" || warn "could not add ${RUN_USER} to docker group"
fi

# ---------------------------------------------------------------- systemd
log "installing systemd service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=qwe1 agent
After=network.target docker.service
Wants=docker.service

[Service]
User=${RUN_USER}
Group=${RUN_USER}
ExecStart=${BIN_PATH} --config ${CONFIG_DIR}/config.yaml
Restart=on-failure
RestartSec=5
Environment=HOME=${CONFIG_DIR}
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${CONFIG_DIR}

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable qwe1-agent
sudo systemctl restart qwe1-agent

# ---------------------------------------------------------------- enroll token
sleep 1
log "generating enrollment token (via sudo, store lives in ${CONFIG_DIR})"
ENROLL_OUT="$(sudo -u "$RUN_USER" -- sh -c "cd ${CONFIG_DIR} && ${BIN_PATH} --enroll --config ${CONFIG_DIR}/config.yaml" 2>/dev/null | grep -oE "Enrollment Token: [A-Za-z0-9_-]+" | awk '{print $3}')"

# ---------------------------------------------------------------- firewall
log "opening port ${PORT}/tcp in firewalld/ufw if present"
if command -v firewall-cmd >/dev/null 2>&1; then
    sudo firewall-cmd --permanent --add-port="${PORT}/tcp" >/dev/null 2>&1 || true
    sudo firewall-cmd --reload >/dev/null 2>&1 || true
elif command -v ufw >/dev/null 2>&1; then
    sudo ufw allow "${PORT}/tcp" >/dev/null 2>&1 || true
fi

# ---------------------------------------------------------------- summary
FP="$(sudo openssl x509 -in "${CERTS_DIR}/cert.pem" -noout -fingerprint -sha256 | sed 's/.*=//')"
IP="$(hostname -I | awk '{print $1}')"

echo ""
echo "===================================================="
echo "  qwe1 agent — production install complete"
echo "===================================================="
echo "  Server URL:  https://${IP}:${PORT}"
echo "  Server name: ${SERVER_NAME}"
echo "  Fingerprint: ${FP}"
if [[ -n "$ENROLL_OUT" ]]; then
    echo "  Enrollment token: ${ENROLL_OUT}"
else
    echo "  Enrollment token: run: sudo -u qwe1 sh -c 'cd /etc/qwe1 && /usr/local/bin/qwe1-agent --enroll'"
fi
echo "  Status:      systemctl status qwe1-agent"
echo "  Logs:        journalctl -u qwe1-agent -f"
echo "===================================================="
echo ""
warn "Enter the enrollment token + server URL in the qwe1 app and pin the fingerprint."

rm -rf "$WORK_DIR"
