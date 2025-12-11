#!/usr/bin/env bash

# =========================================================
#   KS HOSTING - Enterprise Panel Management Suite
#   Professional Multi-Panel Deployment & Administration
# =========================================================

# --- GITHUB CONFIGURATION ---
readonly GH_USER="kiruthik123"
readonly GH_REPO="panelinstaler"
readonly GH_BRANCH="main"
readonly BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
readonly INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/installer/main/install.sh"

# --- DIRECTORIES ---
readonly PANEL_DIR="/var/www/pterodactyl"

# --- COLOR PALETTE ---
readonly NC='\033[0m'
readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly BLUE='\033[1;34m'
readonly YELLOW='\033[1;33m'
readonly MAGENTA='\033[1;95m'
readonly CYAN='\033[1;96m'
readonly WHITE='\033[1;97m'
readonly GRAY='\033[1;90m'
readonly ORANGE='\033[1;38;5;208m'
readonly PURPLE='\033[1;35m'

# --- UI CONSTANTS ---
readonly WIDTH=70
readonly VERSION="2.1.0"

# --- UI FUNCTIONS ---
draw_bar() { 
    printf "${BLUE}╔%*s╗${NC}\n" $((WIDTH-2)) | tr ' ' '═'
}

draw_sub() {
    printf "${GRAY}╠%*s╣${NC}\n" $((WIDTH-2)) | tr ' ' '─'
}

draw_footer() {
    printf "${BLUE}╚%*s╝${NC}\n" $((WIDTH-2)) | tr ' ' '═'
}

