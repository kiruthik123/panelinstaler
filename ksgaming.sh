#!/bin/bash

# =========================================================
#   KS HOSTING BY KSGAMING - SUPREME STORE EDITION
#   Connected to: github.com/kiruthik123/panelinstaler
# =========================================================

# --- GITHUB CONFIGURATION ---
GH_USER="kiruthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"

BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"

# --- DIRECTORIES ---
PANEL_DIR="/var/www/pterodactyl"

# --- NEON COLORS ---
NC='\033[0m' 
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PINK='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
GREY='\033[1;90m'
ORANGE='\033[1;38;5;208m'

# --- UI UTILITIES ---
WIDTH=65

draw_bar() { printf "${BLUE}%*s${NC}\n" "$WIDTH" '' | tr ' ' '='; }
draw_sub() { printf "${GREY}%*s${NC}\n" "$WIDTH" '' | tr ' ' '-'; }

print_c() {
    local text="$1"
    local color="${2:-$WHITE}"
    local len=${#text}
    local padding=$(( (WIDTH - len) / 2 ))
    printf "${BLUE}|${NC}%*s${color}%s${NC}%*s${BLUE}|${NC}\n" $padding "" "$text" $((WIDTH - len - padding)) ""
}

print_opt() {
    local num="$1"
    local text="$2"
    local color="${3:-$WHITE}"
    printf "${BLUE}|${NC}  ${CYAN}[${num}]${NC} ${color}%-45s${NC} ${BLUE}|${NC}\n" "$text"
}

# --- STATUS MESSAGES ---
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[DONE]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- HEADER ---
header() {
    clear
    draw_bar
    print_c "KS HOSTING" "$PINK"
    print_c "Repo: $GH_USER/$GH_REPO" "$CYAN"
    draw_bar
    print_c "User: $USER | IP: $(hostname -I | awk '{print $1}')" "$GREY"
    draw_bar
}

# --- INSTALLER LOGIC ---
install_bp() {
    local name="$1"
    local file="$2"
    local url="$BASE_URL/$file"

    header
    print_c "INSTALLING: $name" "$YELLOW"
    draw_sub
    echo ""
    
    # Check Blueprint
    if ! command -v blueprint &> /dev/null; then
        error "Blueprint framework is missing."
        echo -e "${GREY}Please go to Menu 4 -> Option 1 first.${NC}"
        read -p "Press Enter..."
        return
    fi

    # Download
    cd "$PANEL_DIR" || exit
    info "Downloading $file..."
    rm -f "$file"
    wget -q --show-progress "$url" -O "$file"

    if [ ! -f "$file" ]; then
        echo ""
        error "Download Failed!"
        echo -e "${GREY}Could not find '$file' in your repository.${NC}"
        read -p "Press Enter..."
        return
    fi

    # Install
    echo ""
    info "Running Installer..."
    blueprint -install "$file"

    # Finish
    rm -f "$file"
    echo ""
    success "Installation Complete!"
    read -p "Press Enter to continue..."
}

# --- UNINSTALL LOGIC ---
uninstall_addon() {
    header
    print_c "UNINSTALL ADDON" "$RED"
    draw_sub
    echo -e "${YELLOW}Enter the identifier name (e.g. mctools, recolor):${NC}"
    read -p "> " idname
    
    if [ -z "$idname" ]; then error "Cancelled."; sleep 1; return; fi
    
    cd "$PANEL_DIR" || exit
    info "Removing $idname..."
    blueprint -remove "$idname"
    success "Finished."
    read -p "Press Enter..."
}

uninstall_framework() {
    header
    print_c "UNINSTALL FRAMEWORK" "$RED"
    draw_sub
    echo -e "${YELLOW}WARNING: This removes the Blueprint tool.${NC}"
    echo -e "${GREY}To fully revert visual changes, you may need to reinstall Panel files (Menu 1 -> 1).${NC}"
    echo ""
    read -p "Type 'yes' to confirm: " c
    if [ "$c" == "yes" ]; then
        rm -rf /usr/local/bin/blueprint
        rm -rf "$PANEL_DIR/blueprint"
        success "Blueprint removed from system."
    else
        echo "Cancelled."
    fi
    read -p "Press Enter..."
}

# =========================================================
#    MENUS
# =========================================================

menu_addons() {
    while true; do
        header
        print_c "ADDON STORE" "$PINK"
        draw_sub
        
        print_c "-- THEMES --" "$ORANGE"
        print_opt "1" "Recolor Theme"
        print_opt "2" "Sidebar Theme"
        print_opt "3" "Server Backgrounds"
        print_opt "4" "Euphoria Theme" "$GREEN"
        
        print_c "-- UTILITIES --" "$ORANGE"
        print_opt "5" "MC Tools (Editor)"
        print_opt "6" "MC Logs (Live Console)"
        print_opt "7" "Player Listing"
        print_opt "8" "Votifier Tester"
        print_opt "9" "Database Editor" "$GREEN"
        print_opt "10" "Subdomains Manager" "$GREEN"
        
        draw_sub
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select Addon: ${NC}"
        read opt

        case $opt in
            1) install_bp "Recolor" "recolor.blueprint" ;;
            2) install_bp "Sidebar" "sidebar.blueprint" ;;
            3) install_bp "Backgrounds" "serverbackgrounds.blueprint" ;;
            4) install_bp "Euphoria" "euphoriatheme.blueprint" ;;
            5) install_bp "MC Tools" "mctools.blueprint" ;;
            6) install_bp "MC Logs" "mclogs.blueprint" ;;
            7) install_bp "Player List" "playerlisting.blueprint" ;;
            8) install_bp "Votifier" "votifiertester.blueprint" ;;
            9) install_bp "DB Edit" "dbedit.blueprint" ;;
            10) install_bp "Subdomains" "subdomains.blueprint" ;;
            0) return ;;
            *) error "Invalid"; sleep 0.5 ;;
        esac
    done
}

