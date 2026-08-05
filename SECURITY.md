# Security Policy

qwe1 is a remote-management tool — it is a high-value target. We take security seriously and expect the same from our community.

## Supported versions

| Version | Support |
|---------|---------|
| Latest release (`main`) | Security fixes released ASAP |
| Previous minor release | Security fixes for critical/high only |
| Older releases | No security support — upgrade |

We strongly recommend always running the latest release of both the app and the agent. Releases are paired — check the compatibility note in each release.

## Reporting a vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Report privately to the maintainers:

- Email: security@qwe1.example.org (replace with real address before launch)
- GPG key: `[FINGERPRINT]` (published once infrastructure exists)
- Alternatively, use the GitHub **private vulnerability reporting** workflow on the repository (if enabled)

Please include:

- Affected component (app/agent/api) and version
- Description of the vulnerability
- Steps to reproduce (minimal)
- Impact assessment (what an attacker could achieve)
- Suggested fix (if you have one)

### Response timeline

| Step | SLO |
|------|-----|
| Acknowledge receipt | 48 hours |
| Initial triage/impact assessment | 1 week |
| Fix for critical/high | As fast as responsibly possible |
| Disclosure | Coordinated; public advisory + fix in the same release |

## Scope

In scope: the Flutter app, the Go agent, the API contract, the install/update pipeline, and build/CI configuration.

Out of scope (please confirm with maintainers before testing): third-party infrastructure, Docker Engine itself, the user's network/hosts, and denial-of-service against the user's own hardware.

## Ground rules for researchers

- Test only against your own devices/servers.
- Do not access or modify other users' data.
- Do not exfiltrate data beyond what's needed to demonstrate the issue.
- No public disclosure before the fix is released (90-day default window, negotiable).

## Security expectations for releases

Every release must pass the security checklist in the security architecture documentation. Security fixes are released as PATCH (or MINOR if a feature is involved) and announced via GitHub Security Advisories.

## Contact

- Maintainers: `@qwe1/maintainers` on GitHub
- Security: `security@qwe1.example.org` (update before launch)

Thank you for helping keep qwe1 safe.
