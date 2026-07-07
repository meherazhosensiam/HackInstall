#!/usr/bin/env bash
# =============================================================================
#  H A C K I N S T A L L . S H
#  Universal Offensive Security Toolkit Installer
#  Author  : Meheraz Hosen Siam (github.com/siam)
#  Version : 2.0.0
#  License : MIT
# =============================================================================
# USAGE:
#   chmod +x hackinstall.sh
#   sudo ./hackinstall.sh
# =============================================================================

set -euo pipefail

# ─── COLORS ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── GLOBALS ─────────────────────────────────────────────────────────────────
LOG_FILE="/var/log/hackinstall_$(date +%Y%m%d_%H%M%S).log"
FAILED_TOOLS=()
INSTALLED_TOOLS=()
SKIPPED_TOOLS=()
START_TIME=$(date +%s)

# ─── BANNER ──────────────────────────────────────────────────────────────────
banner() {
  clear
  echo -e "${RED}"
  cat << 'EOF'
 ██╗  ██╗ █████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗
 ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
 ███████║███████║██║     █████╔╝ ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║
 ██╔══██║██╔══██║██║     ██╔═██╗ ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║
 ██║  ██║██║  ██║╚██████╗██║  ██╗██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
EOF
  echo -e "${RESET}"
  echo -e "${DIM}${CYAN}          Universal Offensive Security Toolkit Installer v2.0.0${RESET}"
  echo -e "${DIM}          ─────────────────────────────────────────────────────${RESET}"
  echo -e "${DIM}          For educational / authorized penetration testing only${RESET}\n"
}

# ─── LOGGING ─────────────────────────────────────────────────────────────────
log()    { echo -e "$(date '+%H:%M:%S') [INFO]  $*" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}$(date '+%H:%M:%S') [WARN]  $*${RESET}" | tee -a "$LOG_FILE"; }
success(){ echo -e "${GREEN}$(date '+%H:%M:%S') [OK]    $*${RESET}" | tee -a "$LOG_FILE"; }
error()  { echo -e "${RED}$(date '+%H:%M:%S') [FAIL]  $*${RESET}" | tee -a "$LOG_FILE"; }
section(){ echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════${RESET}"; \
           echo -e "${BOLD}${CYAN}  $*${RESET}"; \
           echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════${RESET}\n"; }

# ─── PREFLIGHT ───────────────────────────────────────────────────────────────
preflight() {
  section "🔍 Pre-flight Checks"

  # Root check
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo $0"
    exit 1
  fi
  success "Running as root"

  # Distro detection
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="${ID:-unknown}"
    DISTRO_VERSION="${VERSION_ID:-unknown}"
    log "Detected: $PRETTY_NAME"
  else
    error "Cannot detect OS. /etc/os-release missing."
    exit 1
  fi

  # Package manager detection
  if   command -v apt-get &>/dev/null; then PKG_MGR="apt"
  elif command -v dnf     &>/dev/null; then PKG_MGR="dnf"
  elif command -v pacman  &>/dev/null; then PKG_MGR="pacman"
  elif command -v zypper  &>/dev/null; then PKG_MGR="zypper"
  else error "No supported package manager found."; exit 1; fi
  success "Package manager: $PKG_MGR"

  # Internet check
  if ! ping -c1 -W3 8.8.8.8 &>/dev/null; then
    error "No internet connection detected."
    exit 1
  fi
  success "Internet: Connected"

  # Disk space (>= 20 GB recommended)
  FREE_GB=$(df / --output=avail -BG | tail -1 | tr -d 'G ')
  if [[ $FREE_GB -lt 10 ]]; then
    warn "Low disk space: ${FREE_GB}GB free (20GB+ recommended)"
  else
    success "Disk space: ${FREE_GB}GB free"
  fi

  echo ""
}

# ─── SYSTEM UPDATE ───────────────────────────────────────────────────────────
update_system() {
  section "🔄 Updating System"
  case $PKG_MGR in
    apt)    apt-get update -qq && apt-get upgrade -y -qq ;;
    dnf)    dnf update -y -q ;;
    pacman) pacman -Syu --noconfirm -q ;;
    zypper) zypper refresh -q && zypper update -y -q ;;
  esac
  success "System updated"
}

# ─── GENERIC INSTALLER ───────────────────────────────────────────────────────
# install_pkg TOOL_NAME PKG_NAME [pip|gem|go|git URL] [extra_cmd]
install_pkg() {
  local name="$1"
  local pkg="$2"
  local method="${3:-pkg}"
  local extra="${4:-}"

  echo -ne "  ${DIM}Installing ${CYAN}${name}${RESET}${DIM}...${RESET} "

  {
    case "$method" in
      pkg)
        case $PKG_MGR in
          apt)    apt-get install -y -qq "$pkg" ;;
          dnf)    dnf install -y -q "$pkg" ;;
          pacman) pacman -S --noconfirm -q "$pkg" ;;
          zypper) zypper install -y -q "$pkg" ;;
        esac ;;
      pip)  pip3 install --quiet --upgrade "$pkg" ;;
      pip2) pip2 install --quiet "$pkg" 2>/dev/null || pip install --quiet "$pkg" ;;
      gem)  gem install "$pkg" --quiet ;;
      go)   go install "$pkg"@latest ;;
      git)
        local dir="/opt/$(basename "$pkg" .git)"
        [[ -d "$dir" ]] && git -C "$dir" pull -q || git clone -q "$pkg" "$dir"
        [[ -n "$extra" ]] && (cd "$dir" && eval "$extra") ;;
      snap) snap install "$pkg" ;;
      wget)
        local dest="/usr/local/bin/$name"
        wget -q "$pkg" -O "$dest" && chmod +x "$dest" ;;
      manual) eval "$pkg" ;;
    esac
  } >> "$LOG_FILE" 2>&1

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓${RESET}"
    INSTALLED_TOOLS+=("$name")
  else
    echo -e "${RED}✗${RESET}"
    FAILED_TOOLS+=("$name")
  fi
}