menu_blueprint() {
    while true; do
        header
        print_c "BLUEPRINT SYSTEM" "$CYAN"
        draw_sub
        print_opt "1" "Install Framework (Custom Script)" "$PINK"
        print_opt "2" "Open KS Addon Store" "$GREEN"
        print_opt "3" "Update Framework/Addons"
        print_opt "4" "Toggle Dev Mode (Debug)"
        draw_sub
        print_opt "5" "Uninstall Extension" "$ORANGE"
        print_opt "6" "Uninstall Framework" "$RED"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        
        case $opt in
            1) 
                echo ""
                info "Downloading blueprint-installer.sh..."
                cd "$PANEL_DIR" || exit
                rm -f blueprint-installer.sh
                wget -q --show-progress "$BASE_URL/blueprint-installer.sh" -O blueprint-installer.sh
                
                if [ -f "blueprint-installer.sh" ]; then
                    info "Running Custom Installer..."
                    bash blueprint-installer.sh
                    rm blueprint-installer.sh
                    success "Done."
                else
                    error "File blueprint-installer.sh not found in repo."
                fi
                read -p "Press Enter..."
                ;;
            2) menu_addons ;;
            3) 
                # UPDATED: Now uses 'blueprint -upgrade'
                cd "$PANEL_DIR" && blueprint -upgrade 
                success "Update process finished."
                read -p "Press Enter..." 
                ;;
            4) cd "$PANEL_DIR" && sed -i 's/APP_ENV=production/APP_ENV=local/g' .env; success "Dev Mode Set."; sleep 0.5 ;;
            5) uninstall_addon ;;
            6) uninstall_framework ;;
            0) return ;;
        esac
    done
}

