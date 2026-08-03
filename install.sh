#!/bin/sh
set -e

echo "qwe1 Agent Installer v1.0.0"
echo "============================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_URL="${QWE1_URL:-https://github.com/Eapechan/qwe1/releases/download/v1.0.0/qwe1-agent-linux-amd64}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
CONFIG_DIR="${CONFIG_DIR:-/etc/qwe1}"

echo "Installing qwe1 agent..."
echo "  Binary:  ${INSTALL_DIR}/qwe1-agent"
echo "  Config:  ${CONFIG_DIR}/config.yaml"
echo ""

if [ ! -f "${SCRIPT_DIR}/qwe1-agent" ]; then
    echo "Downloading binary from ${BINARY_URL}..."
    curl -fL -o "${SCRIPT_DIR}/qwe1-agent" "${BINARY_URL}"
fi

chmod +x "${SCRIPT_DIR}/qwe1-agent"
cp "${SCRIPT_DIR}/qwe1-agent" "${INSTALL_DIR}/qwe1-agent"

mkdir -p "${CONFIG_DIR}"

if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
    cat > "${CONFIG_DIR}/config.yaml" <<EOF
server:
  host: 0.0.0.0
  port: 9443
  tls:
    cert: /etc/qwe1/cert.pem
    key: /etc/qwe1/key.pem
auth:
  enrollSecret: ""
  tokenTTL: 15m
  refreshTTL: 7d
docker:
  socket: /var/run/docker.sock
files:
  roots:
    - /tmp
alerts:
  enabled: true
EOF
    echo "Created default config at ${CONFIG_DIR}/config.yaml"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ${CONFIG_DIR}/config.yaml"
echo "  2. Generate TLS certs or place existing ones at ${CONFIG_DIR}/"
echo "  3. Run: qwe1-agent --config ${CONFIG_DIR}/config.yaml"
echo "  4. Or use Docker: docker run -d --name qwe1-agent -v /var/run/docker.sock:/var/run/docker.sock -p 9443:9443 qwe1/agent"