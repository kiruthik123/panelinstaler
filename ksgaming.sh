#!/usr/bin/env bash
# ==================================================
# KS HOSTING • Blueprint System (v2.3)
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
GH_USER="kiruthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
BLUEPRINT_INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main/blueprint-installer.sh"

PANEL_DIR="/var/www/pterodactyl"

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
    echo -e "${PRIMARY}║${TEXT}           📦 Blueprint System            ${PRIMARY}║${RESET}"
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

run_with_progress() {
    local msg="$1"; local cmd="$2"
    echo -e "${PRIMARY}▶${RESET} $msg..."
    set +e
    bash -c "$cmd"
    local EXIT=$?
    set -e
    if [ $EXIT -eq 0 ]; then
        echo -e "${SUCCESS}✓${RESET} $msg completed"
    else
        echo -e "${DANGER}✗${RESET} $msg failed"
    fi
    return $EXIT
}

# ---------------- BLUEPRINT INSTALLATION ----------------
install_bp() {
    local name="$1"; local file="$2"
    local url="$BASE_URL/$file"
    
    ks_banner
    echo -e "${WARNING}📥 INSTALLING: $name${RESET}"
    echo -e "${PRIMARY}══════════════════════════════════════════${RESET}"
    
    if ! command -v blueprint &>/dev/null; then
        echo -e "${DANGER}❌ Blueprint framework not installed. Run Blueprint Install first.${RESET}"
        pause
        return
    fi
    
    mkdir -p "$PANEL_DIR"
    cd "$PANEL_DIR" || return
    
    loading
    run_with_progress "Downloading $file" "wget -q \"$url\" -O \"$file\""
    
    if [ ! -f "$file" ]; then 
        echo -e "${DANGER}❌ Download failed.${RESET}"
        pause
        return
    fi
    
    run_with_progress "Installing $name" "blueprint -install \"$file\""
    rm -f "$file"
    
    echo -e "${SUCCESS}✅ $name installed successfully!${RESET}"
    pause
}

# ---------------- BLUEPRINT ADDONS MENU ----------------
blueprint_addons() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}🧩 BLUEPRINT ADDONS${RESET}"
        
        # Organized in two columns for better view
        echo -e "${PRIMARY} 1)${TEXT} 🎨 Recolor Theme       ${PRIMARY}13)${TEXT} 📝 Console Logs"
        echo -e "${PRIMARY} 2)${TEXT} 🧱 Sidebar Theme        ${PRIMARY}14)${TEXT} 📋 Hux Register"
        echo -e "${PRIMARY} 3)${TEXT} 🖼️  Server Backgrounds   ${PRIMARY}15)${TEXT} 🐛 Laravel Logs"
        echo -e "${PRIMARY} 4)${TEXT} 🌈 Euphoria Theme       ${PRIMARY}16)${TEXT} 📢 LyrDy Announce"
        echo -e "${PRIMARY} 5)${TEXT} ⚒️  MC Tools             ${PRIMARY}17)${TEXT} 📊 MD Logs"
        echo -e "${PRIMARY} 6)${TEXT} 📋 MC Logs              ${PRIMARY}18)${TEXT} 🌐 Modrinth Browser"
        echo -e "${PRIMARY} 7)${TEXT} 👥 Player Listing       ${PRIMARY}19)${TEXT} 🌙 Night Admin"
        echo -e "${PRIMARY} 8)${TEXT} 📊 Votifier Tester      ${PRIMARY}20)${TEXT} 🔔 Resource Alerts"
        echo -e "${PRIMARY} 9)${TEXT} 🗃️  Database Editor      ${PRIMARY}21)${TEXT} 📦 Resource Manager"
        echo -e "${PRIMARY}10)${TEXT} 🌐 Subdomain Manager    ${PRIMARY}22)${TEXT} 🆔 Show Node IDs"
        echo -e "${PRIMARY}11)${TEXT} 🧹 Activity Purges      ${PRIMARY}23)${TEXT} 👣 Simple Footers"
        echo -e "${PRIMARY}12)${TEXT} 🧪 Vanilla Tweaks       ${PRIMARY}24)${TEXT} 🌍 Translations"
        echo -e "                                      ${PRIMARY}25)${TEXT} ⬇️  URL Downloader"
        
        echo -e "${DANGER} 0)${TEXT} Back${RESET}"
        echo
        read -p "${SECONDARY}➜${RESET} Select Addon ID: " ad

        case $ad in
            1) install_bp "Recolor Theme" "recolor.blueprint" ;;
            2) install_bp "Sidebar Theme" "sidebar.blueprint" ;;
            3) install_bp "Server Backgrounds" "serverbackgrounds.blueprint" ;;
            4) install_bp "Euphoria Theme" "euphoriatheme.blueprint" ;;
            5) install_bp "MC Tools" "mctools.blueprint" ;;
            6) install_bp "MC Logs" "mclogs.blueprint" ;;
            7) install_bp "Player Listing" "playerlisting.blueprint" ;;
            8) install_bp "Votifier Tester" "votifiertester.blueprint" ;;
            9) install_bp "Database Editor" "dbedit.blueprint" ;;
            10) install_bp "Subdomain Manager" "subdomains.blueprint" ;;
            11) install_bp "Activity Purges" "activitypurges.blueprint" ;;
            12) install_bp "Vanilla Tweaks" "vanillatweaks.blueprint" ;;
            13) install_bp "Console Logs" "console.logs.blueprint" ;;
            14) install_bp "Hux Register" "huxregister.blueprint" ;;
            15) install_bp "Laravel Logs" "laravellogs.blueprint" ;;
            16) install_bp "LyrDy Announce" "lyrdyannounce.blueprint" ;;
            17) install_bp "MD Logs" "mdlogs.blueprint" ;;
            18) install_bp "Modrinth Browser" "modrinthbrowser.blueprint" ;;
            19) install_bp "Night Admin" "nightadmin.blueprint" ;;
            20) install_bp "Resource Alerts" "resourcealerts.blueprint" ;;
            21) install_bp "Resource Manager" "resourcemanager.blueprint" ;;
            22) install_bp "Show Node IDs" "shownodeids.blueprint" ;;
            23) install_bp "Simple Footers" "simplefooters.blueprint" ;;
            24) install_bp "Translations" "translations.blueprint" ;;
            25) install_bp "URL Downloader" "urldownloader.blueprint" ;;
            0) break ;;
            *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
        esac
    done
}

