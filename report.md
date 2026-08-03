# qwe1 Agent — Connection Troubleshooting Report

## Summary

While pairing the qwe1 app to the agent on the Linux server, the app showed a
**"Network exception / Could not connect to server"** error, and
`curl https://<server-ip>:9443/status` also failed to load.

The agent started successfully with the test scripts, but connections were
rejected. **The root cause is a scheme/address mismatch**: the development
`dev.sh` agent serves **plain HTTP on port 9443**, so `https://` and the
wrong URL will never connect.

---

## Root Cause

`scripts/dev.sh` writes a runtime config with empty TLS paths
(`dev.sh`, lines 199-214):

```yaml
serverName: qwe1-runtime
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
   (HTTPS only works after running `scripts/setup-production.sh`, which generates
   TLS certs and serves HTTPS on that port.)

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
   If you started with `./scripts/dev.sh --port 1234`, then the app and curl
   must both use `1234`, not the default `9443`.

6. **Confirm the agent is still running** (a foreground run exits on Ctrl-C):
   ```bash
   cat scripts/.runtime/agent.pid         # shows pid if daemon mode
   curl http://127.0.0.1:9443/status      # still returns JSON?
   tail -f scripts/.runtime/agent.log     # shows startup errors
   ```

---

## Correct Pairing Procedure (test mode)

`dev.sh` runs the agent **and** prints the enrollment token in a single
terminal — no second terminal needed:

```bash
# server, single terminal
./scripts/dev.sh
```

Then in the app enter:
- Server URL: `http://<server-lan-ip>:9443`
- Enrollment token: copy from the `dev.sh` output

For a background run instead: `./scripts/dev.sh --daemon`
(to stop: `./scripts/dev.sh --stop`).
For a full automated check of the API: `./scripts/dev.sh --test`.

---

## HTTPS Production Fix

The app "could not connect" and the desire for HTTPS both point toward the
production install, which serves real HTTPS on the same port:

```bash
git pull origin main
./scripts/setup-production.sh --server my-server --port 9443
```

This cross-builds the agent, generates self-signed TLS certs, installs to
`/etc/qwe1/`, and registers a systemd service. It prints the server fingerprint
and enrollment token — enter both in the app to pair over HTTPS securely.

---

## Quick Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| App "network exception" | `https://` used, or wrong IP, or port closed | Use `http://<lan-ip>:9443`, open port 9443 |
| `curl https://.../status` fails | Agent is HTTP-only in test mode | Use `http://`, not `https://` |
| Phone can't reach server | Wrong IP (localhost) or firewall | Use server LAN IP, `sudo ufw allow 9443/tcp` |
| Port refused | Agent on different port or not running | Check `ss -tlnp`, restart with matching `--port` |