print_header() {
    local title="$1"
    local color="${2:-$WHITE}"
    printf "${BLUE}║${NC}%*s${color}╡ %-52s ╞${NC}%*s${BLUE}║${NC}\n" \
        $(( (WIDTH - ${#title} - 6) / 2 )) "" "$title" \
        $(( WIDTH - ${#title} - 6 - (WIDTH - ${#title} - 6) / 2 )) ""
}

print_section() {
    local title="$1"
    printf "${BLUE}║${NC}  ${MAGENTA}▸${NC} ${CYAN}%s${NC}\n" "$title"
}

print_option() {
    local num="$1"
    local text="$2"
    local icon="${3:-"○"}"
    local color="${4:-$WHITE}"
    printf "${BLUE}║${NC}    ${GREEN}%s${NC} ${CYAN}[%s]${NC} ${color}%-50s${NC} ${BLUE}║${NC}\n" "$icon" "$num" "$text"
}

print_status() {
    local type="$1"
    local message="$2"
    case $type in
        "info") echo -e "${CYAN}📘 INFO${NC}    $message" ;;
        "success") echo -e "${GREEN}✅ SUCCESS${NC} $message" ;;
        "error") echo -e "${RED}❌ ERROR${NC}   $message" ;;
        "warning") echo -e "${YELLOW}⚠️  WARNING${NC} $message" ;;
    esac
}

# --- HEADER DISPLAY ---
header() {
    clear
    draw_bar
    print_header "🛡️  KS HOSTING MANAGEMENT SUITE" "$MAGENTA"
    print_header "Version $VERSION | Enterprise Edition" "$GRAY"
    draw_sub
    printf "${BLUE}║${NC}  ${GRAY}User:${NC} ${WHITE}%s${NC} ${GRAY}|${NC} ${GRAY}IP:${NC} ${WHITE}%s${NC} ${GRAY}|${NC} ${GRAY}Host:${NC} ${WHITE}%s${NC} %*s${BLUE}║${NC}\n" \
        "$USER" "$(hostname -I | awk '{print $1}')" "$(hostname)" \
        $((WIDTH - 30 - ${#USER} - ${#HOSTNAME})) ""
    draw_bar
}

# --- BLUEPRINT INSTALLER ---
install_bp() {
    local name="$1"
    local file="$2"
    local url="$BASE_URL/$file"

    header
    print_header "📦 INSTALLING: $name" "$YELLOW"
    draw_sub
    echo ""
    
    if ! command -v blueprint &> /dev/null; then
        print_status "error" "Blueprint framework not found"
        echo -e "${GRAY}Please install Blueprint framework first.${NC}"
        read -p "🔄 Press Enter to continue..."
        return 1
    fi

    cd "$PANEL_DIR" || { print_status "error" "Cannot access panel directory"; return 1; }
    
    print_status "info" "Downloading $name..."
    if wget -q --show-progress "$url" -O "$file"; then
        print_status "success" "Download completed"
    else
        print_status "error" "Download failed: $file"
        read -p "🔄 Press Enter to continue..."
        return 1
    fi

    echo ""
    print_status "info" "Installing extension..."
    if blueprint -install "$file"; then
        print_status "success" "Installation complete"
    else
        print_status "error" "Installation failed"
    fi
    
    rm -f "$file"
    echo ""
    read -p "🚀 Press Enter to continue..."
}

# --- TAILSCALE MANAGER ---
menu_tailscale() {
    while true; do
        header
        print_header "🔐 TAILSCALE VPN MANAGER" "$ORANGE"
        draw_sub
        print_option "1" "Install Tailscale VPN" "🔧"
        print_option "2" "Generate Auth Link" "🔗"
        print_option "3" "View Status & IP" "📊"
        print_option "4" "Remove Tailscale" "🗑️"
        draw_sub
        print_option "0" "Return to Main Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🛠️  Select option [0-4]: ${NC}"
        read -r ts_opt

        case $ts_opt in
            1)
                echo ""
                if [ ! -c /dev/net/tun ]; then
                    print_status "error" "TUN device unavailable"
                    echo -e "${YELLOW}Please enable TUN/TAP support with your VPS provider.${NC}"
                else
                    print_status "info" "Installing Tailscale..."
                    curl -fsSL https://tailscale.com/install.sh | sh
                    print_status "success" "Tailscale installed successfully"
                fi
                read -p "🔄 Press Enter..."
                ;;
            2)
                header
                print_header "🔗 AUTHENTICATION LINK" "$GREEN"
                draw_sub
                echo ""
                if command -v tailscale &> /dev/null; then
                    echo -e "${YELLOW}Generating authentication link...${NC}"
                    tailscale up --reset
                    echo ""
                    print_status "success" "Authentication initiated"
                else
                    print_status "error" "Tailscale not installed"
                fi
                read -p "🔄 Press Enter..."
                ;;
            3)
                echo ""
                print_status "info" "Connection Status:"
                tailscale status
                echo -e "\n${YELLOW}IP Address:${NC} $(tailscale ip -4 2>/dev/null || echo "Not connected")"
                read -p "🔄 Press Enter..."
                ;;
            4)
                echo ""
                print_status "warning" "⚠️  TAILSCALE REMOVAL"
                read -p "Type 'CONFIRM' to proceed: " confirm
                if [[ "$confirm" == "CONFIRM" ]]; then
                    print_status "info" "Removing Tailscale..."
                    systemctl stop tailscaled 2>/dev/null
                    apt-get remove tailscale -y 2>/dev/null || yum remove tailscale -y 2>/dev/null
                    rm -rf /var/lib/tailscale /etc/tailscale
                    print_status "success" "Tailscale uninstalled"
                else
                    print_status "info" "Removal cancelled"
                fi
                read -p "🔄 Press Enter..."
                ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- CLOUDFLARE TUNNEL MANAGER ---
menu_cloudflare() {
    while true; do
        header
        print_header "☁️  CLOUDFLARE TUNNEL MANAGER" "$ORANGE"
        draw_sub
        print_option "1" "Install & Configure Tunnel" "🔧"
        print_option "2" "Uninstall Cloudflared" "🗑️"
        draw_sub
        print_option "0" "Return to Main Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🛠️  Select option [0-2]: ${NC}"
        read -r cf_opt

        case $cf_opt in
            1)
                echo ""
                print_status "info" "Adding Cloudflare repository..."
                mkdir -p --mode=0755 /usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | \
                    tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
                
                echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
                    tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
                
                apt-get update && apt-get install cloudflared -y
                
                echo ""
                print_status "info" "📋 Tunnel Setup Instructions:"
                echo -e "${CYAN}1.${NC} Create tunnel at ${BLUE}https://one.dash.cloudflare.com/${NC}"
                echo -e "${CYAN}2.${NC} Copy the 'Connector' command"
                echo -e "${CYAN}3.${NC} Paste it below\n"
                
                read -p "📝 Paste command/token: " cf_cmd
                cf_cmd=${cf_cmd/sudo /}

                if [[ "$cf_cmd" == *"cloudflared"* ]]; then
                    print_status "info" "Configuring tunnel..."
                    eval "$cf_cmd"
                    print_status "success" "Tunnel activated"
                elif [[ -n "$cf_cmd" ]]; then
                    print_status "info" "Installing service token..."
                    cloudflared service install "$cf_cmd"
                    print_status "success" "Tunnel service installed"
                else
                    print_status "error" "No input provided"
                fi
                read -p "🔄 Press Enter..."
                ;;
            2)
                echo ""
                print_status "warning" "⚠️  CLOUDFLARED REMOVAL"
                read -p "Type 'CONFIRM' to proceed: " confirm
                if [[ "$confirm" == "CONFIRM" ]]; then
                    print_status "info" "Stopping service..."
                    systemctl stop cloudflared
                    systemctl disable cloudflared
                    
                    print_status "info" "Removing package..."
                    apt-get remove cloudflared -y
                    apt-get purge cloudflared -y
                    
                    rm -rf /etc/cloudflared
                    rm -f /etc/apt/sources.list.d/cloudflared.list
                    
                    print_status "success" "Cloudflared uninstalled"
                else
                    print_status "info" "Removal cancelled"
                fi
                read -p "🔄 Press Enter..."
                ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- ADDON MANAGEMENT ---
menu_addons() {
    while true; do
        header
        print_header "🎨 ADDON MARKETPLACE" "$PURPLE"
        draw_sub
        print_section "🎭 THEMES & APPEARANCE"
        print_option "1" "Recolor Theme" "🎨"
        print_option "2" "Sidebar Theme" "📐"
        print_option "3" "Server Backgrounds" "🖼️"
        print_option "4" "Euphoria Theme" "🌈"
        
        draw_sub
        print_section "⚙️  UTILITIES & TOOLS"
        print_option "5" "MC Tools (Editor)" "🛠️"
        print_option "6" "MC Logs (Live Console)" "📜"
        print_option "7" "Player Listing" "👥"
        print_option "8" "Votifier Tester" "📨"
        print_option "9" "Database Editor" "🗃️"
        print_option "10" "Subdomains Manager" "🌐"
        
        draw_sub
        print_option "0" "Return to Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🛍️  Select addon [0-10]: ${NC}"
        read -r opt

        case $opt in
            1) install_bp "Recolor Theme" "recolor.blueprint" ;;
            2) install_bp "Sidebar Theme" "sidebar.blueprint" ;;
            3) install_bp "Server Backgrounds" "serverbackgrounds.blueprint" ;;
            4) install_bp "Euphoria Theme" "euphoriatheme.blueprint" ;;
            5) install_bp "MC Tools" "mctools.blueprint" ;;
            6) install_bp "MC Logs" "mclogs.blueprint" ;;
            7) install_bp "Player Listing" "playerlisting.blueprint" ;;
            8) install_bp "Votifier Tester" "votifiertester.blueprint" ;;
            9) install_bp "Database Editor" "dbedit.blueprint" ;;
            10) install_bp "Subdomains Manager" "subdomains.blueprint" ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- BLUEPRINT SYSTEM MENU ---