# ─── DEPENDENCIES ────────────────────────────────────────────────────────────
install_dependencies() {
  section "📦 Core Dependencies"
  local deps=(
    "Python3"        "python3"
    "Python3-pip"    "python3-pip"
    "Git"            "git"
    "Curl"           "curl"
    "Wget"           "wget"
    "Nmap"           "nmap"
    "Net-tools"      "net-tools"
    "Build-essential" "build-essential"
    "Libssl-dev"     "libssl-dev"
    "Libffi-dev"     "libffi-dev"
    "Ruby"           "ruby"
    "Ruby-dev"       "ruby-dev"
    "Golang"         "golang"
    "Perl"           "perl"
    "OpenSSL"        "openssl"
    "Unzip"          "unzip"
    "7zip"           "p7zip-full"
    "Sqlite3"        "sqlite3"
    "Tcpdump"        "tcpdump"
    "Whois"          "whois"
    "Dnsutils"       "dnsutils"
    "Tor"            "tor"
    "Proxychains"    "proxychains4"
    "Libpcap-dev"    "libpcap-dev"
    "Aircrack-ng"    "aircrack-ng"
    "Hydra"          "hydra"
    "John"           "john"
    "Hashcat"        "hashcat"
    "Sqlmap"         "sqlmap"
    "Nikto"          "nikto"
    "Dirb"           "dirb"
    "Gobuster"       "gobuster"
    "Wfuzz"          "wfuzz"
    "Netcat"         "netcat-openbsd"
    "Socat"          "socat"
    "Wireshark"      "wireshark"
    "Tshark"         "tshark"
    "Ettercap"       "ettercap-text-only"
    "Arp-scan"       "arp-scan"
    "Masscan"        "masscan"
    "Enum4linux"     "enum4linux"
    "Smbclient"      "smbclient"
    "Snmp"           "snmp"
    "Ftp"            "ftp"
    "Ssh"            "openssh-client"
    "Medusa"         "medusa"
    "Onesixtyone"    "onesixtyone"
    "Ike-scan"       "ike-scan"
    "Hping3"         "hping3"
    "Yersinia"       "yersinia"
    "Dsniff"         "dsniff"
    "Bettercap"      "bettercap"
    "Recon-ng"       "recon-ng"
    "Metagoofil"     "metagoofil"
    "Dnsenum"        "dnsenum"
    "Fierce"         "fierce"
    "Theharvester"   "theharvester"
    "Sublist3r"      "sublist3r"
    "Amass"          "amass"
    "Whois"          "whois"
    "Lynis"          "lynis"
    "Chkrootkit"     "chkrootkit"
    "Rkhunter"       "rkhunter"
    "Binwalk"        "binwalk"
    "Foremost"       "foremost"
    "Steghide"       "steghide"
    "Stegosuite"     "stegosuite"
    "Exiftool"       "exiftool"
    "Volatility3"    "volatility3"
    "Autopsy"        "autopsy"
    "Sleuthkit"      "sleuthkit"
    "Airbase-ng"     "airbase-ng"
    "Fern-wifi"      "fern-wifi-cracker"
    "Wifite"         "wifite"
    "Cowpatty"       "cowpatty"
    "Crackmapexec"   "crackmapexec"
    "Evil-winrm"     "evil-winrm"
    "Impacket"       "python3-impacket"
    "Kerbrute"       "kerbrute"
    "Dnschef"        "dnschef"
    "Responder"      "responder"
    "Sslstrip"       "sslstrip"
    "Setoolkit"      "set"
    "Beef-xss"       "beef-xss"
    "Webscarab"      "webscarab"
    "Skipfish"       "skipfish"
    "W3af"           "w3af"
    "Zaproxy"        "zaproxy"
    "Burpsuite"      "burpsuite"
    "Commix"         "commix"
    "Xsser"          "xsser"
    "Jsql-injection" "jsql-injection"
    "Ghauri"         "ghauri"
    "Whatweb"        "whatweb"
    "Wafw00f"        "wafw00f"
    "Httprobe"       "httprobe"
    "Gowitness"      "gowitness"
    "Eyewitness"     "eyewitness"
    "Ffuf"           "ffuf"
    "Dirsearch"      "dirsearch"
    "Feroxbuster"    "feroxbuster"
    "Arjun"          "arjun"
    "Gf"             "gf"
    "Nuclei"         "nuclei"
    "Katana"         "katana"
    "Httpx"          "httpx-toolkit"
    "Dnsx"           "dnsx"
    "Subfinder"      "subfinder"
    "Assetfinder"    "assetfinder"
    "Findomain"      "findomain"
    "Chaos-client"   "chaos-client"
    "Haktrails"      "haktrails"
    "Gau"            "gau"
    "Waybackurls"    "waybackurls"
    "Hakrawler"      "hakrawler"
    "Getallurls"     "getallurls"
    "Dalfox"         "dalfox"
    "Kxss"           "kxss"
    "Qsreplace"      "qsreplace"
    "Anew"           "anew"
    "Uro"            "uro"
    "Sqliv"          "sqliv"
    "Nosqlmap"       "nosqlmap"
    "Corscanner"     "corscanner"
    "Crlfuzz"        "crlfuzz"
    "Ssrfmap"        "ssrfmap"
    "Tplmap"         "tplmap"
    "Jwt-tool"       "jwt-tool"
    "Smuggler"       "smuggler"
    "Openssl"        "openssl"
    "Sslscan"        "sslscan"
    "Testssl"        "testssl.sh"
    "Sslyze"         "sslyze"
    "Ncrack"         "ncrack"
    "Pwncat"         "pwncat-cs"
    "Pwndbg"         "pwndbg"
    "Gdb"            "gdb"
    "Ltrace"         "ltrace"
    "Strace"         "strace"
    "Radare2"        "radare2"
    "Ghidra"         "ghidra"
    "Jadx"           "jadx"
    "Apktool"        "apktool"
    "Dex2jar"        "dex2jar"
    "Adb"            "adb"
    "Frida"          "frida-tools"
    "Objection"      "objection"
    "Mobsf"          "mobsf"
    "Androguard"     "androguard"
    "Qemu"           "qemu-system"
    "Docker"         "docker.io"
    "Vagrant"        "vagrant"
    "Vim"            "vim"
    "Tmux"           "tmux"
    "Screen"         "screen"
    "Htop"           "htop"
    "Tree"           "tree"
    "Jq"             "jq"
    "Bat"            "bat"
    "Ripgrep"        "ripgrep"
    "Fd-find"        "fd-find"
  )

  for (( i=0; i<${#deps[@]}; i+=2 )); do
    install_pkg "${deps[$i]}" "${deps[$((i+1))]}" "pkg"
  done
}

# ─── CATEGORY INSTALLERS ─────────────────────────────────────────────────────

install_recon() {
  section "🔎 Reconnaissance & OSINT"
  install_pkg "Maltego"        "maltego"                pkg
  install_pkg "Shodan-cli"     "shodan"                 pip
  install_pkg "Censys-cli"     "censys"                 pip
  install_pkg "Photon"         "https://github.com/s0md3v/Photon.git"  git "pip3 install -r requirements.txt -q"
  install_pkg "Osrframework"   "osrframework"           pip
  install_pkg "Holehe"         "holehe"                 pip
  install_pkg "Sherlock"       "sherlock-project"       pip
  install_pkg "Maigret"        "maigret"                pip
  install_pkg "Phoneinfoga"    "phoneinfoga"            pip
  install_pkg "Twint"          "twint"                  pip
  install_pkg "Instaloader"    "instaloader"            pip
  install_pkg "Socialscan"     "socialscan"             pip
  install_pkg "Pwnedornot"     "https://github.com/thewhiteh4t/pwnedOrNot.git" git ""
  install_pkg "GitLeaks"       "gitleaks"               pkg
  install_pkg "TruffleHog"     "trufflehog"             pip
  install_pkg "GitDumper"      "git-dumper"             pip
  install_pkg "Gitrob"         "gitrob"                 go  "github.com/michenriksen/gitrob"
  install_pkg "Sn0int"         "sn0int"                 pkg
  install_pkg "Spiderfoot"     "spiderfoot"             pip
  install_pkg "H8mail"         "h8mail"                 pip
  install_pkg "EmailHarvester" "EmailHarvester"         pip
  install_pkg "Finalrecon"     "https://github.com/thewhiteh4t/FinalRecon.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Raccoon"        "raccoon-scanner"        pip
  install_pkg "Reconspider"    "https://github.com/bhavsec/reconspider.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Crosslinked"    "crosslinked"            pip
}

install_scanning() {
  section "🔬 Scanning & Enumeration"
  install_pkg "Unicornscan"    "unicornscan"            pkg
  install_pkg "Zmap"           "zmap"                   pkg
  install_pkg "P0f"            "p0f"                    pkg
  install_pkg "Xprobe2"        "xprobe2"                pkg
  install_pkg "Knock"          "knockpy"                pip
  install_pkg "Dnsrecon"       "dnsrecon"               pkg
  install_pkg "Fping"          "fping"                  pkg
  install_pkg "Snmpwalk"       "snmp"                   pkg
  install_pkg "Nbtscan"        "nbtscan"                pkg
  install_pkg "Ldapenum"       "ldap-utils"             pkg
  install_pkg "Pywhat"         "pywhat"                 pip
  install_pkg "Smap"           "smap"                   go  "github.com/s0md3v/smap/cmd/smap"
  install_pkg "Naabu"          "naabu"                  pkg
  install_pkg "Rustscan"       "rustscan"               pkg
  install_pkg "Sn1per"         "https://github.com/1N3/Sn1per.git" git "bash install.sh"
}

install_exploitation() {
  section "💥 Exploitation Frameworks"
  install_pkg "Metasploit"     "metasploit-framework"   pkg
  install_pkg "Exploit-db"     "exploitdb"              pkg
  install_pkg "Searchsploit"   "exploitdb"              pkg
  install_pkg "Sqlmap"         "sqlmap"                 pkg
  install_pkg "Routersploit"   "routersploit"           pip
  install_pkg "Bfac"           "bfac"                   pip
  install_pkg "Ysoserial"      "ysoserial"              pkg
  install_pkg "Nuclei-templates" "https://github.com/projectdiscovery/nuclei-templates.git" git ""
  install_pkg "Platypus"       "platypus-term"          pkg
  install_pkg "Pupy"           "https://github.com/n1nj4sec/pupy.git" git ""
}

install_password() {
  section "🔑 Password Attacks"
  install_pkg "Hashcat"        "hashcat"                pkg
  install_pkg "John"           "john"                   pkg
  install_pkg "Hydra"          "hydra"                  pkg
  install_pkg "Medusa"         "medusa"                 pkg
  install_pkg "Ncrack"         "ncrack"                 pkg
  install_pkg "Crunch"         "crunch"                 pkg
  install_pkg "Wordlistctl"    "wordlistctl"            pkg
  install_pkg "Cewl"           "cewl"                   pkg
  install_pkg "Mentalist"      "mentalist"              pkg
  install_pkg "Rsmangler"      "rsmangler"              pkg
  install_pkg "Maskprocessor"  "maskprocessor"          pkg
  install_pkg "Kwprocessor"    "kwprocessor"            pkg
  install_pkg "Pipal"          "pipal"                  pkg
  install_pkg "Princeprocessor" "princeprocessor"       pkg
  install_pkg "Hash-identifier" "hash-identifier"       pkg
  install_pkg "Hashid"         "hashid"                 pip
  install_pkg "Name-that-hash" "name-that-hash"         pip
  install_pkg "Rockyou"        "wordlists"              pkg
  install_pkg "Brutespray"     "brutespray"             pkg
  install_pkg "Spray"          "spray"                  pip
  install_pkg "Patator"        "patator"                pkg
  install_pkg "Crowbar"        "crowbar"                pkg
  install_pkg "Thc-pptp-bruter" "thc-pptp-bruter"      pkg
  install_pkg "Statsprocessor" "statsprocessor"         pkg
  install_pkg "Hcxtools"       "hcxtools"               pkg
  install_pkg "Hcxdumptool"    "hcxdumptool"            pkg
}

install_wireless() {
  section "📡 Wireless Attacks"
  install_pkg "Aircrack-ng"    "aircrack-ng"            pkg
  install_pkg "Airgeddon"      "https://github.com/v1s1t0r1sh3r3/airgeddon.git" git ""
  install_pkg "Wifite2"        "wifite2"                pkg
  install_pkg "Kismet"         "kismet"                 pkg
  install_pkg "Wavemon"        "wavemon"                pkg
  install_pkg "Horst"          "horst"                  pkg
  install_pkg "Wifi-honey"     "wifi-honey"             pkg
  install_pkg "Mdk4"           "mdk4"                   pkg
  install_pkg "Freeradius"     "freeradius"             pkg
  install_pkg "Hostapd-wpe"    "hostapd-wpe"            pkg
  install_pkg "Eapmd5pass"     "eapmd5pass"             pkg
  install_pkg "Reaver"         "reaver"                 pkg
  install_pkg "Pixiewps"       "pixiewps"               pkg
  install_pkg "Bully"          "bully"                  pkg
  install_pkg "Wps-scan"       "wpscan"                 gem
  install_pkg "Bluelog"        "bluelog"                pkg
  install_pkg "Blueranger"     "blueranger"             pkg
  install_pkg "Spooftooph"     "spooftooph"             pkg
  install_pkg "Bluez"          "bluez"                  pkg
  install_pkg "Bluez-tools"    "bluez-tools"            pkg
  install_pkg "Btscanner"      "btscanner"              pkg
  install_pkg "Rfkill"         "rfkill"                 pkg
}

install_webapps() {
  section "🌐 Web Application Testing"
  install_pkg "Burpsuite"      "burpsuite"              pkg
  install_pkg "Zaproxy"        "zaproxy"                pkg
  install_pkg "Nikto"          "nikto"                  pkg
  install_pkg "Skipfish"       "skipfish"               pkg
  install_pkg "Wpscan"         "wpscan"                 gem
  install_pkg "Joomscan"       "joomscan"               pkg
  install_pkg "Droopescan"     "droopescan"             pip
  install_pkg "Cmsmap"         "cmsmap"                 pip
  install_pkg "Wpseku"         "https://github.com/m4ll0k/WPSeku.git" git ""
  install_pkg "Arachni"        "arachni"                pkg
  install_pkg "Vega"           "vega"                   pkg
  install_pkg "Grabber"        "grabber"                pkg
  install_pkg "Websploit"      "websploit"              pkg
  install_pkg "Xsser"          "xsser"                  pkg
  install_pkg "Sqlninja"       "sqlninja"               pkg
  install_pkg "Bbqsql"         "bbqsql"                 pip
  install_pkg "Blind-sql-bitshifting" "https://github.com/awnumar/blind-sql-bitshifting.git" git ""
  install_pkg "Subdomainer"    "subdomainer"            pip
  install_pkg "Virtual-host-discovery" "https://github.com/jobertabma/virtual-host-discovery.git" git ""
  install_pkg "Cors-scanner"   "cors-scanner"           pip
  install_pkg "Secretfinder"   "https://github.com/m4ll0k/SecretFinder.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Linkfinder"     "https://github.com/GerbenJavado/LinkFinder.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Js-scan"        "https://github.com/zricethezav/gitleaks.git" git ""
  install_pkg "Cariddi"        "cariddi" go "github.com/edoardottt/cariddi/cmd/cariddi"
  install_pkg "Graphqlmap"     "https://github.com/swisskyrepo/GraphQLmap.git" git ""
  install_pkg "Clairvoyance"   "clairvoyance"           pip
}

install_sniffing() {
  section "🦈 Sniffing & Spoofing"
  install_pkg "Wireshark"      "wireshark"              pkg
  install_pkg "Tshark"         "tshark"                 pkg
  install_pkg "Tcpdump"        "tcpdump"                pkg
  install_pkg "Ettercap"       "ettercap-graphical"     pkg
  install_pkg "Bettercap"      "bettercap"              pkg
  install_pkg "Mitmproxy"      "mitmproxy"              pkg
  install_pkg "Arpspoof"       "dsniff"                 pkg
  install_pkg "Dnsspoof"       "dsniff"                 pkg
  install_pkg "Macchanger"     "macchanger"             pkg
  install_pkg "Sslstrip2"      "sslstrip"               pkg
  install_pkg "Evilgrade"      "evilgrade"              pkg
  install_pkg "Xerosploit"     "https://github.com/LionSec/xerosploit.git" git ""
  install_pkg "Responder"      "responder"              pkg
  install_pkg "Inveigh"        "inveigh"                pkg
  install_pkg "Mitm6"          "mitm6"                  pip
  install_pkg "Scapy"          "scapy"                  pip
  install_pkg "Impacket"       "impacket"               pip
}

install_forensics() {
  section "🔍 Digital Forensics & Incident Response"
  install_pkg "Autopsy"        "autopsy"                pkg
  install_pkg "Sleuthkit"      "sleuthkit"              pkg
  install_pkg "Volatility3"    "volatility3"            pip
  install_pkg "Foremost"       "foremost"               pkg
  install_pkg "Scalpel"        "scalpel"                pkg
  install_pkg "Bulk-extractor" "bulk-extractor"         pkg
  install_pkg "Dc3dd"          "dc3dd"                  pkg
  install_pkg "Ddrescue"       "gddrescue"              pkg
  install_pkg "Safecopy"       "safecopy"               pkg
  install_pkg "Guymager"       "guymager"               pkg
  install_pkg "Exiftool"       "libimage-exiftool-perl" pkg
  install_pkg "Exiv2"          "exiv2"                  pkg
  install_pkg "Binwalk"        "binwalk"                pkg
  install_pkg "Firmware-mod-kit" "firmware-mod-kit"     pkg
  install_pkg "Radare2"        "radare2"                pkg
  install_pkg "Strings"        "binutils"               pkg
  install_pkg "Hexdump"        "bsdmainutils"           pkg
  install_pkg "Xxd"            "xxd"                    pkg
  install_pkg "Plaso"          "plaso"                  pip
  install_pkg "Timesketch"     "timesketch"             pip
  install_pkg "Chainsaw"       "https://github.com/WithSecureLabs/chainsaw.git" git ""
  install_pkg "Hayabusa"       "hayabusa"               pkg
  install_pkg "Log2timeline"   "log2timeline"           pkg
  install_pkg "Pcapreader"     "pcapreader"             pip
  install_pkg "Networkminer"   "networkminer"           pkg
  install_pkg "Xplico"         "xplico"                 pkg
}

install_steganography() {
  section "🎭 Steganography"
  install_pkg "Steghide"       "steghide"               pkg
  install_pkg "Stegcracker"    "stegcracker"            pip
  install_pkg "Zsteg"          "zsteg"                  gem
  install_pkg "Stegsolve"      "stegsolve"              pkg
  install_pkg "Outguess"       "outguess"               pkg
  install_pkg "Openstego"      "openstego"              pkg
  install_pkg "Stegosuite"     "stegosuite"             pkg
  install_pkg "Steganabara"    "steganabara"            pkg
  install_pkg "Pngcheck"       "pngcheck"               pkg
  install_pkg "Spectrology"    "https://github.com/solusipse/spectrology.git" git ""
  install_pkg "Exif-steganography" "https://github.com/RickdeJager/stegseek.git" git ""
  install_pkg "Stegsnow"       "stegsnow"               pkg
  install_pkg "Snowdrop"       "snowdrop"               pkg
  install_pkg "Jphide"         "jphide"                 pkg
}

install_reverse_engineering() {
  section "⚙️  Reverse Engineering & Binary Exploitation"
  install_pkg "Gdb"            "gdb"                    pkg
  install_pkg "Pwndbg"         "pwndbg"                 pkg
  install_pkg "Peda"           "https://github.com/longld/peda.git" git "echo 'source ~/peda/peda.py' >> ~/.gdbinit"
  install_pkg "Pwntools"       "pwntools"               pip
  install_pkg "Radare2"        "radare2"                pkg
  install_pkg "Cutter"         "cutter"                 pkg
  install_pkg "Ghidra"         "ghidra"                 pkg
  install_pkg "Jadx"           "jadx"                   pkg
  install_pkg "Apktool"        "apktool"                pkg
  install_pkg "Dex2jar"        "dex2jar"                pkg
  install_pkg "Objdump"        "binutils"               pkg
  install_pkg "Ltrace"         "ltrace"                 pkg
  install_pkg "Strace"         "strace"                 pkg
  install_pkg "Checksec"       "checksec"               pkg
  install_pkg "Ropgadget"      "ROPGadget"              pip
  install_pkg "Ropper"         "ropper"                 pip
  install_pkg "Angr"           "angr"                   pip
  install_pkg "Z3-solver"      "z3-solver"              pip
  install_pkg "Capstone"       "capstone"               pip
  install_pkg "Keystone"       "keystone-engine"        pip
  install_pkg "Unicorn"        "unicorn"                pip
  install_pkg "Lief"           "lief"                   pip
  install_pkg "Yara-python"    "yara-python"            pip
  install_pkg "Yara"           "yara"                   pkg
  install_pkg "Retdec"         "retdec"                 pkg
  install_pkg "Binary-ninja"   "binary-ninja"           pkg
  install_pkg "Rizin"          "rizin"                  pkg
  install_pkg "Cwe-checker"    "cwe_checker"            pip
  install_pkg "Flare-floss"    "floss"                  pip
  install_pkg "Speakeasy"      "speakeasy-emulator"     pip
  install_pkg "Qiling"         "qiling"                 pip
  install_pkg "Triton"         "triton"                 pip
}

install_mobile() {
  section "📱 Mobile Security"
  install_pkg "Adb"            "adb"                    pkg
  install_pkg "Fastboot"       "fastboot"               pkg
  install_pkg "Frida"          "frida-tools"            pip
  install_pkg "Objection"      "objection"              pip
  install_pkg "Mobsf"          "mobsf"                  pip
  install_pkg "Apktool"        "apktool"                pkg
  install_pkg "Jadx"           "jadx"                   pkg
  install_pkg "Drozer"         "drozer"                 pip
  install_pkg "Androguard"     "androguard"             pip
  install_pkg "Dexdump"        "dexdump"                pkg
  install_pkg "Baksmali"       "baksmali"               pkg
  install_pkg "Signapk"        "signapk"                pkg
  install_pkg "Uber-apk-signer" "uber-apk-signer"       pkg
  install_pkg "Apkleaks"       "apkleaks"               pip
  install_pkg "Apksigner"      "apksigner"              pkg
  install_pkg "Aapt"           "aapt"                   pkg
  install_pkg "Qark"           "qark"                   pip
  install_pkg "Idb"            "idb"                    gem
  install_pkg "Ipa-installer"  "ios-deploy"             pkg
  install_pkg "Cfr-decompiler" "cfr"                    pkg
  install_pkg "Bytecodeviewer" "bytecodeviewer"         pkg
}

install_active_directory() {
  section "🏢 Active Directory & Windows"
  install_pkg "Crackmapexec"   "crackmapexec"           pkg
  install_pkg "Evil-winrm"     "evil-winrm"             gem
  install_pkg "Bloodhound"     "bloodhound"             pkg
  install_pkg "Sharphound"     "sharphound"             pkg
  install_pkg "Impacket"       "impacket"               pip
  install_pkg "Kerbrute"       "kerbrute"               pkg
  install_pkg "Rubeus"         "rubeus"                 pkg
  install_pkg "Mimikatz"       "mimikatz"               pkg
  install_pkg "Pypykatz"       "pypykatz"               pip
  install_pkg "Secretsdump"    "impacket-secretsdump"   pip
  install_pkg "Lsassy"         "lsassy"                 pip
  install_pkg "Nxcdb"          "netexec"                pip
  install_pkg "Enum4linux-ng"  "enum4linux-ng"          pip
  install_pkg "Smbmap"         "smbmap"                 pip
  install_pkg "Windapsearch"   "windapsearch"           pkg
  install_pkg "Adidnsdump"     "adidnsdump"             pip
  install_pkg "Bloodyad"       "bloodyAD"               pip
  install_pkg "Certipy"        "certipy-ad"             pip
  install_pkg "Pywhisker"      "pywhisker"              pip
  install_pkg "Pkinittools"    "pkinittools"            pip
  install_pkg "Donpapi"        "donpapi"                pip
  install_pkg "Ldapdomaindump" "ldapdomaindump"         pip
  install_pkg "Krbrelayx"      "krbrelayx"              pip
  install_pkg "Responder"      "responder"              pkg
  install_pkg "Inveigh"        "inveigh"                pkg
}

install_cloud() {
  section "☁️  Cloud Security"
  install_pkg "Awscli"         "awscli"                 pip
  install_pkg "Pacu"           "pacu"                   pip
  install_pkg "Cloudsploit"    "cloudsploit"            pkg
  install_pkg "Cloudbrute"     "cloudbrute"             go  "github.com/0xsha/cloudbrute"
  install_pkg "S3scanner"      "s3scanner"              pip
  install_pkg "Bucket-finder"  "bucket-finder"          gem
  install_pkg "Cloudflair"     "CloudFlair"             pip
  install_pkg "Gcpbucketbrute" "https://github.com/RhinoSecurityLabs/GCPBucketBrute.git" git ""
  install_pkg "Scoutsuite"     "scoutsuite"             pip
  install_pkg "Prowler"        "prowler"                pip
  install_pkg "Azurehound"     "azurehound"             pkg
  install_pkg "Stormspotter"   "stormspotter"           pip
  install_pkg "Trufflehog"     "trufflehog"             pip
  install_pkg "Gitleaks"       "gitleaks"               pkg
  install_pkg "Gitallsecrets"  "git-all-secrets"        pkg
}

install_social_engineering() {
  section "🎣 Social Engineering"
  install_pkg "Setoolkit"      "set"                    pkg
  install_pkg "Gophish"        "gophish"                pkg
  install_pkg "Evilginx2"      "evilginx2"              pkg
  install_pkg "Modlishka"      "modlishka"              go  "github.com/drk1wi/Modlishka"
  install_pkg "Phishx"         "https://github.com/rezaaksa/phishx.git" git ""
  install_pkg "King-phisher"   "king-phisher"           pkg
  install_pkg "Beef-xss"       "beef-xss"               pkg
  install_pkg "Wifiphisher"    "wifiphisher"            pkg
  install_pkg "Fluxion"        "https://github.com/FluxionNetwork/fluxion.git" git ""
  install_pkg "Socialfish"     "https://github.com/UndeadSec/SocialFish.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Zphisher"       "https://github.com/htr-tech/zphisher.git" git ""
  install_pkg "Saycheese"      "https://github.com/hangetzzu/saycheese.git" git ""
  install_pkg "Camphish"       "https://github.com/techchipnet/CamPhish.git" git ""
  install_pkg "Nexphisher"     "https://github.com/htr-tech/nexphisher.git" git ""
  install_pkg "Credphish"      "credphish"              pip
}

install_cryptography() {
  section "🔐 Cryptography & Encoding"
  install_pkg "Openssl"        "openssl"                pkg
  install_pkg "Gpg"            "gnupg"                  pkg
  install_pkg "Sslscan"        "sslscan"                pkg
  install_pkg "Sslyze"         "sslyze"                 pip
  install_pkg "Testssl"        "testssl.sh"             pkg
  install_pkg "Cryptography"   "cryptography"           pip
  install_pkg "Pycryptodome"   "pycryptodome"           pip
  install_pkg "Hashpump"       "hashpump"               pkg
  install_pkg "Xortool"        "xortool"                pip
  install_pkg "Featherduster"  "featherduster"          pip
  install_pkg "Rsactftool"     "rsactftool"             pip
  install_pkg "Ciphey"         "ciphey"                 pip
  install_pkg "Dcode"          "dcode"                  pip
  install_pkg "Jwt-cracker"    "https://github.com/lmammino/jwt-cracker.git" git ""
  install_pkg "Jwt-tool"       "jwt-tool"               pip
  install_pkg "Padding-oracle" "https://github.com/mwielgoszewski/python-paddingoracle.git" git ""
  install_pkg "Factordb-cli"   "factordb-cli"           pip
  install_pkg "Msieve"         "msieve"                 pkg
  install_pkg "Yafu"           "yafu"                   pkg
}

install_ctf_tools() {
  section "🏆 CTF & General Purpose Tools"
  install_pkg "Pwntools"       "pwntools"               pip
  install_pkg "Pwncat"         "pwncat-cs"              pip
  install_pkg "Binja-free"     "binary-ninja-free"      pkg
  install_pkg "Cyberchef"      "https://github.com/gchq/CyberChef.git" git ""
  install_pkg "Checksec"       "checksec"               pkg
  install_pkg "Gef"            "https://github.com/hugsy/gef.git" git "pip3 install -r requirements.txt -q"
  install_pkg "Pwndbg"         "pwndbg"                 pkg
  install_pkg "One-gadget"     "one_gadget"             gem
  install_pkg "Niklata"        "niklata"                pip
  install_pkg "Gmpy2"          "python3-gmpy2"          pkg
  install_pkg "Sage"           "sagemath"               pkg
  install_pkg "Stegoveritas"   "stegoveritas"           pip
  install_pkg "Volatility"     "volatility"             pip
  install_pkg "Autopwn-suite"  "autopwn-suite"          pip
  install_pkg "Exploit-utils"  "exploit-utils"          pip
  install_pkg "Aeskeyschedule" "aeskeyschedule"         pip
  install_pkg "Libc-database"  "https://github.com/niklasb/libc-database.git" git ""
  install_pkg "Patchelf"       "patchelf"               pkg
  install_pkg "Seccomp-tools"  "seccomp-tools"          gem
  install_pkg "Rappel"         "rappel"                 pkg
  install_pkg "Rp++"           "rp"                     pkg
}

install_custom_pip_tools() {
  section "🐍 Python Security Tools (pip)"
  local tools=(
    "dirsearch" "shodan" "censys" "h8mail" "holehe"
    "sherlock-project" "maigret" "phoneinfoga" "instaloader"
    "socialscan" "osrframework" "twint" "arjun" "uro"
    "sqliv" "nosqlmap" "corscanner" "crlfuzz" "ssrfmap"
    "tplmap" "jwt-tool" "smuggler" "sslyze" "dnschef"
    "impacket" "pypykatz" "lsassy" "netexec" "enum4linux-ng"
    "smbmap" "adidnsdump" "bloodyad" "certipy-ad" "pywhisker"
    "pkinittools" "donpapi" "ldapdomaindump" "krbrelayx"
    "pacu" "s3scanner" "scoutsuite" "prowler" "stormspotter"
    "trufflehog" "gitleaks" "credphish" "cryptography"
    "pycryptodome" "xortool" "featherduster" "rsactftool"
    "ciphey" "jwt-cracker" "factordb-cli" "pwntools"
    "pwncat-cs" "stegoveritas" "volatility3" "autopwn-suite"
    "exploit-utils" "aeskeyschedule" "frida-tools" "objection"
    "mobsf" "androguard" "qark" "apkleaks" "mitm6"
    "mitmproxy" "scapy" "angr" "z3-solver" "capstone"
    "keystone-engine" "unicorn" "lief" "yara-python" "floss"
    "speakeasy-emulator" "qiling" "ropgadget" "ropper"
    "raccoon-scanner" "finalrecon" "crosslinked"
    "cloudflair" "cloudbrute" "secretfinder"
  )
  for t in "${tools[@]}"; do
    install_pkg "$t" "$t" pip
  done
}

install_custom_go_tools() {
  section "🐹 Go Security Tools"
  export PATH=$PATH:/usr/local/go/bin
  # Ensure go is installed
  if ! command -v go &>/dev/null; then
    warn "Go not found. Skipping Go tools."
    return
  fi
  local tools=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    "github.com/projectdiscovery/httpx/cmd/httpx"
    "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu"
    "github.com/projectdiscovery/dnsx/cmd/dnsx"
    "github.com/projectdiscovery/katana/cmd/katana"
    "github.com/projectdiscovery/chaos-client/cmd/chaos"
    "github.com/hakluke/hakrawler"
    "github.com/hakluke/haktrails"
    "github.com/hakluke/hakrevdns"
    "github.com/lc/gau/v2/cmd/gau"
    "github.com/tomnomnom/waybackurls"
    "github.com/tomnomnom/httprobe"
    "github.com/tomnomnom/assetfinder"
    "github.com/tomnomnom/gf"
    "github.com/tomnomnom/anew"
    "github.com/tomnomnom/qsreplace"
    "github.com/tomnomnom/unfurl"
    "github.com/tomnomnom/meg"
    "github.com/tomnomnom/fff"
    "github.com/tomnomnom/hacks/html-tool"
    "github.com/ffuf/ffuf/v2"
    "github.com/OJ/gobuster/v3"
    "github.com/epi052/feroxbuster"
    "github.com/hahwul/dalfox/v2"
    "github.com/Emoe/kxss"
    "github.com/edoardottt/cariddi/cmd/cariddi"
    "github.com/michenriksen/gitrob"
    "github.com/0xsha/cloudbrute"
    "github.com/drk1wi/Modlishka"
    "github.com/sensepost/gowitness"
    "github.com/jaeles-project/jaeles"
    "github.com/jaeles-project/gospider"
    "github.com/d3mondev/puredns/v2"
    "github.com/Cgboal/SonarSearch/cmd/crobat"
    "github.com/Ice3man543/hawkeye"
    "github.com/gwen001/github-subdomains"
    "github.com/gwen001/gitlab-subdomains"
    "github.com/takshal/freq"
    "github.com/j3ssie/metabigor"
    "github.com/j3ssie/osmedeus/cmd/osmedeus"
    "github.com/s0md3v/smap/cmd/smap"
    "github.com/glitchedgitz/cook/v2/cmd/cook"
  )
  for t in "${tools[@]}"; do
    name=$(basename "$t")
    install_pkg "$name" "$t" go
  done
}

install_ruby_tools() {
  section "💎 Ruby Security Tools (gem)"
  local tools=(
    "wpscan" "evil-winrm" "one_gadget" "seccomp-tools"
    "idb" "bucket-finder" "zsteg"
  )
  for t in "${tools[@]}"; do
    install_pkg "$t" "$t" gem
  done
}

install_wordlists() {
  section "📚 Wordlists & Dictionaries"
  install_pkg "Wordlists"      "wordlists"              pkg
  install_pkg "Seclists"       "seclists"               pkg

  # Download SecLists if not present
  if [[ ! -d /usr/share/seclists ]]; then
    log "Cloning SecLists to /usr/share/seclists ..."
    git clone -q --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists \
      >> "$LOG_FILE" 2>&1 && success "SecLists downloaded" || warn "SecLists failed"
  else
    success "SecLists already present"
  fi

  # Download rockyou if not present
  if [[ ! -f /usr/share/wordlists/rockyou.txt ]]; then
    if [[ -f /usr/share/wordlists/rockyou.txt.gz ]]; then
      gzip -d /usr/share/wordlists/rockyou.txt.gz && success "rockyou.txt extracted"
    else
      wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt \
        -O /usr/share/wordlists/rockyou.txt && success "rockyou.txt downloaded" || warn "rockyou download failed"
    fi
  else
    success "rockyou.txt already present"
  fi
}

# ─── SUMMARY ─────────────────────────────────────────────────────────────────
print_summary() {
  local end_time=$(date +%s)
  local elapsed=$(( end_time - START_TIME ))
  local mins=$(( elapsed / 60 ))
  local secs=$(( elapsed % 60 ))

  section "📊 Installation Summary"
  echo -e "  ${GREEN}✓ Installed : ${#INSTALLED_TOOLS[@]} tools${RESET}"
  echo -e "  ${RED}✗ Failed    : ${#FAILED_TOOLS[@]} tools${RESET}"
  echo -e "  ${YELLOW}⊘ Skipped   : ${#SKIPPED_TOOLS[@]} tools${RESET}"
  echo -e "  ${CYAN}⏱ Time      : ${mins}m ${secs}s${RESET}"
  echo -e "  ${DIM}📄 Log       : $LOG_FILE${RESET}\n"

  if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}  Failed tools (manual install needed):${RESET}"
    for t in "${FAILED_TOOLS[@]}"; do
      echo -e "    ${RED}• $t${RESET}"
    done
    echo ""
  fi
  success "HackInstall complete! Happy hacking (legally)."
}

# ─── INTERACTIVE MENU ────────────────────────────────────────────────────────
interactive_menu() {
  banner
  echo -e "${BOLD}${CYAN}  SELECT INSTALLATION MODE${RESET}\n"
  echo -e "  ${YELLOW}[1]${RESET}  🔥 INSTALL ALL (Full Arsenal — 1000+ tools)"
  echo -e "  ${YELLOW}[2]${RESET}  🔎 Reconnaissance & OSINT"
  echo -e "  ${YELLOW}[3]${RESET}  🔬 Scanning & Enumeration"
  echo -e "  ${YELLOW}[4]${RESET}  💥 Exploitation Frameworks"
  echo -e "  ${YELLOW}[5]${RESET}  🔑 Password Attacks"
  echo -e "  ${YELLOW}[6]${RESET}  📡 Wireless Attacks"
  echo -e "  ${YELLOW}[7]${RESET}  🌐 Web Application Testing"
  echo -e "  ${YELLOW}[8]${RESET}  🦈 Sniffing & Spoofing"
  echo -e "  ${YELLOW}[9]${RESET}  🔍 Digital Forensics & DFIR"
  echo -e "  ${YELLOW}[10]${RESET} 🎭 Steganography"
  echo -e "  ${YELLOW}[11]${RESET} ⚙️  Reverse Engineering & PWN"
  echo -e "  ${YELLOW}[12]${RESET} 📱 Mobile Security"
  echo -e "  ${YELLOW}[13]${RESET} 🏢 Active Directory & Windows"
  echo -e "  ${YELLOW}[14]${RESET} ☁️  Cloud Security"
  echo -e "  ${YELLOW}[15]${RESET} 🎣 Social Engineering"
  echo -e "  ${YELLOW}[16]${RESET} 🔐 Cryptography & Encoding"
  echo -e "  ${YELLOW}[17]${RESET} 🏆 CTF Tools"
  echo -e "  ${YELLOW}[18]${RESET} 🐍 Python Tools (pip)"
  echo -e "  ${YELLOW}[19]${RESET} 🐹 Go Tools"
  echo -e "  ${YELLOW}[20]${RESET} 💎 Ruby Tools (gem)"
  echo -e "  ${YELLOW}[21]${RESET} 📚 Wordlists & Dictionaries"
  echo -e "  ${YELLOW}[22]${RESET} 📦 Core Dependencies Only"
  echo -e "  ${YELLOW}[0]${RESET}  ❌ Exit\n"
  echo -ne "  ${BOLD}Enter your choice(s) separated by space: ${RESET}"
  read -r -a choices

  for choice in "${choices[@]}"; do
    case "$choice" in
      1)  update_system
          install_dependencies
          install_recon
          install_scanning
          install_exploitation
          install_password
          install_wireless
          install_webapps
          install_sniffing
          install_forensics
          install_steganography
          install_reverse_engineering
          install_mobile
          install_active_directory
          install_cloud
          install_social_engineering
          install_cryptography
          install_ctf_tools
          install_custom_pip_tools
          install_custom_go_tools
          install_ruby_tools
          install_wordlists ;;
      2)  install_recon ;;
      3)  install_scanning ;;
      4)  install_exploitation ;;
      5)  install_password ;;
      6)  install_wireless ;;
      7)  install_webapps ;;
      8)  install_sniffing ;;
      9)  install_forensics ;;
      10) install_steganography ;;
      11) install_reverse_engineering ;;
      12) install_mobile ;;
      13) install_active_directory ;;
      14) install_cloud ;;
      15) install_social_engineering ;;
      16) install_cryptography ;;
      17) install_ctf_tools ;;
      18) install_custom_pip_tools ;;
      19) install_custom_go_tools ;;
      20) install_ruby_tools ;;
      21) install_wordlists ;;
      22) install_dependencies ;;
      0)  echo -e "\n${YELLOW}Goodbye, hacker.${RESET}\n"; exit 0 ;;
      *)  warn "Unknown option: $choice. Skipped." ;;
    esac
  done
}

