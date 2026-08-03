#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AGENT_BIN="./agent/qwe1-agent"
CONFIG="config.yaml"

# Build agent if missing or source changed.
if [ ! -f "$AGENT_BIN" ] || [ agent/cmd/qwe1-agent/main.go -nt "$AGENT_BIN" ]; then
  echo "[token.sh] Building agent..."
  cd agent && go build -o qwe1-agent ./cmd/qwe1-agent && cd ..
fi

echo ""
echo "=== Generating enrollment token + QR code ==="
echo ""
"$AGENT_BIN" --enroll --config "$CONFIG"

echo ""
echo "=== Done ==="
echo ""
echo "If a QR PNG was written, scan it with the qwe1 app."
echo "The token is valid for 1 hour and can be used by multiple devices."
echo ""
