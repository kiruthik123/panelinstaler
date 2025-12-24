#!/bin/bash

# ==================================================
# KS HOSTING • Professional Installer Menu (v2.0)
# ==================================================

# ---------------- CONFIG & THEME ----------------
BG_CLEAR="\033[2J\033[H"
PRIMARY='\033[38;5;39m'    # Cyan Blue
SECONDARY='\033[38;5;33m'  # Dark Blue
SUCCESS='\033[38;5;82m'    # Green
WARNING='\033[38;5;214m'   # Orange
DANGER='\033[38;5;196m'    # Red
TEXT='\033[38;5;252m'      # Light Gray
RESET='\033[0m'

BASE_REPO="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"
LOG_FILE="/var/log/ks_hosting.log"

# ---------------- INITIAL CHECKS ----------------
if [[ $EUID -ne 0 ]]; then
   echo -e "${DANGER}❌ This script must be run as root.${RESET}" 
   exit 1
fi

# ---------------- UI FUNCTIONS ----------------
ks_banner() {
    echo -e "$BG_CLEAR"
    echo -e "${PRIMARY}╔══════════════════════════════════════════╗${RESET}"
    echo -e "${PRIMARY}║${TEXT}              ☁️  KS HOSTING               ${PRIMARY}║${RESET}"
    echo -e "${PRIMARY}║${SECONDARY}      Secure • Fast • Cloud Platform      ${PRIMARY}║${RESET}"
    echo -e "${PRIMARY}║${TEXT}               BY KS GAMING               ${PRIMARY}║${RESET}"
    echo -e "${PRIMARY}╚══════════════════════════════════════════╝${RESET}"
    echo
}

msg() { echo -e "${PRIMARY}➜${RESET} ${TEXT}$1${RESET}"; }
err() { echo -e "${DANGER}❌ $1${RESET}"; }
success() { echo -e "${SUCCESS}✔ $1${RESET}"; }

loading() {
    local message=${1:-"Processing"}
    echo -ne "${PRIMARY}⏳ $message"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e "${RESET}"
}

# ---------------- LOGGING ----------------
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# ---------------- CORE TOOLS ----------------
install_dependency() {
    if ! command -v "$1" &> /dev/null; then
        loading "Installing $1"
        apt update && apt install "$1" -y >> "$LOG_FILE" 2>&1
    fi
}

# ---------------- SUB-MENUS ----------------
panel_manager() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🧩 PANEL MANAGER${RESET}"
        echo -e "${PRIMARY}1)${TEXT} Pterodactyl Panel${RESET}"
        echo -e "${PRIMARY}2)${TEXT} Skyport Panel${RESET}"
        echo -e "${PRIMARY}3)${TEXT} Airlink Panel${RESET}"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Select option: " p

        case $p in
            1) msg "Installing Pterodactyl..."; bash <(curl -sL https://pterodactyl-installer.se) ;;
            2) msg "Installing Skyport..."; # Add your specific Skyport logic here
               sleep 2 ;;
            0) break ;;
            *) err "Invalid option"; sleep 1 ;;
        esac
    done
}

blueprint_addons() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🧩 BLUEPRINT ADDONS${RESET}"
        echo -e "${PRIMARY}1)${TEXT} 🎨 Euphoria Theme     ${PRIMARY}5)${TEXT} 📜 Player Listing"
        echo -e "${PRIMARY}2)${TEXT} 🧱 Sidebar            ${PRIMARY}6)${TEXT} 🔄 Recolor"
        echo -e "${PRIMARY}3)${TEXT} 🖼️  Backgrounds       ${PRIMARY}7)${TEXT} 🧩 Vanilla Tweaks"
        echo -e "${PRIMARY}4)${TEXT} 🔧 MC Tools           ${PRIMARY}8)${TEXT} 🌐 Subdomains"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Select addon: " ad

        case $ad in
            1) bp="euphoriatheme.blueprint" ;;
            2) bp="sidebar.blueprint" ;;
            3) bp="serverbackgrounds.blueprint" ;;
            4) bp="mctools.blueprint" ;;
            5) bp="playerlisting.blueprint" ;;
            6) bp="recolor.blueprint" ;;
            7) bp="vanillatweaks.blueprint" ;;
            8) bp="subdomains.blueprint" ;;
            0) break ;;
            *) err "Invalid option"; sleep 1; continue ;;
        esac

        read -p "Apply $bp ? (y/n): " c
        if [[ "$c" =~ ^[Yy]$ ]]; then
            loading "Applying $bp"
            curl -fsSL "$BASE_REPO/$bp" | bash | tee -a "$LOG_FILE"
            success "Addon Applied"
            read -p "Press Enter..."
        fi
    done
}