menu_panel() {
    while true; do
        header
        print_c "PANEL MANAGEMENT" "$YELLOW"
        draw_sub
        print_opt "1" "Install Panel (Standard)"
        print_opt "2" "Create Admin User"
        print_opt "3" "Clear Cache (Fix 500 Error)"
        print_opt "4" "Reset Permissions"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) 
                echo -e "${YELLOW}Starting Official Installer...${NC}"
                bash <(curl -s https://pterodactyl-installer.se) --panel
                read -p "Press Enter..."
                ;;
            2) cd "$PANEL_DIR" && php artisan p:user:make; read -p "Press Enter..." ;;
            3) cd "$PANEL_DIR" && php artisan view:clear && php artisan config:clear; success "Cache Cleared."; sleep 0.5 ;;
            4) chown -R www-data:www-data "$PANEL_DIR"/*; success "Permissions Fixed."; sleep 0.5 ;;
            0) return ;;
        esac
    done
}

menu_wings() {
    while true; do
        header
        print_c "WINGS MANAGEMENT" "$YELLOW"
        draw_sub
        print_opt "1" "Install Wings"
        print_opt "2" "Auto-Configure (Paste Token)"
        print_opt "3" "Restart Wings"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) 
                echo -e "${YELLOW}Starting Official Installer...${NC}"
                bash <(curl -s https://pterodactyl-installer.se) --wings
                read -p "Press Enter..."
                ;;
            2) 
                echo ""; echo -e "${YELLOW}Paste Command:${NC}"; read -r CMD; eval "$CMD"; systemctl enable --now wings; success "Started."; sleep 0.5 ;;
            3) systemctl restart wings; success "Wings Restarted."; sleep 0.5 ;;
            0) return ;;
        esac
    done
}

menu_toolbox() {
    while true; do
        header
        print_c "SYSTEM TOOLBOX" "$PINK"
        draw_sub
        print_opt "1" "System Monitor"
        print_opt "2" "Add 2GB RAM Swap"
        print_opt "3" "Network Speedtest"
        print_opt "4" "Auto-Firewall"
        print_opt "5" "Database Backup"
        print_opt "6" "Install SSL (Certbot)"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) header; free -h | grep Mem; df -h / | awk 'NR==2'; read -p "Press Enter..." ;;
            2) fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab; success "Swap Added."; sleep 0.5 ;;
            3) apt-get install speedtest-cli -y -qq; speedtest-cli --simple; read -p "Press Enter..." ;;
            4) apt install ufw -y -qq; ufw allow 22; ufw allow 80; ufw allow 443; ufw allow 8080; ufw allow 2022; yes | ufw enable; success "Firewall Secure."; sleep 0.5 ;;
            5) mysqldump -u root -p pterodactyl > /root/backup_$(date +%F).sql; success "Backup saved to /root/"; read -p "Press Enter..." ;;
            6) apt install certbot -y -qq; echo ""; read -p "Enter Domain: " DOM; certbot certonly --standalone -d $DOM; read -p "Press Enter..." ;;
            0) return ;;
        esac
    done
}

# =========================================================
#    MAIN MENU LOOP
# =========================================================
while true; do
    header
    print_c "MAIN MENU" "$GREEN"
    draw_sub
    print_opt "1" "Panel Manager"
    print_opt "2" "Wings Manager"
    print_opt "3" "Install Both (Hybrid)"
    draw_sub
    print_opt "4" "Blueprint & Addons" "$CYAN"
    print_opt "5" "System Toolbox" "$PINK"
    draw_sub
    print_opt "6" "Uninstall Pterodactyl" "$RED"
    print_opt "0" "Exit" "$GREY"
    draw_bar
    echo -ne "${CYAN}  root@kshosting:~# ${NC}"
    read choice

    case $choice in
        1) menu_panel ;;
        2) menu_wings ;;
        3) 
            echo -e "${YELLOW}Starting Official Installer...${NC}"
            bash <(curl -s https://pterodactyl-installer.se) --panel --wings
            read -p "Press Enter..."
            ;;
        4) menu_blueprint ;;
        5) menu_toolbox ;;
        6) 
            echo ""; echo -e "${RED}WARNING: DELETE ALL DATA?${NC}"; read -p "Type 'yes': " CONF
            if [ "$CONF" == "yes" ]; then rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings; success "Deleted."; fi; sleep 1 ;;
        0) clear; exit 0 ;;
        *) error "Invalid"; sleep 0.5 ;;
    esac
done
