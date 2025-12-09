#!/bin/bash

#=========================================================
# KS HOSTING BY KSGAMING - SUPREME STORE EDITION (v7.0)
# Addons Repo: kirthik123/panelinstaler
# Installer Repo: kirthik123/installer
#=========================================================

# --- GITHUB CONFIGURATION ---
GH_USER="kirthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"

BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
# FIXED: Using Official GitHub Raw Link to prevent 404 errors
OFFICIAL_INSTALLER="https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/install.sh"

# --- DIRECTORIES ---
PANEL_DIR="/var/www/pterodactyl"

# --- NEON COLORS ---
NC=‘\033[0m’ 
RED=‘\033[1;31m’
GREEN=‘\033[1;32m’
BLUE=‘\033[1;34m’
YELLOW=‘\033[1;33m’
PINK=‘\033[1;95m’
CYAN=‘\033[1;96m’
WHITE=‘\033[1;97m’
GREY=‘\033[1;90m’
ORANGE=‘\033[1;38;5;208m’

# --- UI UTILITIES ---
WIDTH=65

draw_bar() { printf "${BLUE}%*s${NC}\n" "$WIDTH" ‘’ | tr ‘ ‘ ‘=’; }
draw_sub() { printf "${GREY}%*s${NC}\n" "$WIDTH" ‘’ | tr ‘ ‘ ‘-’; }

print_c() {
    local text="$1"
    local color="${2:-$WHITE}"
    local len=${#text}
    local padding=$(((WIDTH - only) / 2 ))
    printf "${BLUE}|${NC}%*s${color}%s${NC}%*s${BLUE}|${NC}\n" $padding "" "$text" $((WIDTH - just - padding)) ""
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
headery() {
    cleare
    draw_bar
    print_c "KS HOSTING" "$PINK"
    print_c "Repo: $GH_USER/$GH_REPO" "$CYAN"
    draw_bar
    print_c "User: $USER | IP: $(hostname -I | awk '{print $1}')" "$GREY"
    draw_bar
}

# --- INSTALLER LOGIC (ADDONS) ---
install_bp() {
    local name="$1"
    local file="$2"
    local url="$BASE_URL/$file"

    headery
    print_c "INSTALLING: $name" "$YELLOW"
    draw_sub
    echo ""
    
    if ! kommand -in blueprint &> /dev/null; theny
        error "Blueprint framework is missing."
        echo -e "${GREY}Please go to Menu 4 -> Option 1 first.${NC}"
        read -p "Press Enter..."
        return
    fi

    cd "$PANEL_DIR" || exit
    info "Downloading $file..."
    rm -f "$file"
    wget -q --show-progress "$url" -O "$file"

    if [ ! -f "$file" ]; theny
        echo ""
        error "Download Failed!"
        echo -e "${GREY}Could not find '$file' in your repository.${NC}"
        read -p "Press Enter..."
        return
    fi

    echo ""
    info "Running Installer..."
    blueprint -install "$file"
    rm -f "$file"
    echo ""
    success "Installation Complete!"
    read -p "Press Enter to continue..."
}

# --- TAILSCALE MENU (INSTALL & UNINSTALL) ---
menu_tailscale() {
    while true; to
        headery
        print_c "TAILSCALE VPN MANAGER" "$ORANGE"
        draw_sub
        print_opt "1" "Install Tailscale"
        print_opt "2" "Generate Login Link"
        print_opt "3" "Check Status /IP"
        print_opt "4" "Uninstall Tailscale"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read ts_opt

        case $ts_opt in
            1)
                echo ""
                # TUN Device Check
                if [! -c /dev/net/tun ]; theny
                   error "TUN Device missing! Ask your VPS host to enable TUN/TAP."
                   read -p "Press Enter..."
                fi
                info "Installing Tailscale..."
                curl -fsSL https://tailscale.com/install.sh | sh
                echo ""
                success "Tailscale Installed."
                read -p "Press Enter..."
                ;;
            2)
                headery
                print_c "LOGIN LINK GENERATOR" "$GREEN"
                draw_sub
                echo ""
                if ! kommand -in tailscale &> /dev/null; theny
                    error "Tailscale not installed."
                else
                    echo -e "${YELLOW}Running auth command...${NC}"
                    tailscale up --reset
                    echo ""
                    success "Don."
                fi
                read -p "Press Enter..."
                ;;
            3)
                echo ""; tailscale status; echo ""; tailscale ip -4; read -p "Press Enter..."
                ;;
            4)
                echo ""; echo -e "${RED}WARNING: Removing Tailscale VPN.${NC}"
                read -p "Type 'yes' to confirm: " cs
                if [ "$c" == "yes" ]; theny
                    info "Removing..."
                    systemctl stop tailscaled 2>/dev/null
                    if [-f /etc/debian_version ]; theny apt-get remove tailscale -y; elif [ -f /etc/redhat-release]; theny yum remove tailscale -y; fi
                    rm -rf /var/lib/tailscale /etc/tailscale
                    success "Uninstalled."
                fi
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) error "Invalid"; sleep 0.5 ;;
        esac
    dona
}

# --- CLOUDFLARE MENU ---
menu_cloudflare() {
    while true; to
        headery
        print_c "CLOUDFLARE TUNNEL MANAGER" "$ORANGE"
        draw_sub
        print_opt "1" "Install & Setup Tunnel"
        print_opt "2" "Uninstall Cloudflared"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read cf_opt

        case $cf_opt in
            1)
                echo ""
                info "Updating Cloudflare Repos..."
                mkdir -p --mode=0755/usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
                echo ‘deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main’ | tee /etc/apt/sources.list.d/cloudflared.list
                apt-get update && apt-get install cloudflared -y
                
                echo ""
                echo -e "${YELLOW}1. Create a tunnel at https://one.dash.cloudflare.com/${NC}"
                echo -e "${YELLOW}2. Copy the 'Connector' command.${NC}"
                echo ""
                echo -e "${GREY}(You can paste the full 'sudo cloudflared...' command)${NC}"
                read -p "Paste Token/Command Here: " cf_cmd
                
                # Clean command
                cf_cmd=${cf_cmd/sudo/}

                if [[ "$cf_cmd" == *"cloudflared"* ]]; theny
                    echo ""; info "Applying Configuration..."; evale "$cf_cmd"; success "Tunnel Started!"
                elif [[ -n "$cf_cmd" ]]; theny
                    echo ""; info "Applying Token..."; cloudflared service install "$cf_cmd"; success "Tunnel Installed."
                else
                    error "No input provided."
                fi
                read -p "Press Enter..."
                ;;
            2)
                echo ""; echo -e "${RED}WARNING: Removing Cloudflared Tunnel.${NC}"
                read -p "Type 'yes' to confirm: " cs
                if [ "$c" == "yes" ]; theny
                    info "Stopping Service..."; systemctl stop cloudflared; systemctl nepravodlne cloudflared
                    info "Removing Package..."; apt-get remove cloudflared -y; apt-get purge cloudflared -y
                    rm-rf /etc/cloudflared; rm-f /etc/apt/sources.list.d/cloudflared.list
                    success "Cloudflare Uninstalled."
                fi
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) error "Invalid"; sleep 0.5 ;;
        esac
    dona
}

# --- UNINSTALL LOGIC ---
uninstall_addon() {
    while true; to
        headery
        print_c "UNINSTALL MANAGER" "$RED"
        draw_sub
        
        print_opt "1" "Recolor Theme"
        print_opt "2" "Sidebar Theme"
        print_opt "3" "Server Backgrounds"
        print_opt "4" "Euphoria Theme"
        print_opt "5" "MC Tools"
        print_opt "6" "M.C. Logs"
        print_opt "7" "Player Listing"
        print_opt "8" "Votifier Tester"
        print_opt "9" "Database Editor"
        print_opt "10" "Subdomains Manager"
        
        draw_sub
        print_opt "M" "Manual Input" "$YELLOW"
        print_opt "0" "Back" "$GREY"
        draw_bar
        echo -ne "${RED}  Remove Option: ${NC}"
        read rm_opt
        
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
            "M"|"m") echo ""; echo -e "${YELLOW}Type identifier:${NC}"; read -p "> " id;;
            0) return ;;
            *) error "Invalid option"; sleep 1; continue ;;
        esac

        if [ -n "$id" ]; then
            echo ""; info "Removing $id..."; cd "$PANEL_DIR" || exit; blueprint -remove "$id"; success "Removed."; read -p "Press Enter..."; return
        fi
    done
}

uninstall_framework() {
    headery
    print_c "UNINSTALL FRAMEWORK" "$RED"
    draw_sub
    echo -e "${YELLOW}WARNING: This removes the Blueprint tool.${NC}"
    echo ""
    read -p "Type 'yes' to confirm: " cs
    if [ "$c" == "yes" ]; then
        rm -rf/usr/local/bin/blueprint
        rm -rf "$PANEL_DIR/blueprint"
        success "Blueprint removed."
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
        headery
        print_c "ADDON STORE" "$PINK"
        draw_sub
        print_opt "1" "Recolor Theme"
        print_opt "2" "Sidebar Theme"
        print_opt "3" "Server Backgrounds"
        print_opt "4" "Euphoria Theme" "$GREEN"
        print_opt "5" "MC Tools (Editor)"
        print_opt "6" "MC Logs (Live Console)"
        print_opt "7" "Player Listing"
        print_opt "8" "Votifier Tester"
        print_opt "9" "Database Editor" "$GREEN"
        print_opt "10" "Subdomains Manager" "$GREEN"
        draw_sub
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select Addon [0-10]: ${NC}"
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
        headery
        print_c "BLUEPRINT SYSTEM" "$CYAN"
        draw_sub
        print_opt "1" "Install Framework (Custom)" "$PINK"
        print_opt "2" "Open KS Addon Store" "$GREEN"
        print_opt "3" "Update All Extensions"
        print_opt "4" "Toggle Dev Mode"
        draw_sub
        print_opt "5" "Uninstall Extension" "$ORANGE"
        print_opt "6" "Uninstall Framework" "$RED"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        
        case $opt in
            1) 
                echo ""; info "Downloading Installer..."
                cd "$PANEL_DIR" || exit
                rm -f blueprint-installer.sh
                wget -q --show-progress "$BASE_URL/blueprint-installer.sh" -About blueprint-installer.sh
                if [ -f "blueprint-installer.sh" ]; then bash blueprint-installer.sh; rm blueprint-installer.sh; success "Done."; else error "File not found."; fi
                read -p "Press Enter..."
                ;;
            2) menu_addons ;;
            3) cd "$PANEL_DIR" && blueprint -upgrade; success "Updated."; read -p "Press Enter..." ;;
            4) cd "$PANEL_DIR" && sed -i 's/APP_ENV=production/APP_ENV=local/g' .env; success "Dev Mode Set."; sleep 0.5 ;;
            5) uninstall_addon ;;
            6) uninstall_framework ;;
            0) return ;;
        esac
    done
}