menu_blueprint() {
    while true; do
        header
        print_header "🧩 BLUEPRINT EXTENSION SYSTEM" "$CYAN"
        draw_sub
        print_option "1" "Install Framework" "🔧" "$PURPLE"
        print_option "2" "Browse Addon Store" "🛍️" "$GREEN"
        print_option "3" "Update All Extensions" "🔄"
        print_option "4" "Toggle Development Mode" "👨‍💻"
        draw_sub
        print_option "5" "Remove Extension" "🗑️" "$ORANGE"
        print_option "6" "Uninstall Framework" "⚠️" "$RED"
        draw_sub
        print_option "0" "Return to Main Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🛠️  Select option [0-6]: ${NC}"
        read -r opt
        
        case $opt in
            1) 
                print_status "info" "Downloading Blueprint installer..."
                cd "$PANEL_DIR" || exit
                rm -f blueprint-installer.sh
                if wget -q --show-progress "$BASE_URL/blueprint-installer.sh"; then
                    bash blueprint-installer.sh
                    rm blueprint-installer.sh
                    print_status "success" "Framework installed"
                else
                    print_status "error" "Download failed"
                fi
                read -p "🔄 Press Enter..."
                ;;
            2) menu_addons ;;
            3) 
                cd "$PANEL_DIR" && blueprint -upgrade
                print_status "success" "Extensions updated"
                read -p "🔄 Press Enter..."
                ;;
            4) 
                cd "$PANEL_DIR" && sed -i 's/APP_ENV=production/APP_ENV=local/g' .env
                print_status "success" "Development mode enabled"
                sleep 1
                ;;
            5) 
                echo ""
                print_status "info" "Enter extension identifier to remove:"
                read -p "📝 Identifier: " identifier
                if [[ -n "$identifier" ]]; then
                    cd "$PANEL_DIR" && blueprint -remove "$identifier"
                    print_status "success" "Extension removed"
                fi
                read -p "🔄 Press Enter..."
                ;;
            6) 
                echo ""
                print_status "warning" "⚠️  FRAMEWORK REMOVAL"
                read -p "Type 'DELETE' to confirm: " confirm
                if [[ "$confirm" == "DELETE" ]]; then
                    rm -rf /usr/local/bin/blueprint "$PANEL_DIR/blueprint"
                    print_status "success" "Blueprint framework removed"
                else
                    print_status "info" "Operation cancelled"
                fi
                read -p "🔄 Press Enter..."
                ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- PANEL INSTALLATION FUNCTIONS ---