# ─── ARGUMENT MODE ───────────────────────────────────────────────────────────
arg_mode() {
  case "${1:-}" in
    --all|-a)         update_system; install_dependencies
                      install_recon; install_scanning; install_exploitation
                      install_password; install_wireless; install_webapps
                      install_sniffing; install_forensics; install_steganography
                      install_reverse_engineering; install_mobile
                      install_active_directory; install_cloud
                      install_social_engineering; install_cryptography
                      install_ctf_tools; install_custom_pip_tools
                      install_custom_go_tools; install_ruby_tools
                      install_wordlists ;;
    --recon)          install_recon ;;
    --scan)           install_scanning ;;
    --exploit)        install_exploitation ;;
    --password)       install_password ;;
    --wireless)       install_wireless ;;
    --web)            install_webapps ;;
    --sniff)          install_sniffing ;;
    --forensics)      install_forensics ;;
    --steg)           install_steganography ;;
    --re)             install_reverse_engineering ;;
    --mobile)         install_mobile ;;
    --ad)             install_active_directory ;;
    --cloud)          install_cloud ;;
    --se)             install_social_engineering ;;
    --crypto)         install_cryptography ;;
    --ctf)            install_ctf_tools ;;
    --pip)            install_custom_pip_tools ;;
    --go)             install_custom_go_tools ;;
    --ruby)           install_ruby_tools ;;
    --wordlists)      install_wordlists ;;
    --deps)           install_dependencies ;;
    --help|-h)
      echo -e "${BOLD}Usage:${RESET} sudo $0 [OPTION]"
      echo ""
      echo "  --all         Install everything (1000+ tools)"
      echo "  --recon       Reconnaissance & OSINT tools"
      echo "  --scan        Scanning & enumeration tools"
      echo "  --exploit     Exploitation frameworks"
      echo "  --password    Password attack tools"
      echo "  --wireless    Wireless attack tools"
      echo "  --web         Web app testing tools"
      echo "  --sniff       Sniffing & spoofing tools"
      echo "  --forensics   Digital forensics tools"
      echo "  --steg        Steganography tools"
      echo "  --re          Reverse engineering & PWN"
      echo "  --mobile      Mobile security tools"
      echo "  --ad          Active Directory & Windows"
      echo "  --cloud       Cloud security tools"
      echo "  --se          Social engineering tools"
      echo "  --crypto      Cryptography tools"
      echo "  --ctf         CTF & general purpose tools"
      echo "  --pip         Python pip tools"
      echo "  --go          Go language tools"
      echo "  --ruby        Ruby gem tools"
      echo "  --wordlists   Wordlists & dictionaries"
      echo "  --deps        Core dependencies only"
      echo "  --help        Show this help"
      exit 0 ;;
    *)
      interactive_menu ;;
  esac
}

# ─── DISCLAIMER ──────────────────────────────────────────────────────────────
disclaimer() {
  echo -e "${RED}${BOLD}"
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║             ⚠  LEGAL DISCLAIMER ⚠               ║"
  echo "  ╠══════════════════════════════════════════════════╣"
  echo "  ║  These tools are for AUTHORIZED TESTING ONLY.   ║"
  echo "  ║  Using them against targets you do not have     ║"
  echo "  ║  explicit written permission to test is         ║"
  echo "  ║  ILLEGAL and UNETHICAL. The authors assume      ║"
  echo "  ║  NO responsibility for misuse.                  ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -ne "  ${YELLOW}Do you agree and accept responsibility? [yes/no]: ${RESET}"
  read -r agree
  if [[ ! "$agree" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "\n${RED}Installation aborted.${RESET}\n"
    exit 1
  fi
  echo ""
}

# ─── MAIN ────────────────────────────────────────────────────────────────────
main() {
  banner
  disclaimer
  preflight
  arg_mode "${1:-}"
  print_summary
}

main "$@"
