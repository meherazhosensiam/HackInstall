# ⚔️ HackInstall — Universal Offensive Security Toolkit Installer

```
 ██╗  ██╗ █████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗
 ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
 ███████║███████║██║     █████╔╝ ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║
 ██╔══██║██╔══██║██║     ██╔═██╗ ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║
 ██║  ██║██║  ██║╚██████╗██║  ██╗██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
```

![Bash](https://img.shields.io/badge/Shell-Bash-green?style=flat-square&logo=gnubash)
![Linux](https://img.shields.io/badge/Platform-Linux-blue?style=flat-square&logo=linux)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![Tools](https://img.shields.io/badge/Tools-1000%2B-orange?style=flat-square)
![Version](https://img.shields.io/badge/Version-2.0.0-cyan?style=flat-square)

> **For authorized penetration testing and security research only.**

A single Bash script that lets you install **1000+ offensive security tools** either all at once or by category — with an interactive menu, full logging, and cross-distro support.

---

## 📋 Table of Contents

- [Features](#-features)
- [Supported Distros](#-supported-distros)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Tool Categories](#-tool-categories)
- [Directory Structure](#-directory-structure)
- [Logs](#-logs)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Legal Disclaimer](#-legal-disclaimer)
- [License](#-license)

---

## ✨ Features

| Feature | Details |
|---|---|
| 🎯 Selective Install | Choose 1 or multiple categories from the interactive menu |
| 💣 Full Arsenal | Install all 1000+ tools with a single flag |
| 📦 Multi-Package Manager | apt / dnf / pacman / zypper auto-detection |
| 🐍 pip / 💎 gem / 🐹 go | Installs tools from all major package ecosystems |
| 🌐 git clone | Auto-clones and builds git-only tools to `/opt/` |
| 📄 Full Logging | Timestamped logs saved to `/var/log/hackinstall_*.log` |
| ✅ Pre-flight Checks | Root check, internet check, disk space warning |
| 📊 Summary Report | Count of installed / failed / skipped tools + elapsed time |
| 🔁 Idempotent | Safe to re-run; already-installed tools are skipped |
| ⚠️ Disclaimer | Legal warning prompt before any installation begins |

---

## 🐧 Supported Distros

| Distribution | Package Manager | Status |
|---|---|---|
| Kali Linux | apt | ✅ Primary target |
| Ubuntu / Debian | apt | ✅ Fully supported |
| Parrot OS | apt | ✅ Fully supported |
| Fedora / RHEL / Rocky | dnf | ✅ Supported |
| Arch / BlackArch / Manjaro | pacman | ✅ Supported |
| openSUSE | zypper | ✅ Supported |
| Other Debian-based | apt | ⚠️ Mostly supported |

> **Recommended:** Kali Linux or Ubuntu 22.04+ for best package availability.

---

## 📌 Requirements

```bash
# Must be run as root
sudo -i

# Minimum specs
RAM   : 2 GB+
Disk  : 20 GB+ free (full install ~50 GB)
Net   : Stable internet connection
OS    : Linux (Debian/Ubuntu/Fedora/Arch/openSUSE)
```

---

## 🚀 Quick Start

```bash
# 1. Clone or download
git clone https://github.com/yourusername/hackinstall.git
cd hackinstall

# 2. Make executable
chmod +x hackinstall.sh

# 3. Run as root
sudo ./hackinstall.sh

# Or pass a flag directly
sudo ./hackinstall.sh --all        # Install everything
sudo ./hackinstall.sh --web        # Web app tools only
sudo ./hackinstall.sh --recon      # OSINT & recon only
```

---

## 📖 Usage

### Interactive Menu (no arguments)

```
sudo ./hackinstall.sh
```

You'll see a numbered menu. Type one or more numbers separated by spaces:

```
Enter your choice(s): 2 7 16
```

This installs Recon, Web App, and Cryptography tools.

### Command-Line Flags

```
sudo ./hackinstall.sh [OPTION]

  --all         Install everything (1000+ tools)
  --recon       Reconnaissance & OSINT
  --scan        Scanning & enumeration
  --exploit     Exploitation frameworks
  --password    Password attack tools
  --wireless    Wireless attack tools
  --web         Web application testing
  --sniff       Sniffing & spoofing
  --forensics   Digital forensics & DFIR
  --steg        Steganography tools
  --re          Reverse engineering & binary exploitation
  --mobile      Mobile security (Android/iOS)
  --ad          Active Directory & Windows attacks
  --cloud       Cloud security
  --se          Social engineering
  --crypto      Cryptography & encoding
  --ctf         CTF & general purpose tools
  --pip         Python pip security tools
  --go          Go language security tools
  --ruby        Ruby gem security tools
  --wordlists   Download wordlists & dictionaries
  --deps        Core dependencies only
  --help        Show help
```

---

## 🗂 Tool Categories

<details>
<summary><b>🔎 Reconnaissance & OSINT (25+ tools)</b></summary>

Maltego, Shodan CLI, Censys CLI, Photon, Osrframework, Holehe, Sherlock, Maigret, Phoneinfoga, Twint, Instaloader, Socialscan, SpiderFoot, H8mail, Finalrecon, Raccoon, Crosslinked, Theharvester, Amass, Subfinder, Assetfinder, Recon-ng, Dnsenum, Fierce, GitLeaks, TruffleHog, GitDumper, Gitrob, Sn0int, EmailHarvester

</details>

<details>
<summary><b>🔬 Scanning & Enumeration (20+ tools)</b></summary>

Nmap, Masscan, Rustscan, Naabu, Smap, Unicornscan, Zmap, P0f, Xprobe2, Knock, Dnsrecon, Fping, Gobuster, Ffuf, Feroxbuster, Dirsearch, Enum4linux, Nbtscan, Snmpwalk, Ldapenum, Pywhat, Sn1per

</details>

<details>
<summary><b>💥 Exploitation (15+ tools)</b></summary>

Metasploit Framework, Searchsploit / Exploit-DB, SQLMap, RouterSploit, BeEF-XSS, Commix, XSSer, Platypus, Pupy, jSQL Injection, Ghauri, BFAC, YSOSerial, Nuclei + Templates

</details>

<details>
<summary><b>🔑 Password Attacks (25+ tools)</b></summary>

Hashcat, John the Ripper, Hydra, Medusa, Ncrack, Crunch, CeWL, Mentalist, Rsmangler, Maskprocessor, Pipal, Princeprocessor, Hash-identifier, Hashid, Name-that-hash, Rockyou, Brutespray, Spray, Patator, Crowbar, Hcxtools, Hcxdumptool, Kwprocessor, Statsprocessor

</details>

<details>
<summary><b>📡 Wireless Attacks (20+ tools)</b></summary>

Aircrack-ng, Airgeddon, Wifite2, Kismet, Wavemon, Mdk4, Wifi-honey, Freeradius, Hostapd-wpe, Reaver, Pixiewps, Bully, WPScan, Bluelog, Blueranger, Spooftooph, Bluez, Btscanner, Cowpatty, Fern Wifi Cracker

</details>

<details>
<summary><b>🌐 Web App Testing (35+ tools)</b></summary>

Burp Suite, OWASP ZAP, Nikto, Skipfish, WPScan, Joomscan, Droopescan, CMSmap, Arachni, XSSer, SQLninja, BBQSQL, CORScanner, SecretFinder, LinkFinder, GraphQLmap, Clairvoyance, Cariddi, WhatWeb, WAFW00F, Httprobe, GoWitness, EyeWitness, Feroxbuster, Arjun, Dalfox, KXSS, CRLFUZZ, SSRFmap, Tplmap, JWT-tool, Smuggler

</details>

<details>
<summary><b>🦈 Sniffing & Spoofing (15+ tools)</b></summary>

Wireshark, Tshark, Tcpdump, Ettercap, Bettercap, mitmproxy, ARPspoof, DNSspoof, Macchanger, SSLstrip, Evilgrade, Xerosploit, Responder, Inveigh, Mitm6, Scapy, Impacket

</details>

<details>
<summary><b>🔍 Digital Forensics & DFIR (25+ tools)</b></summary>

Autopsy, Sleuthkit, Volatility3, Foremost, Scalpel, Bulk-extractor, dc3dd, DDrescue, Guymager, Exiftool, Binwalk, Radare2, Plaso, Timesketch, Chainsaw, Hayabusa, Log2timeline, Pcapreader, NetworkMiner, Xplico

</details>

<details>
<summary><b>⚙️ Reverse Engineering & PWN (30+ tools)</b></summary>

GDB + PEDA + GEF + pwndbg, Pwntools, Pwncat, Radare2, Cutter, Ghidra, JADX, Apktool, ROPgadget, Ropper, Angr, Z3-solver, Capstone, Keystone, Unicorn, LIEF, YARA, FLARE-FLOSS, Speakeasy, Qiling, Triton, checksec, one_gadget, seccomp-tools, patchelf, retdec, Rizin, CWE-checker

</details>

<details>
<summary><b>📱 Mobile Security (20+ tools)</b></summary>

ADB, Fastboot, Frida, Objection, MobSF, Apktool, JADX, Drozer, Androguard, Dexdump, Baksmali, APKLeaks, APKSigner, AAPT, QARK, IDB, APK Signer, BytecodeViewer, CFR Decompiler

</details>

<details>
<summary><b>🏢 Active Directory (25+ tools)</b></summary>

CrackMapExec, Evil-WinRM, BloodHound, SharpHound, Impacket suite, Kerbrute, Rubeus, Mimikatz, Pypykatz, secretsdump, Lsassy, NetExec, Enum4linux-ng, SMBmap, Windapsearch, ADIDNSDump, BloodyAD, Certipy, PyWhisker, PKINITtools, DonPAPI, ldapdomaindump, krbrelayx, Responder, Inveigh

</details>

<details>
<summary><b>☁️ Cloud Security (15+ tools)</b></summary>

AWS CLI, Pacu, CloudSploit, Cloudbrute, S3Scanner, Bucket-finder, CloudFlair, GCPBucketBrute, ScoutSuite, Prowler, AzureHound, Stormspotter, TruffleHog, GitLeaks

</details>

<details>
<summary><b>🎣 Social Engineering (15+ tools)</b></summary>

SET (Social Engineer Toolkit), GoPhish, Evilginx2, Modlishka, King Phisher, BeEF-XSS, Wifiphisher, Fluxion, SocialFish, Zphisher, SayCheese, CamPhish, NexPhisher, CredPhish

</details>

<details>
<summary><b>🔐 Cryptography (20+ tools)</b></summary>

OpenSSL, GnuPG, SSLScan, SSLyze, testssl.sh, HashPump, Xortool, FeatherDuster, RSACTFTool, Ciphey, JWT-tool, Padding Oracle, FactorDB CLI, Msieve, YAFU, Cryptography (Python), PyCryptodome

</details>

<details>
<summary><b>🏆 CTF Tools (20+ tools)</b></summary>

Pwntools, Pwncat, GEF/pwndbg/PEDA, CyberChef, checksec, one_gadget, SageMath, Stegoveritas, Volatility, libc-database, patchelf, seccomp-tools, rappel, rp++, angr, z3-solver, autopwn-suite

</details>

<details>
<summary><b>📚 Wordlists</b></summary>

SecLists (full), RockYou, Seclists package, Wordlists package — all downloaded to `/usr/share/`

</details>

---

## 📁 Directory Structure

```
hackinstall/
├── hackinstall.sh       # Main installer script
├── README.md            # This file
├── CONTRIBUTORS.md      # Contributors list
└── SECURITY.md          # Security policy & responsible disclosure
```

Git-cloned tools land in `/opt/<tool-name>/`.
Wordlists land in `/usr/share/wordlists/` and `/usr/share/seclists/`.
Logs: `/var/log/hackinstall_YYYYMMDD_HHMMSS.log`

---

## 📄 Logs

Every installation attempt is logged with a timestamp:

```
/var/log/hackinstall_20250501_143022.log
```

Entries look like:
```
14:30:22 [OK]    Nmap installed
14:30:25 [FAIL]  ghauri — see log for details
14:30:26 [INFO]  Cloning Photon to /opt/Photon
```

At the end of a run a **summary table** is printed showing:
- Total installed
- Total failed (with names)
- Total skipped
- Elapsed time

---

## 🛠 Troubleshooting

| Problem | Solution |
|---|---|
| `Permission denied` | Run with `sudo ./hackinstall.sh` |
| Tool shows `✗` (red) | Check log file for exact error |
| `go: command not found` | Run `--deps` first to install Go |
| `gem: command not found` | Run `--deps` first to install Ruby |
| Slow install | Use a specific flag (e.g. `--web`) instead of `--all` |
| Package not found (dnf/pacman) | Some apt-only packages need AUR/COPR repos |
| Low disk space warning | Free up at least 20 GB before full install |

---

## 🤝 Contributing

Pull requests are welcome! Please read [CONTRIBUTORS.md](CONTRIBUTORS.md) before submitting.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/add-new-tool`
3. Add the tool to the appropriate category function
4. Test on a clean VM
5. Submit a PR with a clear description

---

## ⚖️ Legal Disclaimer

> **This tool is strictly for use on systems you own or have explicit written authorization to test.**
> Unauthorized access to computer systems is illegal under laws including the CFAA (USA), Computer Misuse Act (UK), IT Act 2000 (India), and equivalent laws in Bangladesh and most other countries.
> The authors and contributors accept **zero liability** for any misuse.

---

## 📜 License

```
MIT License — see LICENSE file for full text.
```

---

<div align="center">
Made with ❤️ by Siam | Bangladesh 🇧🇩
</div>
