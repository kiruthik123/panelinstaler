#!/bin/bash

# ==================================================
# KS HOSTING • Professional Installer Menu
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

# Repository Configuration
BASE_REPO="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"
BLUEPRINT_INSTALL_URL="${BASE_REPO}/blueprint-installer.sh"

# ---------------- INITIAL CHECKS ----------------
if [[ $EUID -ne 0 ]]; then
   echo -e "${DANGER}❌ This script must be run as root.${RESET}" 
   exit 1
fi

# ---------------- UI COMPONENTS ----------------
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
# BLUEPRINT ADDONS (Verified from Repository)
# ==================================================
blueprint_addons() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🧩 BLUEPRINT ADDONS${RESET}"
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
            10) bp="votifiertester.blueprint" ;; # Fixed typo from previous version
            11) bp="simplefooters.blueprint" ;;
            12) bp="dbedit.blueprint" ;;
            13) bp="mclogs.blueprint" ;; # Added from your repo upload
            0) break ;;
            *) continue ;;
        esac

        read -p "Apply $bp ? (y/n): " c
        if [[ "$c" =~ ^[Yy]$ ]]; then
            loading
            # Pull the blueprint file and run it
            curl -fsSL "$BASE_REPO/$bp" | bash
            pause
        fi
    done
}

# ==================================================
# MAIN INTERFACE
# ==================================================
blueprint_main() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}📘 BLUEPRINT FRAMEWORK${RESET}"
        echo -e "${PRIMARY}1)${TEXT} 🚀 Install Framework${RESET}"
        echo -e "${PRIMARY}2)${TEXT} 🧩 Manage Addons${RESET}"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        echo
        read -p "➜ Selection: " choice

        case $choice in
            1)
                read -p "Install Blueprint Framework? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    loading
                    bash <(curl -fsSL "$BLUEPRINT_INSTALL_URL")
                    pause
                fi
                ;;
            2) blueprint_addons ;;
            0) break ;;
        esac
    done
}

# Simple system tool placeholder for Menu Option 3
system_tools() {
    ks_banner
    echo -e "${SECONDARY}🛠️  SYSTEM TOOLS${RESET}"
    echo -e "${PRIMARY}1)${TEXT} ⬆️  System Update${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Selection: " s
    if [[ "$s" == "1" ]]; then
        loading
        apt update && apt upgrade -y
        pause
    fi
}

while true; do
    ks_banner
    echo -e "${PRIMARY}1)${TEXT} 🧩 Panel Manager${RESET}"
    echo -e "${PRIMARY}2)${TEXT} 📘 Blueprint${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🛠️  System Tool${RESET}"
    echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
    echo
    read -p "➜ Select option: " main

    case $main in
        1) echo -e "${WARNING}Panel Manager module coming soon...${RESET}"; sleep 1 ;;
        2) blueprint_main ;;
        3) system_tools ;;
        0) echo -e "${SUCCESS}👋 Thank you for using KS HOSTING!${RESET}"; exit 0 ;;
        *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
done
