# 🔐 Security Policy

## Overview

HackInstall is an **installer script** for penetration testing tools.
This document covers:

1. The security posture of the installer script itself
2. Responsible use of the tools it installs
3. Vulnerability disclosure policy for this project

---

## ⚠️ Legal & Ethical Use Policy

> **CRITICAL: Read this before using HackInstall.**

HackInstall installs powerful offensive security tools. These tools are:

- ✅ **Legal** when used on systems you **own** or have **explicit written permission** to test
- ❌ **Illegal** when used on systems without authorization

### Applicable Laws (non-exhaustive)

| Country | Law |
|---|---|
| Bangladesh | Digital Security Act 2018, ICT Act 2006 Section 54/57 |
| USA | Computer Fraud and Abuse Act (CFAA) |
| UK | Computer Misuse Act 1990 |
| EU | EU Directive 2013/40/EU |
| India | IT Act 2000 (Section 43, 66) |
| Global | Budapest Convention on Cybercrime |

**Violation of these laws can result in criminal prosecution, fines, and imprisonment.**

The author and contributors of HackInstall accept **zero liability** for any illegal or unethical use of this software or the tools it installs.

---

## 🛡️ Script Security

### What the Script Does

- Installs packages via `apt`, `dnf`, `pacman`, `zypper`, `pip`, `gem`, `go install`, or `git clone`
- Writes logs to `/var/log/hackinstall_*.log`
- Requires root (`sudo`) to run
- Clones git repos to `/opt/<tool>/`
- Downloads wordlists to `/usr/share/wordlists/`

### What the Script Does NOT Do

- Does NOT collect or transmit any personal data
- Does NOT create backdoors or persistence mechanisms
- Does NOT phone home to any server
- Does NOT modify system configurations beyond package installation
- Does NOT disable firewalls or security software

### Running Safely

```bash
# Always review a script before running it as root
cat hackinstall.sh | less

# Run in a VM or isolated environment first
# Recommended: Kali Linux VM (VirtualBox / VMware)

# Do not run on production systems
```

---

## 🔍 Vulnerability Disclosure

### Scope

Vulnerabilities in **this project** include:

- Command injection in `hackinstall.sh` via unsanitized user input
- Privilege escalation through the installer
- Malicious code injection via compromised upstream packages
- Insecure download (HTTP instead of HTTPS) of binaries

### Out of Scope

- Vulnerabilities in the **tools that are installed** (report to their respective projects)
- Issues arising from misuse of the installed tools
- Issues on unsupported operating systems

### How to Report

1. **Do NOT open a public GitHub Issue** for security vulnerabilities
2. Send a private report via GitHub's **Security Advisories** feature:
   `Repository → Security → Advisories → New draft security advisory`
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (optional but appreciated)

### Response Timeline

| Stage | Timeframe |
|---|---|
| Acknowledgement | Within 48 hours |
| Initial assessment | Within 7 days |
| Fix / patch | Within 30 days (critical: 7 days) |
| Public disclosure | After patch is released |

---

## 🧪 Safe Testing Environments

Before using any installed tool, set up a proper lab:

### Recommended Lab Setups

```
Option A — Virtual Machines
├── Attacker : Kali Linux (VirtualBox/VMware)
├── Target   : Metasploitable2/3, DVWA, VulnHub VMs
└── Network  : Host-only / NAT (isolated)

Option B — Cloud Labs
├── HackTheBox    : https://hackthebox.com
├── TryHackMe     : https://tryhackme.com
├── PortSwigger   : https://portswigger.net/web-security
└── PentesterLab  : https://pentesterlab.com

Option C — Docker-based
└── docker pull webgoat/goat-and-wolf
    docker pull vulnerables/web-dvwa
    docker pull metasploitable/metasploitable
```

### Networks — NEVER test on

- Corporate networks without written authorization
- ISP networks
- Hospital / critical infrastructure networks
- Government networks
- Any network you don't own

---

## 📦 Supply Chain Security

HackInstall installs tools from:

| Source | Trust Level |
|---|---|
| Official distro repos (apt/dnf/pacman) | ✅ High — signed packages |
| PyPI (pip) | ⚠️ Medium — verify package names carefully |
| RubyGems (gem) | ⚠️ Medium — verify gem names |
| Go modules (go install) | ⚠️ Medium — pinned to @latest |
| GitHub (git clone) | ⚠️ Medium — clones HEAD of default branch |

**Recommendation:** On production/sensitive systems, pin to specific versions and verify checksums manually.

---

## 🔒 Post-Installation Hardening

After installing tools, consider:

```bash
# Restrict access to sensitive tools
chmod 700 /opt/*/

# Use a dedicated low-privilege user for testing
useradd -m -s /bin/bash pentester
usermod -aG sudo pentester

# Enable and configure a firewall
ufw enable
ufw default deny incoming
ufw allow out

# Use proxychains for anonymity during authorized tests
# /etc/proxychains.conf — configure your proxy chain

# Keep tools updated
sudo ./hackinstall.sh --all  # re-run to update
```

---

## 🤝 Responsible Disclosure Pledge

By using HackInstall you agree to:

1. Only test systems you own or have **written authorization** to test
2. Report vulnerabilities you find to system owners **before** public disclosure
3. Not use these tools for financial gain without the system owner's consent
4. Follow the ethical guidelines of bodies such as:
   - EC-Council Code of Ethics
   - (ISC)² Code of Ethics
   - OWASP Code of Conduct
   - Bug Bounty program rules (HackerOne, Bugcrowd, etc.)

---

*Security is a responsibility, not just a skill.*  
*Hack ethically. Hack legally. Hack for good.* ⚔️🛡️
