# qwe1 Agent — Connection Troubleshooting Report

## Summary

While pairing the qwe1 app to the agent on the Linux server, the app showed a
**"Network exception / Could not connect to server"** error, and
`curl https://<server-ip>:9443/status` also failed to load.

The agent started successfully, but connections were
rejected. **The root cause is a scheme/address mismatch**: the development
setup (plain config with empty TLS paths) serves **plain HTTP on port 9443**, so
`https://` and the wrong URL will never connect.

---

## Root Cause

A manual dev config with empty TLS paths:

```yaml
serverName: test-server
listenHost: 0.0.0.0
listenPort: 9443
tlsCertPath: ""
tlsKeyPath: ""
```

Because `tlsCertPath`/`tlsKeyPath` are empty, the agent listens as **HTTP on port
9443** — not HTTPS. Therefore:

- `curl https://<ip>:9443/status` fails (there is no TLS listener).
- The app fails to connect if you enter `https://`, `localhost`, `127.0.0.1`, or a
  port that doesn't match the running agent.

---

## How to Verify the Agent Is Actually Working

Run these on the server (note: plain `http://`, not `https://`):

```bash
# 1. Confirm the agent responds
curl http://127.0.0.1:9443/status

# 2. Confirm the port is bound
ss -tlnp | grep 9443
```

If these return JSON / show the listener, the server is fine — the problem is how
you are connecting to it.

---

## How to Solve It (check these in order)

1. **Use the correct scheme — HTTP, not HTTPS.**
   In the app and curl, use `http://<server-ip>:9443`, never `https://`.
   (HTTPS only works after setting up TLS certs in the config — see the
   production steps in [GETTING_STARTED.md](GETTING_STARTED.md), which serve
   HTTPS on that port.)

2. **Use the correct address (don't use localhost/127.0.0.1 on the phone).**
   From the server itself, `127.0.0.1` works. From a phone, you must use the
   server's LAN IP, e.g. `http://192.168.1.5:9443`. `localhost` on a phone points
   to the phone, not the server.

3. **Test reachability from the phone in a browser.**
   On a phone on the same Wi-Fi, open `http://<server-lan-ip>:9443/status`. If it
   loads, the server is reachable and pairing can proceed.

4. **Open the port in the firewall.**
   ```bash
   sudo ufw allow 9443/tcp
   ```
   (or `sudo firewall-cmd --permanent --add-port=9443/tcp && sudo firewall-cmd --reload`)

5. **Match the port.**
   If you started the agent with `listenPort: 1234`, then the app and curl
   must both use `1234`, not the default `9443`.

6. **Confirm the agent is still running** (a foreground run exits on Ctrl-C):
   ```bash
   ps aux | grep qwe1-agent         # is it running?
   curl http://127.0.0.1:9443/status      # still returns JSON?
   ```

---

## Correct Pairing Procedure

Run `./run.sh` in one terminal — it builds the agent, generates a token + QR
code, and starts the agent in the background:

```bash
./run.sh
```

To regenerate the token later:

```bash
./run.sh token
```

Then in the app tap **Scan QR Code** and scan the terminal/QR image, or enter manually:
- Server URL: `http://<server-lan-ip>:9443`
- Enrollment token: the `qwe1-...` printed by `--enroll`

The token is valid for **1 hour** and can be used by multiple devices. After 1 hour,
run `./run.sh token` again to generate a fresh token.

---

## HTTPS Production Fix

The app "could not connect" and the desire for HTTPS both point toward the
production install, which serves real HTTPS on the same port. Follow the manual
production steps in [GETTING_STARTED.md](GETTING_STARTED.md): generate
self-signed TLS certs, point `tlsCertPath`/`tlsKeyPath` at them in
`/etc/qwe1/config.yaml`, install to `/etc/qwe1/`, and register a systemd service.
Run `./run.sh` to generate a token + QR — scan it with the app to pair over
HTTPS securely.

## Tailscale Support

The app supports Tailscale VPN for remote access. The QR code carries both your
LAN URL and Tailscale URL, so one scan works at home and away. Set
`advertiseTailscaleUrl` in `config.yaml` to your server's Tailscale IP
(e.g. `http://100.x.y.z:9443`), re-run `./run.sh`, and scan the new QR.

---

## Quick Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| App "network exception" | `https://` used, or wrong IP, or port closed | Use `http://<lan-ip>:9443`, open port 9443 |
| `curl https://.../status` fails | Agent is HTTP-only in test mode | Use `http://`, not `https://` |
| Phone can't reach server | Wrong IP (localhost) or firewall | Use server LAN IP, `sudo ufw allow 9443/tcp` |
| Port refused | Agent on different port or not running | Check `ss -tlnp`, restart with matching `--port` |