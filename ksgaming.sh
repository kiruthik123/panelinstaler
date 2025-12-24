#!/bin/bash

# ==================================================
# KS HOSTING • Professional Installer Menu (v2.3)
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

# Repository Pathing
BASE_REPO="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"

# ---------------- INITIAL CHECKS ----------------
if [[ $EUID -ne 0 ]]; then
   echo -e "${DANGER}❌ Error: You must run this script as root (sudo).${RESET}" 
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

loading() {
    echo -ne "${PRIMARY}⏳ Processing"
    for i in {1..3}; do echo -ne "."; sleep 0.3; done
    echo -e "${RESET}"
}

pause() {
    echo -e "\n${SECONDARY}➜ Press [Enter] to return to menu...${RESET}"
    read -r
}

# ==================================================
# BLUEPRINT MODULES
# ==================================================
blueprint_addons() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🧩 BLUEPRINT ADDONS${RESET}"
        # Organized based on your GitHub file list
        echo -e "${PRIMARY} 1)${TEXT} 🎨 Euphoria Theme     ${PRIMARY} 8)${TEXT} 🌐 Subdomains"
        echo -e "${PRIMARY} 2)${TEXT} 🧱 Sidebar            ${PRIMARY} 9)${TEXT} 👤 Player Manager"
        echo -e "${PRIMARY} 3)${TEXT} 🖼️  Backgrounds       ${PRIMARY}10)${TEXT} 🗳️  Votifier Tester"
        echo -e "${PRIMARY} 4)${TEXT} 🔧 MC Tools           ${PRIMARY}11)${TEXT} 🧾 Simple Footers"
        echo -e "${PRIMARY} 5)${TEXT} 📜 Player Listing     ${PRIMARY}12)${TEXT} 🛠️  DB Edit"
        echo -e "${PRIMARY} 6)${TEXT} 🔄 Recolor            ${PRIMARY}13)${TEXT} 📋 MC Logs"
        echo -e "${PRIMARY} 7)${TEXT} 🧩 Vanilla Tweaks     ${DANGER} 0)${TEXT} Back"
        echo
        read -p "➜ Select Addon ID: " ad

        case $ad in
            1) bp="euphoriatheme.blueprint" ;;
            2) bp="sidebar.blueprint" ;;
            3) bp="serverbackgrounds.blueprint" ;;
            4) bp="mctools.blueprint" ;;
            5) bp="playerlisting.blueprint" ;;
            6) bp="recolor.blueprint" ;;
            7) bp="vanillatweaks.blueprint" ;;
            8) bp="subdomains.blueprint" ;;
            9) bp="minecraftplayermanager.blueprint" ;;
            10) bp="votifiertester.blueprint" ;;
            11) bp="simplefooters.blueprint" ;;
            12) bp="dbedit.blueprint" ;;
            13) bp="mclogs.blueprint" ;;
            0) break ;;
            *) continue ;;
        esac

        read -p "Apply $bp ? (y/n): " c
        if [[ "$c" =~ ^[Yy]$ ]]; then
            loading
            # Using raw.githubusercontent path to pull the specific addon file
            curl -fsSL "$BASE_REPO/$bp" | bash
            pause
        fi
    done
}

blueprint_main() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}📘 BLUEPRINT FRAMEWORK${RESET}"
        echo -e "${PRIMARY}1)${TEXT} 🚀 Install Framework${RESET}"
        echo -e "${PRIMARY}2)${TEXT} 🧩 Browse Addons${RESET}"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Selection: " choice

        case $choice in
            1)
                read -p "Confirm Blueprint Framework Installation? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    loading
                    # Direct link provided by you
                    bash <(curl -s https://raw.githubusercontent.com/kiruthik123/panelinstaler/main/blueprint-installer.sh)
                    pause
                fi
                ;;
            2) blueprint_addons ;;
            0) break ;;
        esac
    done
}

# ==================================================
# SYSTEM TOOLS
# ==================================================
system_tool() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🛠️  SYSTEM TOOLS${RESET}"
        echo -e "${PRIMARY}1)${TEXT} 🌐 Install Tailscale      ${PRIMARY}5)${TEXT} 🔄 Change SSH Port"
        echo -e "${PRIMARY}2)${TEXT} ☁️  Cloudflare Tunnel      ${PRIMARY}6)${TEXT} 🔐 SSH Password Login"
        echo -e "${PRIMARY}3)${TEXT} 🔑 Enable Root Access     ${PRIMARY}7)${TEXT} ♻️  Restart SSH"
        echo -e "${PRIMARY}4)${TEXT} 🔐 SSHX (tmate)           ${PRIMARY}8)${TEXT} ⬆️  System Update"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Selection: " s

        case $s in
            1) loading; curl -fsSL https://tailscale.com/install.sh | sh; pause ;;
            2) loading; # Add Cloudflare tunnel setup logic if needed
               pause ;;
            3) loading; passwd root; sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config; systemctl restart ssh; pause ;;
            5) read -p "Enter new SSH port: " p; sed -i "s/^#\?Port .*/Port $p/" /etc/ssh/sshd_config; systemctl restart ssh; pause ;;
            8) loading; apt update && apt upgrade -y; pause ;;
            0) break ;;
        esac
    done
}

# ==================================================
# MAIN LOOP
# ==================================================
while true; do
    ks_banner
    echo -e "${PRIMARY}1)${TEXT} 🧩 Panel Manager${RESET}"
    echo -e "${PRIMARY}2)${TEXT} 📘 Blueprint Framework${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🛠️  System Tool${RESET}"
    echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
    echo
    read -p "➜ Select option: " main

    case $main in
        1) # Placeholder for Panel Installers (Pterodactyl, Skyport, etc)
           echo -e "${WARNING}Panel Manager loading...${RESET}"; sleep 1 ;;
        2) blueprint_main ;;
        3) system_tool ;;
        0) echo -e "${SUCCESS}👋 Thank you for using KS HOSTING!${RESET}"; exit 0 ;;
        *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
done