install_panel() {
    local name="$1"
    local installer_url="$2"
    local color="$3"
    
    header
    print_header "🚀 INSTALLING: $name" "$color"
    draw_sub
    print_status "info" "Downloading installer..."
    echo -e "${GRAY}Source: $installer_url${NC}"
    echo ""
    
    if bash <(curl -s "$installer_url"); then
        print_status "success" "$name installation completed"
    else
        print_status "error" "Installation failed"
    fi
    
    read -p "🔄 Press Enter to continue..."
}

menu_pufferpanel() {
    install_panel "PufferPanel" \
        "https://raw.githubusercontent.com/kiruthik123/pufferpanel/main/Install.sh" \
        "$ORANGE"
}

menu_mythicaldash() {
    install_panel "MythicalDash" \
        "https://raw.githubusercontent.com/kiruthik123/mythicaldash/main/install.sh" \
        "$PURPLE"
}

menu_skyport_panel() {
    install_panel "Skyport Panel" \
        "https://raw.githubusercontent.com/kiruthik123/skyport/main/install.sh" \
        "$CYAN"
}

menu_pterodactyl_install() {
    while true; do
        header
        print_header "🦖 PTERODACTYL MANAGEMENT" "$YELLOW"
        draw_sub
        print_option "1" "Install Panel & Wings (Hybrid)" "🚀"
        print_option "2" "Blueprint & Addons Manager" "🧩" "$CYAN"
        draw_sub
        print_option "3" "Uninstall Pterodactyl" "🗑️" "$RED"
        draw_sub
        print_option "0" "Return to Hub" "↩️" "$GRAY"
        draw_footer
        echo -ne "${CYAN}🛠️  Select option [0-3]: ${NC}"
        read -r opt
        
        case $opt in
            1) 
                print_status "info" "Starting hybrid installer..."
                bash <(curl -s "$INSTALLER_URL")
                read -p "🔄 Press Enter..."
                ;;
            2) menu_blueprint ;;
            3) 
                echo ""
                print_status "warning" "⚠️  PTERODACTYL REMOVAL"
                read -p "Type 'DELETE ALL' to confirm: " confirm
                if [[ "$confirm" == "DELETE ALL" ]]; then
                    rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings
                    print_status "success" "Pterodactyl removed"
                fi
                sleep 1
                ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- PANEL INSTALLATION HUB ---
menu_panel_installation_hub() {
    while true; do
        header
        print_header "🏢 PANEL INSTALLATION HUB" "$ORANGE"
        draw_sub
        print_section "🎮 GAME SERVER PANELS"
        print_option "1" "Pterodactyl Panel" "🦖" "$YELLOW"
        print_option "2" "PufferPanel" "🐡" "$YELLOW"
        
        draw_sub
        print_section "🌐 WEB HOSTING PANELS"
        print_option "3" "MythicalDash Panel" "✨" "$YELLOW"
        print_option "4" "Skyport Panel" "🛰️" "$YELLOW"
        
        draw_sub
        print_option "0" "Return to Main Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🏗️  Select panel to install [0-4]: ${NC}"
        read -r hub_opt

        case $hub_opt in
            1) menu_pterodactyl_install ;;
            2) menu_pufferpanel ;;
            3) menu_mythicaldash ;;
            4) menu_skyport_panel ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- SYSTEM TOOLBOX ---
