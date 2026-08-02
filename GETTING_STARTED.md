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
| Docker management | Working |
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

### Step 1: Cross-compile for Linux

From your Mac:

```bash
cd /Users/binu/qwe1/agent
GOOS=linux GOARCH=amd64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent
```

For ARM servers (Raspberry Pi, etc.):
```bash
GOOS=linux GOARCH=arm64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent
```

### Step 2: Transfer to your server

```bash
scp bin/qwe1-agent-linux user@YOUR_SERVER_IP:~/qwe1-agent
```

Replace `user@YOUR_SERVER_IP` with your actual SSH credentials.

### Step 3: Create config on the server

SSH into your server and create the config:

```bash
ssh user@YOUR_SERVER_IP

cat > ~/config.yaml << 'EOF'
serverName: my-server
listenHost: "0.0.0.0"
listenPort: 9443
tlsCertPath: ""
tlsKeyPath: ""
auth:
  accessTokenTTL: 900
  refreshTokenTTL: 2592000
docker:
  socketPath: /var/run/docker.sock
  enabled: true
host:
  metricsInterval: 5
terminal:
  maxSessions: 4
  idleTimeout: 300
files:
  allowedRoots: ["/home", "/var/log", "/tmp", "/etc"]
  maxUpload: 524288000
alerts:
  enabled: true
  bufferSize: 1000
EOF
```

Setting `tlsCertPath` and `tlsKeyPath` to empty strings runs plain HTTP (easier for testing).

### Step 4: Make executable and run

```bash
chmod +x ~/qwe1-agent
./qwe1-agent --config ~/config.yaml
```

You should see:
```
server listening addr=0.0.0.0:9443
```

Leave this running. Open a new terminal for the next steps.

### Step 5: Verify it works

From your Mac (in a new terminal):

```bash
curl http://YOUR_SERVER_IP:9443/status
```

Expected response:
```json
{"name":"my-server","agentVersion":"1.0.0","apiVersion":1,"caps":{"docker":true,"terminal":true,"files":true,"tempSensors":true}}
```

### Step 6: Generate enrollment token

Run the enrollment command on your server:

```bash
./qwe1-agent --enroll --config ~/config.yaml
```

Output:
```
=========================================
  qwe1 Agent Enrollment Token
=========================================
  Server:          my-server
  Enrollment Token: S78g4yz7F014MGLJCohsq2nY14KrhreDdp1Kv4YuOcU
  Expires:         2027-08-01 (365 days)
=========================================

Enter this token in the qwe1 app to pair
with this server.
```

Copy the **Enrollment Token** — you'll paste it into the app.

> **Note**: The token is a one-time-use code. Once a device enrolls with it, the token is marked as used. Generate a new one for each device.

---

## Part 2: Build the Flutter APK

### Step 1: Set up environment

```bash
export JAVA_HOME=~/java/current
export PATH="$PATH:$HOME/flutter/bin:$HOME/android-sdk/platform-tools"
```

### Step 2: Build

```bash
cd /Users/binu/qwe1/app
flutter pub get
flutter build apk --debug
```

Build time: ~30-60 seconds.

### Step 3: Locate the APK

```
/Users/binu/qwe1/app/build/app/outputs/flutter-apk/app-debug.apk
```

Size: ~156 MB (debug build, includes all architectures).

---

## Part 3: Install on Your Phone

### Option A: USB Transfer

1. Connect phone via USB
2. Copy APK to phone storage:
   ```bash
   adb push /Users/binu/qwe1/app/build/app/outputs/flutter-apk/app-debug.apk /sdcard/Download/
   ```
3. Open file manager on phone, tap the APK, install

### Option B: Local HTTP Server (no USB)

From your Mac:

```bash
cd /Users/binu/qwe1/app/build/app/outputs/flutter-apk/
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
   - **Enrollment Token**: the token from `qwe1-agent --enroll` (e.g., `S78g4yz7F014MGLJCohsq2nY14KrhreDdp1Kv4YuOcU`)
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
| Real-time metrics | Backend WebSocket broadcasts, UI shows placeholder values |
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

- Verify the enrollment token hash matches what's in `my-server.auth.json`
- Check the token hasn't expired
- Check the token hasn't been used already (set `"used": false`)

### APK won't install

- Enable "Install from Unknown Sources" (see Part 3)
- Make sure you have enough storage
- Try uninstalling any previous version first

### "certificate verify failed" in the app

This happens when the agent runs with TLS and the app doesn't trust the self-signed cert. For testing, use plain HTTP (empty `tlsCertPath`/`tlsKeyPath` in config).

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

## Quick Reference: Build Commands

```bash
# Go agent (build for current platform)
cd /Users/binu/qwe1/agent && go build -o bin/qwe1-agent ./cmd/qwe1-agent

# Go agent (cross-compile for Linux amd64)
cd /Users/binu/qwe1/agent && GOOS=linux GOARCH=amd64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent

# Go agent (cross-compile for Linux arm64)
cd /Users/binu/qwe1/agent && GOOS=linux GOARCH=arm64 go build -o bin/qwe1-agent-linux ./cmd/qwe1-agent

# Generate enrollment token
./qwe1-agent --enroll --config ~/config.yaml

# Flutter APK
export JAVA_HOME=~/java/current
cd /Users/binu/qwe1/app && flutter build apk --debug

# Flutter analyze
cd /Users/binu/qwe1/app && flutter analyze

# Go tests
cd /Users/binu/qwe1/agent && go test ./...

# Code generation (after model changes)
cd /Users/binu/qwe1/app && dart run build_runner build
```
