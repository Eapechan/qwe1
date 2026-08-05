# Getting Started with qwe1

## What We Built

**qwe1** is a self-hosted server management app — like NZB360 for your home server. It consists of two components:

```
Flutter App (phone) <-- HTTP/WebSocket --> Go Agent (your server) --> Docker API
```

- **Flutter app** (`app/`) — Android app for monitoring and controlling servers
- **Go agent** (`agent/`) — Lightweight binary that runs on your server, exposes a REST API + WebSocket

There is **no cloud**. Your phone talks directly to your server.

### Current Status

| Component | Status |
|-----------|--------|
| Go agent builds | Working |
| Flutter APK builds | Working |
| Host metrics (CPU/RAM/Disk) | Working |
| Docker management | Working (agent retries if daemon starts late) |
| File browser (list/read/write/upload) | Working |
| Alerts engine | Working |
| Authentication (enroll/refresh/revoke) | Working |
| Terminal (PTY sessions) | Backend working, UI stubbed |
| Real-time metrics streaming | Backend working, UI partial |

---

## Prerequisites

### On Your Mac

```bash
# Flutter (at ~/flutter/)
~/flutter/bin/flutter --version

# Android SDK (at ~/android-sdk/)
# Android SDK platform-tools, platforms;android-34, build-tools;34.0.0

# JDK 17 (at ~/java/current/)
export JAVA_HOME=~/java/current

# Go
go version
```

### On Your Server

- Linux (Debian/Ubuntu, Fedora, Alpine, etc.)
- Docker installed and running
- SSH access
- Port 9443 open (or any port you configure)

---

## Part 1: Run the Go Agent on Your Server

### Step 1: Clone and run

```bash
git clone https://github.com/qwe1/qwe1.git
cd qwe1
./run.sh
```

