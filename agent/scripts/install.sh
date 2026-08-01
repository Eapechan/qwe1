#!/bin/bash
set -e

echo "=== qwe1 Agent Installer ==="

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="armv7"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected: $OS/$ARCH"

# Download URL
VERSION="1.0.0"
DOWNLOAD_URL="https://github.com/qwe1/qwe1/releases/download/v${VERSION}/qwe1-agent-${OS}-${ARCH}"

# Create installation directory
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/qwe1"
CERTS_DIR="${CONFIG_DIR}/certs"

echo "Creating directories..."
sudo mkdir -p "${CONFIG_DIR}" "${CERTS_DIR}"

# Download binary
echo "Downloading agent..."
sudo curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/qwe1-agent"
sudo chmod +x "${INSTALL_DIR}/qwe1-agent"

# Create default config
if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
    echo "Creating default config..."
    sudo tee "${CONFIG_DIR}/config.yaml" > /dev/null <<EOF
serverName: $(hostname)
listenHost: 0.0.0.0
listenPort: 9443
tlsCertPath: ${CERTS_DIR}/cert.pem
tlsKeyPath: ${CERTS_DIR}/key.pem

auth:
  tokenLength: 16
  accessTokenTTL: 900
  refreshTokenTTL: 2592000

docker:
  socketPath: /var/run/docker.sock
  enabled: true

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
fi

# Create systemd service
if command -v systemctl &> /dev/null; then
    echo "Creating systemd service..."
    sudo tee /etc/systemd/system/qwe1-agent.service > /dev/null <<EOF
[Unit]
Description=qwe1 Agent
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
User=root
ExecStart=${INSTALL_DIR}/qwe1-agent --config ${CONFIG_DIR}/config.yaml
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable qwe1-agent
    echo "Service created. Start with: sudo systemctl start qwe1-agent"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Start the agent: sudo systemctl start qwe1-agent"
echo "2. Generate enrollment token: qwe1-agent --enroll"
echo "3. Scan the QR code with the qwe1 app"
echo ""