system_tool() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🛠️  SYSTEM TOOLS${RESET}"
        echo -e "${PRIMARY}1)${TEXT} 🌐 Tailscale          ${PRIMARY}5)${TEXT} 🔄 Change SSH Port"
        echo -e "${PRIMARY}2)${TEXT} ☁️  Cloudflare Tunnel  ${PRIMARY}6)${TEXT} 🔒 SSH Password Login"
        echo -e "${PRIMARY}3)${TEXT} 🔑 Enable Root Access  ${PRIMARY}7)${TEXT} ♻️  Restart SSH"
        echo -e "${PRIMARY}4)${TEXT} 🔐 SSHX (tmate)       ${PRIMARY}8)${TEXT} ⬆️  System Update"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Select option: " s

        case $s in
            1) loading; curl -fsSL https://tailscale.com/install.sh | sh; read -p "Enter..." ;;
            2)
                loading "Installing Cloudflared"
                install_dependency "lsb-release"
                mkdir -p /usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare.gpg >/dev/null
                echo "deb [signed-by=/usr/share/keyrings/cloudflare.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list
                apt update && apt install cloudflared -y
                success "Cloudflared Installed"
                read -p "Enter..."
                ;;
            3)
                msg "Setting root password..."
                passwd root
                sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
                systemctl restart ssh
                success "Root access enabled and SSH restarted"
                sleep 2
                ;;
            5)
                read -p "Enter new SSH port: " port
                if [[ $port =~ ^[0-9]+$ ]]; then
                    sed -i "s/^#\?Port .*/Port $port/" /etc/ssh/sshd_config
                    systemctl restart ssh
                    success "Port changed to $port"
                else
                    err "Invalid port number"
                fi
                sleep 2
                ;;
            8)
                loading "Updating System"
                apt update && apt upgrade -y
                success "Update Complete"
                sleep 2
                ;;
            0) break ;;
            *) err "Invalid option"; sleep 1 ;;
        esac
    done
}

# ---------------- MAIN LOOP ----------------
while true; do
    ks_banner
    echo -e "${PRIMARY}1)${TEXT} 🧩 Panel Manager${RESET}"
    echo -e "${PRIMARY}2)${TEXT} 📘 Blueprint Framework${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🛠️  System Tools${RESET}"
    echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
    echo
    read -p "➜ Select option: " main

    case $main in
        1) panel_manager ;;
        2) 
            ks_banner
            echo -e "${PRIMARY}1)${TEXT} Install Blueprint${RESET}"
            echo -e "${PRIMARY}2)${TEXT} Blueprint Addons${RESET}"
            read -p "➜ choice: " bc
            [[ "$bc" == "1" ]] && bash <(curl -fsSL "$BASE_REPO/blueprint-installer.sh")
            [[ "$bc" == "2" ]] && blueprint_addons
            ;;
        3) system_tool ;;
        0)
            ks_banner
            echo -e "${SUCCESS}👋 Thank you for using KS HOSTING!${RESET}"
            log_action "Script exited safely."
            exit 0
            ;;
        *) err "Invalid selection"; sleep 1 ;;
    esac
done