menu_toolbox() {
    while true; do
        header
        print_header "🧰 SYSTEM TOOLBOX" "$MAGENTA"
        draw_sub
        print_section "📊 MONITORING & OPTIMIZATION"
        print_option "1" "System Monitor" "📈"
        print_option "2" "Add 2GB Swap Memory" "💾"
        print_option "3" "Network Speed Test" "🌐"
        print_option "4" "Configure Firewall" "🛡️"
        
        draw_sub
        print_section "🔧 MAINTENANCE & SECURITY"
        print_option "5" "Database Backup" "💾"
        print_option "6" "Install SSL Certificate" "🔒"
        print_option "9" "Enable Root Access" "🔑" "$GREEN"
        print_option "10" "SSH Web Terminal" "💻" "$GREEN"
        
        draw_sub
        print_section "🔗 NETWORK SERVICES"
        print_option "7" "Tailscale VPN Manager" "🔐" "$ORANGE"
        print_option "8" "Cloudflare Tunnel Manager" "☁️" "$ORANGE"
        
        draw_sub
        print_option "0" "Return to Main Menu" "↩️" "$RED"
        draw_footer
        echo -ne "${CYAN}🛠️  Select tool [0-10]: ${NC}"
        read -r opt
        
        case $opt in
            1) 
                header
                print_header "📊 SYSTEM METRICS" "$CYAN"
                draw_sub
                echo -e "${WHITE}Memory Usage:${NC}"
                free -h | grep Mem
                echo -e "\n${WHITE}Disk Usage:${NC}"
                df -h / | awk 'NR==2 {printf "Used: %s/%s (%s)\n", $3, $2, $5}'
                echo -e "\n${WHITE}Load Average:${NC}"
                uptime | awk -F'load average:' '{print $2}'
                read -p "🔄 Press Enter..."
                ;;
            2) 
                print_status "info" "Configuring swap memory..."
                fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
                echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
                print_status "success" "2GB swap memory added"
                sleep 1
                ;;
            3) 
                apt-get install speedtest-cli -y -qq
                print_status "info" "Running speed test..."
                speedtest-cli --simple
                read -p "🔄 Press Enter..."
                ;;
            4) 
                apt install ufw -y -qq
                ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw allow 8080 && ufw allow 2022 && ufw allow 5656
                echo "y" | ufw enable
                print_status "success" "Firewall configured with essential ports"
                sleep 1
                ;;
            5) 
                mysqldump -u root -p pterodactyl > "/root/backup_$(date +%F_%H-%M).sql"
                print_status "success" "Backup saved to /root/backup_$(date +%F_%H-%M).sql"
                read -p "🔄 Press Enter..."
                ;;
            6) 
                apt install certbot -y -qq
                echo ""
                read -p "🌐 Enter domain name: " DOMAIN
                certbot certonly --standalone -d "$DOMAIN"
                print_status "success" "SSL certificate installed"
                read -p "🔄 Press Enter..."
                ;;
            7) menu_tailscale ;;
            8) menu_cloudflare ;;
            9) 
                echo -e "${CYAN}🔑 Setting root password...${NC}"
                passwd root
                sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
                systemctl restart ssh
                print_status "success" "Root access enabled"
                read -p "🔄 Press Enter..."
                ;;
            10) 
                curl -sSf https://sshx.io/get | sh
                echo ""
                sshx
                read -p "🔄 Press Enter..."
                ;;
            0) return ;;
            *) print_status "error" "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# --- MAIN MENU ---
while true; do
    header
    print_header "🏠 MAIN CONTROL PANEL" "$GREEN"
    draw_sub
    print_section "🚀 DEPLOYMENT"
    print_option "1" "Panel Installation Hub" "🏢" "$YELLOW"
    
    draw_sub
    print_section "⚙️  MANAGEMENT"
    print_option "2" "Pterodactyl Addon Manager" "🧩" "$CYAN"
    print_option "3" "System Toolbox" "🧰" "$MAGENTA"
    
    draw_sub
    print_section "🔚 EXIT"
    print_option "0" "Exit Management Suite" "🚪" "$GRAY"
    
    draw_footer
    echo -ne "${CYAN}🎯 Select action [0-3]: ${NC}"
    read -r choice

    case $choice in
        1) menu_panel_installation_hub ;;
        2) menu_blueprint ;;
        3) menu_toolbox ;;
        0) 
            clear
            echo -e "${GREEN}Thank you for using KS Hosting Management Suite${NC}"
            echo -e "${GRAY}Goodbye! 👋${NC}"
            exit 0
            ;;
        *) print_status "error" "Invalid selection"; sleep 0.5 ;;
    esac
done