**Prerequisites:** Go >= 1.25 on your server ([install Go](https://go.dev/dl/)).

`run.sh` will:
1. Pull the latest code from origin/main
2. Check your Go version
3. Build the agent binary
4. Generate a 1-hour reusable enrollment token + QR code (ASCII + `enroll-qr.png`)
5. Start the agent in the background

You'll see output like:
```
==> Agent started (PID 12345)
==> Health check OK

═══════════════════════════════════════════════
  qwe1 Agent — Ready
═══════════════════════════════════════════════
  Agent PID : 12345
  URL       : http://0.0.0.0:9443
  Log       : agent.log
  QR code   : enroll-qr.png
```

### Step 2: Verify it works

From your Mac (in a new terminal):

```bash
curl http://YOUR_SERVER_IP:9443/status
```

Expected response:
```json
{"name":"your-server","agentVersion":"1.0.0","apiVersion":1,"caps":{"docker":true,"dockerSocket":"unix:///var/run/docker.sock","terminal":true,"files":true,"tempSensors":true}}
```

`caps.dockerSocket` is a diagnostic: it holds the socket the agent is watching.
If the Docker daemon is slow to start, the agent retries in the background and
flips `caps.docker` to `true` automatically as soon as the daemon becomes
reachable — no agent restart needed.

### Step 2: Verify it works

From your Mac (in a new terminal):

```bash
curl http://YOUR_SERVER_IP:9443/status
```

### Step 3: Generate enrollment token

### Local development

Run the agent in the foreground:

```bash
./run.sh --foreground
```

Or regenerate the token + QR separately:

```bash
./run.sh token
```

Copy the printed token into the app (Server URL `http://YOUR_SERVER_IP:9443`), or scan the QR code from the app's "Add Server" screen.

### Tailscale (remote access)

When you're away from home, the app connects via Tailscale VPN. The QR code carries **both** your LAN URL and your Tailscale URL, so one scan works everywhere.

1. Install Tailscale on both phone and server.
2. Find your server's Tailscale IP: `tailscale ip -4` on the server.
3. Set `advertiseTailscaleUrl` in `config.yaml`:
   ```yaml
   advertiseTailscaleUrl: "http://100.x.y.z:9443"
   ```
4. Re-run `./run.sh` — the new QR includes both addresses.
5. Scan with the app. At home it uses the LAN URL; away from home it automatically falls back to the Tailscale URL.

### Production install (TLS + systemd)

For a real deployment, do these manual steps on your server. They cross-build the
agent, generate self-signed TLS certs, install the binary to `/usr/local/bin`,
write a hardened config to `/etc/qwe1/config.yaml`, and register a systemd service
that auto-starts on boot.

1. **Generate certs** — either your CA's certs or self-signed:
   ```bash
   sudo mkdir -p /etc/qwe1/certs
   sudo openssl req -x509 -nodes -newkey rsa:2048 -days 3650 -sha256 \
      -subj "/CN=your-server" \
      -addext "subjectAltName=DNS:your-server,IP:YOUR_SERVER_IP" \
     -keyout /etc/qwe1/certs/key.pem -out /etc/qwe1/certs/cert.pem
   sudo chmod 600 /etc/qwe1/certs/key.pem
   ```
2. **Point the config at the certs** — set `tlsCertPath` and `tlsKeyPath` in `/etc/qwe1/config.yaml` (see `config.example.yaml`).
3. **Run as a service** (example): `/usr/local/bin/qwe1-agent --config /etc/qwe1/config.yaml`.
4. **Open the port**: `sudo ufw allow 9443/tcp` or `sudo firewall-cmd --permanent --add-port=9443/tcp && sudo firewall-cmd --reload`.

---

## Part 2: Build the Flutter APK

### Step 1: Set up environment

```bash
export JAVA_HOME=~/java/current
export PATH="$PATH:$HOME/flutter/bin:$HOME/android-sdk/platform-tools"
```

### Step 2: Build

```bash
cd ~/qwe1/app
flutter pub get
flutter build apk --debug
```

Build time: ~30-60 seconds.

### Step 3: Locate the APK

```
~/qwe1/app/build/app/outputs/flutter-apk/app-debug.apk
```

Size: ~156 MB (debug build, includes all architectures).

---

## Part 3: Install on Your Phone

### Option A: USB Transfer

1. Connect phone via USB
2. Copy APK to phone storage:
   ```bash
   adb push ~/qwe1/app/build/app/outputs/flutter-apk/app-debug.apk /sdcard/Download/
   ```
3. Open file manager on phone, tap the APK, install

### Option B: Local HTTP Server (no USB)

From your Mac:

```bash
cd ~/qwe1/app/build/app/outputs/flutter-apk/
python3 -m http.server 8080
```

On your phone's browser, open:
```
http://YOUR_MAC_IP:8080/app-debug.apk
```

Download and install.

### Option C: AirDrop / File Share

Just send the APK file to your phone however you normally share files.

### Enable Install from Unknown Sources

On Android:
- **Android 8+**: Settings > Apps > Special access > Install unknown apps > [your browser/file manager] > Allow
- **Android 7 and below**: Settings > Security > Unknown sources > Enable

---

## Part 4: Connect App to Agent

### Step 1: Verify agent is reachable

```bash
curl http://YOUR_SERVER_IP:9443/status
```

If this fails, check:
- Agent is running on the server
- Port 9443 is open (firewall rules)
- You're on the same network (or using Tailscale/VPN)

### Step 2: Open the app

Launch qwe1 on your phone. You'll see the onboarding screens — tap through or skip.

### Step 3: Add your server

1. Tap the **+** button on the dashboard
2. Fill in:
   - **Server Name**: anything (e.g., "My Server")
   - **Agent URL**: `http://YOUR_SERVER_IP:9443`
   - **Enrollment Token**: the token from `qwe1-agent --enroll` (e.g., `qwe1-<token>`)
   - **Group** (optional): e.g., "home"
3. Tap **Add Server**

The app will:
1. Call `POST /auth/enroll` with your token
2. Receive access + refresh tokens
3. Save them securely on your phone
4. Fetch server status and capabilities

### Step 4: You're in

The dashboard should show your server with live status. Tap it to see:
- CPU, RAM, Disk usage
- Docker containers
- File browser
- Alerts

---

## Part 5: What Works Now

### Working End-to-End

| Feature | How to Test |
|---------|-------------|
| Server status | Dashboard shows server name and status indicator |
| Host metrics | Server detail screen shows CPU/RAM/Disk chips |
| Docker containers | Tap "Containers" — lists all containers with status |
| Docker actions | Start/stop/restart buttons on container cards |
| Container detail | Tap a container for details, kill/remove actions |
| File browser | Tap "Files" — browse allowed roots, create folders, rename, delete |
| File upload | Upload button in file browser |
| File write | Edit/create text files from the app |
| Alerts list | Tap "Alerts" — shows threshold alerts |
| Alert acknowledge | Swipe/tap to acknowledge alerts |
| Multi-server | Add multiple servers via the + button |

### Partially Working

| Feature | Status |
|---------|--------|
| Terminal | Backend PTY works, Flutter UI has display but input not wired |
| Real-time metrics | Backend WebSocket broadcasts; app uses WS and falls back to 5s HTTP polling of `/metrics/latest` if the socket is unavailable |
| File download | Backend supports it, UI download button not implemented |
| File preview | Backend supports it, UI preview not implemented |
| Certificate pinning | Fingerprint stored but not validated yet |

### Not Yet Working

- Container logs viewer (backend streams, no UI screen)
- Alert threshold editing (backend API exists, no UI)
- Offline queue (database table exists, no logic)
- Biometric lock (toggle exists, no enforcement)

---

## Troubleshooting

### "command not found: flutter"

```bash
export PATH="$PATH:$HOME/flutter/bin"
```

### "Unable to locate a Java Runtime"

```bash
export JAVA_HOME=~/java/current
```

### "Connection refused" when curling the agent

- Make sure the agent is running: `ps aux | grep qwe1`
- Check the port: `ss -tlnp | grep 9443`
- Check firewall: `sudo ufw allow 9443` (Ubuntu) or equivalent

### Enrollment fails in the app

- **"Invalid token format"**: the token must start with `qwe1-`. The `--enroll` command now generates tokens in this format (e.g. `qwe1-...`). Make sure you paste the full token including the `qwe1-` prefix.
- Verify the enrollment token hash matches what's in `your-server.auth.json`
- Check the token hasn't expired
- Check the token hasn't been used already (set `"used": false`)

### APK won't install

- Enable "Install from Unknown Sources" (see Part 3)
- Make sure you have enough storage
- Try uninstalling any previous version first

### "certificate verify failed" in the app

This happens when the agent runs with TLS and the app doesn't trust the self-signed cert. For testing, use plain HTTP (empty `tlsCertPath`/`tlsKeyPath` in config).

### "unexpected error occurred: null" in the app

This means the QR URL uses `https://` but the agent is running plain HTTP (no
TLS certs configured). Delete the server in the app, then on the server run:

```bash
./run.sh token
```

The new QR will advertise `http://…` (matching your plain-HTTP config). Scan
it again. If you need HTTPS, set up TLS certs first — see the production steps
above.

### "Docker is not available" in the app

The app shows this when the agent reports it can't reach the Docker socket.
This is expected if the agent started before the Docker daemon. The agent
retries automatically every 5 seconds (up to 6 times) and flips the capability
to `true` as soon as the daemon responds — refresh the server status in the app.

Check on the server:
- Is Docker running? `sudo systemctl status docker`
- Does the agent's user have access to the socket? `ls -l /var/run/docker.sock` (group `docker`)
- What does the agent log say? `tail -50 agent.log | grep -i docker`

### "Agent failed to start"

`run.sh` auto-detects and kills stray agents that hold the port. If it still
fails, check the log:

```bash
tail -20 agent.log
```

Common causes:
- **"address already in use"** — run `pkill -f qwe1-agent` then `./run.sh` again.
- **"no such file or directory"** — Go not installed or binary not built. Run
  `./run.sh --force`.

---

## Next Steps

To make this fully functional, implement in this order:

1. **Terminal input wiring** — Connect Flutter terminal UI to WebSocket PTY streams
2. **Metrics streaming** — Wire `serverMetricsProvider` to WebSocket for live charts
3. **Container logs screen** — New screen showing streaming logs
4. **File download/preview** — Add download action and text/image preview
5. **TLS certificate generation** — Auto-generate self-signed certs on first run
6. **Biometric lock** — Enforce fingerprint/PIN on app launch

---

## Quick Reference

```bash
# Full flow: pull → build → token+QR → start agent
./run.sh

# Force rebuild
./run.sh --force

# Skip git pull
./run.sh --no-pull

# Run in foreground (stream logs)
./run.sh --foreground

# Stop the agent
./run.sh stop

# Regenerate token + QR
./run.sh token

# Check agent status
./run.sh status

# Flutter APK
export JAVA_HOME=~/java/current
cd ~/qwe1/app && flutter build apk --debug

# Flutter analyze
cd ~/qwe1/app && flutter analyze

# Go tests
cd ~/qwe1/agent && go test ./...

# Code generation (after model changes)
cd ~/qwe1/app && dart run build_runner build
```