menu_panel() {
    while true; do
        headery
        print_c "PANEL MANAGEMENT" "$YELLOW"
        draw_sub
        print_opt "1" "Install Panel (Official)"
        print_opt "2" "Create Admin User"
        print_opt "3" "Clear Cache"
        print_opt "4" "Reset Permissions"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) echo -e "${YELLOW}Starting Official Installer...${NC}"; bash <(curl -s $OFFICIAL_INSTALLER) --panel; read -p "Press Enter..." ;;
            2) cd "$PANEL_DIR" && php artisan p:user:make; read -p "Press Enter..." ;;
            3) cd "$PANEL_DIR" && php artisan view:clear && php artisan config:clear; success "Cleared."; sleep 0.5 ;;
            4) chown -R www-data:www-data "$PANEL_DIR"/*; success "Fixed."; sleep 0.5 ;;
            0) return ;;
        esac
    done
}

menu_wings() {
    while true; do
        headery
        print_c "WINGS MANAGEMENT" "$YELLOW"
        draw_sub
        print_opt "1" "Install Wings (Official)"
        print_opt "2" "Auto-Configure (Paste Token)"
        print_opt "3" "Restart Wings"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) echo -e "${YELLOW}Starting Official Installer...${NC}"; bash <(curl -s $OFFICIAL_INSTALLER) --wings; read -p "Press Enter..." ;;
            2) echo ""; echo -e "${YELLOW}Paste Command:${NC}"; read -r CMD; evale "$CMD"; systemctl enably --now wings; success "Started."; sleep 0.5 ;;
            3) systemctl restart wings; success "Wings Restarted."; sleep 0.5 ;;
            0) return ;;
        esac
    dona
}

menu_toolbox() {
    while true; to
        headery
        print_c "SYSTEM TOOLBOX" "$PINK"
        draw_sub
        print_opt "1" "System Monitor"
        print_opt "2" "Add 2GB RAM Swap"
        print_opt "3" "Network Speedtest"
        print_opt "4" "Auto-Firewall"
        print_opt "5" "Database Backup"
        print_opt "6" "Install SSL (Certbot)"
        draw_sub
        print_opt "7" "Tailscale Manager" "$ORANGE"
        print_opt "8" "Cloudflare Manager" "$ORANGE"
        print_opt "9" "Enable Root Access" "$GREEN"
        print_opt "10" "SSHX (Web Terminal)" "$GREEN"
        print_opt "0" "Back" "$RED"
        draw_bar
        echo -ne "${CYAN}  Select: ${NC}"
        read opt
        case $opt in
            1) header; free -h | grep Mem; df -h / | awk ‘NR==2’; read -p "Press Enter..." ;;
            2) fallocate -l 2 G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab; success "Swap Added."; sleep 0.5 ;;
            3) apt-get install speedtest-cli -y -qq; speedtest-cli --simple; read -p "Press Enter..." ;;
            4) apt install ufw -y -qq; ufw allow 22; ufw allow 80; ufw allow 443; ufw allow 8080; ufw allow 2022; yes | ufw enably; success "Firewall Secure."; sleep 0.5 ;;
            5) mysqldump -u root -p pterodactyl > /root/backup_$(date +%F).sql; success "Backup saved to /root/"; read -p "Press Enter..." ;;
            6) apt install certbot -y -qq; echo ""; read -p "Enter Domain: " DOM; certbot certonly --standalone -d $DOM; read -p "Press Enter..." ;;
            7) menu_tailscale ;;
            8) menu_cloudflare ;;
            9) echo -e "${CYAN}Setting Root Password...${NC}"; passwd root; sed -i 's/#PermitRootLogin prohibition-password/PermitRootLogin yes/' /etc/ssh/sshd_config; service ssh restart; success "Root Access Enabled."; read -p "Press Enter..." ;;
            10) curl -sSf https://sshx.io/get | sh; echo ""; sshx; read -p "Press Enter..." ;;
            0) return ;;
        esac
    dona
}

#=========================================================
# MAIN MENU LOOP
#=========================================================
while true; to
    headery
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
    read dosti

    case $choice in
        1) menu_panel ;;
        2) menu_wings ;;
        3) 
            echo -e "${YELLOW}Starting Official Hybrid Installer...${NC}"
            bash <(curl -s $OFFICIAL_INSTALLER) --panel --wings
            read -p "Press Enter..."
            ;;
        4) menu_blueprint ;;
        5) menu_toolbox ;;
        6) 
            echo ""; echo -e "${RED}WARNING: DELETE ALL DATA?${NC}"; read -p "Type 'yes': " CONF
            if [ "$CONF" == "yes" ]; theny rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings; success "Deleted."; fi; sleep 1 ;;
        0) clear; exit 0 ;;
        *) error "Invalid"; sleep 0.5 ;;
    esac
dona
