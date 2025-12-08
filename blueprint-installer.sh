#!/bin/bash
#=========================================================
#   🚀 KS HOSTING BLUEPRINT INSTALLER (Ultimate Edition)
#      Compatible with Debian/Ubuntu + Pterodactyl
#      Powered by KSGAMING
#=========================================================

set -o errexit
set -o pipefail
set -o nounset

#============ 🎨 NEON COLOR PALETTE ============#
RESET="\e[0m"
BOLD="\e[1m"
UNDERLINE="\e[4m"

# Text Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

# Bright/Neon Colors
NEON_BLUE="\e[94m"
NEON_GREEN="\e[92m"
NEON_CYAN="\e[96m"
NEON_MAGENTA="\e[95m"

# Backgrounds
BG_RED="\e[41m"
BG_BLUE="\e[44m"

clear

#============ ⚔️ KS HOSTING BANNER ⚔️ ============#
echo -e "${NEON_BLUE}${BOLD}"
cat << "EOF"
  _  __  _____      _    _  ____   _____ _______ _____ _   _  _____ 
 | |/ / / ____|    | |  | |/ __ \ / ____|__   __|_   _| \ | |/ ____|
 | ' / | (___      | |__| | |  | | (___    | |    | | |  \| | |  __ 
 |  <   \___ \     |  __  | |  | |\___ \   | |    | | | . ` | | |_ |
 | . \  ____) |    | |  | | |__| |____) |  | |   _| |_| |\  | |__| |
 |_|\_\|_____/     |_|  |_|\____/|_____/   |_|  |_____|_| \_|\_____|
                                                                    
      💻  PREMIUM PTERODACTYL SOLUTIONS  |  BY KSGAMING  🎮
EOF
echo -e "${RESET}"

echo -e "${BG_BLUE}${WHITE}${BOLD}  :: SYSTEM INITIALIZED :: KS HOSTING INSTALLER V2.0  ${RESET}"
echo

#============ 📝 LOGGING SETUP ============#
LOG_FILE="/var/log/kshosting-blueprint.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

#============ 🎬 VISUAL FUNCTIONS ============#
print_header() {
    echo -e "\n${NEON_MAGENTA}${BOLD}┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${NEON_MAGENTA}${BOLD}│ ⚡ STEP: $1 ${RESET}"
    echo -e "${NEON_MAGENTA}${BOLD}└──────────────────────────────────────────────┘${RESET}"
}

print_status() {
    echo -e "${NEON_CYAN}  ➤ ${RESET} $1..."
    sleep 0.5
}

print_success() {
    echo -e "${NEON_GREEN}  ✔ SUCCESS:${RESET} $1"
}

fail() {
    echo -e "\n${BG_RED}${WHITE}${BOLD} ❌ CRITICAL ERROR ❌ ${RESET}"
    echo -e "${RED}  Error Details: $1${RESET}"
    log "CRITICAL ERROR: $1"
    exit 1
}

#============ 🛡️ PRE-CHECKS ============#
check_privileges() {
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        fail "This script requires sudo privileges. Run as root or with sudo."
    fi
}

check_already_installed() {
    if [[ -f "/var/www/pterodactyl/.blueprint-installed" ]]; then
        echo -e "${YELLOW}⚠️  KS Hosting System detected a previous installation.${RESET}"
        read -p "   Do you want to FORCE reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${NEON_GREEN}   Action Cancelled. Have a nice day!${RESET}"
            exit 0
        fi
    fi
}

require() {
    if ! command -v "$1" >/dev/null 2>&1; then
        fail "Required command not found: $1"
    fi
}

install_if_missing() {
    local pkg="$1"
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        print_status "Installing missing package: $pkg"
        sudo apt install -y "$pkg" >/dev/null 2>&1 || fail "Failed to install $pkg"
        print_success "Installed $pkg"
    fi
}

#============ 🚀 MAIN EXECUTION ============#
main() {
    log "Starting KS HOSTING Blueprint Installation"
    
    # 1. Checks
    check_privileges
    check_already_installed

    # 2. System Prep
    print_header "SYSTEM PREPARATION"
    print_status "Verifying internet connectivity"
    require curl
    require wget
    require git
    
    print_status "Updating KS Hosting repositories"
    sudo apt update -y >/dev/null 2>&1 || fail "Apt update failed"
    sudo apt upgrade -y >/dev/null 2>&1 || fail "Apt upgrade failed"
    print_success "System packages updated"

    print_status "Installing core dependencies"
    for pkg in curl wget unzip git zip ca-certificates gnupg lsb-release; do
        install_if_missing "$pkg"
    done

    # 3. Pterodactyl Check
    if [[ ! -d "/var/www/pterodactyl" ]]; then
        fail "Pterodactyl directory not found! Is the panel installed?"
    fi
    cd /var/www/pterodactyl || fail "Cannot access /var/www/pterodactyl"

    # 4. Download Blueprint
    print_header "DOWNLOADING BLUEPRINT FRAMEWORK"
    print_status "Fetching latest release from GitHub"
    
    LATEST_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
        | grep '"browser_download_url"' \
        | grep ".zip" \
        | head -n 1 \
        | cut -d '"' -f 4)

    [[ -z "$LATEST_URL" ]] && fail "Could not retrieve download URL"

    print_status "Downloading Blueprint Archive"
    wget -q "$LATEST_URL" -O blueprint.zip || fail "Download failed"
    
    print_status "Extracting files"
    unzip -oq blueprint.zip || fail "Extraction failed"
    rm -f blueprint.zip
    print_success "Blueprint files extracted"

    # 5. Node.js Setup
    print_header "CONFIGURING NODE.JS ENVIRONMENT"
    if ! command -v node >/dev/null 2>&1 || ! node --version | grep -q "v20"; then
        print_status "Installing Node.js 20 (LTS)"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1
        sudo apt install -y nodejs >/dev/null 2>&1 || fail "Node.js install failed"
        print_success "Node.js 20 installed"
    else
        print_success "Node.js 20 is already active"
    fi

    # 6. Yarn Setup
    print_header "CONFIGURING YARN PACKAGE MANAGER"
    if ! command -v yarn >/dev/null 2>&1; then
        print_status "Enabling Corepack for Yarn"
        sudo npm install -g corepack >/dev/null 2>&1
        sudo corepack enable >/dev/null 2>&1
        print_success "Yarn enabled"
    else
        print_success "Yarn is already active"
    fi

    # 7. Install Dependencies
    print_header "INSTALLING FRONTEND ASSETS"
    print_status "Running yarn install (This may take a moment)"
    yarn install --production=false >/dev/null 2>&1 || fail "Yarn install failed"
    print_success "Frontend dependencies locked and loaded"

    # 8. Blueprint Config
    print_header "APPLYING CONFIGURATIONS"
    if [[ ! -f "/var/www/pterodactyl/.blueprintrc" ]]; then
        print_status "Generating .blueprintrc"
        cat <<EOF | sudo tee /var/www/pterodactyl/.blueprintrc >/dev/null
WEBUSER="www-data"
OWNERSHIP="www-data:www-data"
USERSHELL="/bin/bash"
EOF
        print_success "Configuration file created"
    else
        print_success "Configuration file exists, skipping..."
    fi

    # 9. Final Installation
    print_header "FINALIZING INSTALLATION"
    if [[ ! -f "/var/www/pterodactyl/blueprint.sh" ]]; then
        fail "blueprint.sh not found in root directory!"
    fi

    print_status "Setting permissions"
    sudo chmod +x /var/www/pterodactyl/blueprint.sh
    
    print_status "Executing Blueprint Internal Installer"
    sudo bash /var/www/pterodactyl/blueprint.sh || fail "Internal installer script failed"

    # 10. Mark & Finish
    sudo touch /var/www/pterodactyl/.blueprint-installed
    
    echo
    echo -e "${NEON_GREEN}${BOLD}======================================================${RESET}"
    echo -e "${NEON_GREEN}${BOLD}   🎉  KS HOSTING INSTALLATION COMPLETE  🎉${RESET}"
    echo -e "${NEON_GREEN}${BOLD}======================================================${RESET}"
    echo
    echo -e "${CYAN}🔧  MAINTENANCE COMMANDS:${RESET}"
    echo -e "   ${YELLOW}▶ Clear Cache:${RESET}   sudo php artisan cache:clear"
    echo -e "   ${YELLOW}▶ Restart Queue:${RESET} sudo php artisan queue:restart"
    echo
    echo -e "${NEON_BLUE}Thank you for choosing KS HOSTING by KSGAMING.${RESET}"
    echo -e "${NEON_BLUE}Installation Log:${RESET} $LOG_FILE"
    echo
}

# Run main function
main "$@"