# ---------------- UNINSTALL MENU ----------------
uninstall_addon() {
    while true; do
        ks_banner
        echo -e "${DANGER}🗑️  UNINSTALL ADDON${RESET}"
        echo -e "${PRIMARY}══════════════════════════════════════════${RESET}"
        
        echo -e "${TEXT}Select addon to uninstall:${RESET}"
        echo -e "${PRIMARY} 1)${TEXT} Recolor Theme       ${PRIMARY}14)${TEXT} Laravel Logs"
        echo -e "${PRIMARY} 2)${TEXT} Sidebar Theme        ${PRIMARY}15)${TEXT} LyrDy Announce"
        echo -e "${PRIMARY} 3)${TEXT} Server Backgrounds   ${PRIMARY}16)${TEXT} MD Logs"
        echo -e "${PRIMARY} 4)${TEXT} Euphoria Theme       ${PRIMARY}17)${TEXT} Modrinth Browser"
        echo -e "${PRIMARY} 5)${TEXT} MC Tools             ${PRIMARY}18)${TEXT} Night Admin"
        echo -e "${PRIMARY} 6)${TEXT} MC Logs              ${PRIMARY}19)${TEXT} Resource Alerts"
        echo -e "${PRIMARY} 7)${TEXT} Player Listing       ${PRIMARY}20)${TEXT} Resource Manager"
        echo -e "${PRIMARY} 8)${TEXT} Votifier Tester      ${PRIMARY}21)${TEXT} Show Node IDs"
        echo -e "${PRIMARY} 9)${TEXT} Database Editor      ${PRIMARY}22)${TEXT} Simple Footers"
        echo -e "${PRIMARY}10)${TEXT} Subdomain Manager    ${PRIMARY}23)${TEXT} Translations"
        echo -e "${PRIMARY}11)${TEXT} Activity Purges      ${PRIMARY}24)${TEXT} URL Downloader"
        echo -e "${PRIMARY}12)${TEXT} Console Logs         ${PRIMARY}25)${TEXT} Vanilla Tweaks"
        echo -e "${PRIMARY}13)${TEXT} Hux Register"
        
        echo -e "${WARNING} M)${TEXT} Manual ID"
        echo -e "${DANGER} 0)${TEXT} Back${RESET}"
        echo
        read -p "${SECONDARY}➜${RESET} Select: " rm_opt

        case $rm_opt in
            1) id="recolor" ;;
            2) id="sidebar" ;;
            3) id="serverbackgrounds" ;;
            4) id="euphoria" ;;
            5) id="mctools" ;;
            6) id="mclogs" ;;
            7) id="playerlisting" ;;
            8) id="votifiertester" ;;
            9) id="dbedit" ;;
            10) id="subdomains" ;;
            11) id="activitypurges" ;;
            12) id="consolelogs" ;;
            13) id="huxregister" ;;
            14) id="laravellogs" ;;
            15) id="lyrdyannounce" ;;
            16) id="mdlogs" ;;
            17) id="modrinthbrowser" ;;
            18) id="nightadmin" ;;
            19) id="resourcealerts" ;;
            20) id="resourcemanager" ;;
            21) id="shownodeids" ;;
            22) id="simplefooters" ;;
            23) id="translations" ;;
            24) id="urldownloader" ;;
            25) id="vanillatweaks" ;;
            M|m) read -p "Enter addon ID: " id ;;
            0) return ;;
            *) echo -e "${DANGER}❌ Invalid option${RESET}"; continue ;;
        esac
        
        loading
        cd "$PANEL_DIR" || continue
        run_with_progress "Removing $id" "blueprint -remove \"$id\""
        echo -e "${SUCCESS}✅ $id removed successfully!${RESET}"
        pause
        return
    done
}

# ---------------- UNINSTALL FRAMEWORK ----------------
uninstall_framework() {
    ks_banner
    echo -e "${DANGER}⚠️  UNINSTALL BLUEPRINT FRAMEWORK${RESET}"
    echo -e "${PRIMARY}══════════════════════════════════════════${RESET}"
    
    echo -e "${WARNING}⚠️  This will remove Blueprint framework completely!${RESET}"
    read -p "${SECONDARY}➜${RESET} Type 'yes' to confirm: " c
    
    if [[ "$c" == "yes" ]]; then
        loading
        run_with_progress "Removing blueprint" "rm -rf /usr/local/bin/blueprint \"$PANEL_DIR/blueprint\""
        echo -e "${WARNING}🗑️ Blueprint framework removed!${RESET}"
    else 
        echo -e "${TEXT}Cancelled.${RESET}"
    fi
    pause
}

# ---------------- BLUEPRINT MAIN MENU ----------------
blueprint_main() {
    while true; do
        ks_banner
        echo -e "${SECONDARY}📘 BLUEPRINT FRAMEWORK${RESET}"
        
        echo -e "${PRIMARY}1)${TEXT} 🚀 Install Framework${RESET}"
        echo -e "${PRIMARY}2)${TEXT} 🧩 Browse & Install Addons${RESET}"
        echo -e "${PRIMARY}3)${TEXT} 🔄 Update All Extensions${RESET}"
        echo -e "${PRIMARY}4)${TEXT} 🔧 Toggle Dev Mode${RESET}"
        echo -e "${PRIMARY}5)${TEXT} 🗑️  Uninstall Addon${RESET}"
        echo -e "${PRIMARY}6)${TEXT} ⚠️  Uninstall Framework${RESET}"
        echo -e "${DANGER}0)${TEXT} Back${RESET}"
        
        echo
        read -p "${SECONDARY}➜${RESET} Selection: " choice

        case $choice in
            1)
                ks_banner
                echo -e "${SUCCESS}🚀 BLUEPRINT FRAMEWORK INSTALLATION${RESET}"
                echo -e "${PRIMARY}══════════════════════════════════════════${RESET}"
                
                read -p "${SECONDARY}➜${RESET} Confirm installation? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    loading
                    mkdir -p "$PANEL_DIR"
                    cd "$PANEL_DIR" || continue
                    run_with_progress "Downloading installer" "wget -q \"$BLUEPRINT_INSTALLER_URL\" -O blueprint-installer.sh"
                    
                    if [ -f blueprint-installer.sh ]; then
                        run_with_progress "Running installer" "bash blueprint-installer.sh"
                        rm -f blueprint-installer.sh
                        echo -e "${SUCCESS}✅ Framework installed successfully!${RESET}"
                    else 
                        echo -e "${DANGER}❌ Installer not found!${RESET}"
                    fi
                fi
                pause
                ;;
            
            2) blueprint_addons ;;
            
            3)
                loading
                cd "$PANEL_DIR" || continue
                run_with_progress "Upgrading extensions" "blueprint -upgrade"
                echo -e "${SUCCESS}✅ All extensions updated!${RESET}"
                pause
                ;;
            
            4)
                if [ -f "$PANEL_DIR/.env" ]; then
                    loading
                    run_with_progress "Setting dev mode" "sed -i 's/APP_ENV=production/APP_ENV=local/g' \"$PANEL_DIR/.env\""
                    echo -e "${SUCCESS}✅ Dev mode enabled!${RESET}"
                else 
                    echo -e "${DANGER}❌ .env file not found!${RESET}"
                fi
                pause
                ;;
            
            5) uninstall_addon ;;
            6) uninstall_framework ;;
            0) break ;;
            
            *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
        esac
    done
}

# ---------------- MAIN LOOP ----------------
while true; do
    ks_banner
    echo -e "${PRIMARY}1)${TEXT} 📘 Blueprint Framework${RESET}"
    echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
    echo
    read -p "${SECONDARY}➜${RESET} Select option: " main

    case $main in
        1) blueprint_main ;;
        0) 
            ks_banner
            echo -e "${SUCCESS}👋 Thank you for using KS HOSTING!${RESET}"
            echo -e "${TEXT}Blueprint System - Secure • Fast • Cloud Platform${RESET}"
            echo
            exit 0 
            ;;
        *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
done
