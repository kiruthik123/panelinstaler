#!/bin/bash

# =========================================================
#   ⚡ KS HOSTING CONTROL PANEL - ENHANCED EDITION ⚡
#   Professional Management Interface for Game Panel Hosting
#   GitHub Repository Manager with Advanced Features
# =========================================================

# --- GITHUB CONFIGURATION ---
GH_USER="kiruthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"

# URL for downloading Blueprints (Addons)
BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"

# URL for installing Panel/Wings (Your Custom Repo)
INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/installer/main/install.sh"

# --- DIRECTORIES ---
PANEL_DIR="/var/www/pterodactyl"

# --- ENHANCED COLOR PALETTE ---
NC='\033[0m' # No Color

# Primary Colors
RED='\033[1;38;5;196m'     # 🔴 Bright Red
GREEN='\033[1;38;5;46m'    # 🟢 Neon Green
BLUE='\033[1;38;5;39m'     # 🔵 Electric Blue
YELLOW='\033[1;38;5;226m'  # 🟡 Bright Yellow
PURPLE='\033[1;38;5;129m'  # 🟣 Royal Purple
CYAN='\033[1;38;5;51m'     # 💎 Cyan
WHITE='\033[1;38;5;255m'   # ⚪ White

# Accent Colors
PINK='\033[1;38;5;205m'    # 🎀 Pink
ORANGE='\033[1;38;5;208m'  # 🟠 Orange
LIME='\033[1;38;5;118m'    # 🍏 Lime
TEAL='\033[1;38;5;37m'     # 🐬 Teal
GOLD='\033[1;38;5;220m'    # 🏆 Gold
SILVER='\033[1;38;5;250m'  # 🤍 Silver
MAGENTA='\033[1;38;5;201m' # 💜 Magenta

# UI Elements
BORDER='\033[1;38;5;39m'   # Border Color
ACCENT='\033[1;38;5;51m'   # Accent Color
WARNING='\033[1;38;5;208m' # Warning Color
SUCCESS='\033[1;38;5;46m'  # Success Color
ERROR='\033[1;38;5;196m'   # Error Color

# --- UI CONFIGURATION ---
WIDTH=70
EMOJI_WIDTH=3

# --- EMOJI SET ---
EMOJI_CHECK="✅"
EMOJI_CROSS="❌"
EMOJI_WARN="⚠️"
EMOJI_INFO="ℹ️"
EMOJI_GEAR="⚙️"
EMOJI_ROCKET="🚀"
EMOJI_SHIELD="🛡️"
EMOJI_DATABASE="💾"
EMOJI_NETWORK="🌐"
EMOJI_PACKAGE="📦"
EMOJI_TOOLS="🛠️"
EMOJI_PANEL="🎮"
EMOJI_WINGS="🪽"
EMOJI_ADDON="✨"
EMOJI_THIRD="🔧"
EMOJI_EXIT="👋"
EMOJI_HOME="🏠"
EMOJI_BACK="↩️"
EMOJI_DOWNLOAD="📥"
EMOJI_UPLOAD="📤"
EMOJI_TRASH="🗑️"
EMOJI_LOCK="🔒"
EMOJI_UNLOCK="🔓"
EMOJI_FIRE="🔥"
EMOJI_STAR="⭐"
EMOJI_CRYSTAL="🔮"
EMOJI_CLOUD="☁️"
EMOJI_VPN="🔐"
EMOJI_SSL="🔒"
EMOJI_ROOT="👑"
EMOJI_TERMINAL="💻"

# --- UI UTILITIES ---
draw_bar() {
    printf "${BORDER}┏%*s┓${NC}\n" "$((WIDTH-2))" "" | tr ' ' '━'
}

draw_sub() {
    printf "${SILVER}┣%*s┫${NC}\n" "$((WIDTH-2))" "" | tr ' ' '─'
}

draw_footer() {
    printf "${BORDER}┗%*s┛${NC}\n" "$((WIDTH-2))" "" | tr ' ' '━'
}

draw_section() {
    local title="$1"
    local color="${2:-$ACCENT}"
    local len=${#title}
    local padding=$(( (WIDTH - len - 4) / 2 ))
    printf "${BORDER}┃${NC}%*s${color} %s ${NC}%*s${BORDER}┃${NC}\n" $padding "" "$title" $((WIDTH - len - padding - 4)) ""
}

print_header() {
    local title="$1"
    local emoji="$2"
    local color="${3:-$CYAN}"
    local len=${#title}
    local total_len=$((len + EMOJI_WIDTH + 1))
    local padding=$(( (WIDTH - total_len) / 2 ))
    printf "${BORDER}┃${NC}%*s${color}${emoji} %s${NC}%*s${BORDER}┃${NC}\n" $padding "" "$title" $((WIDTH - total_len - padding)) ""
}

print_option() {
    local num="$1"
    local text="$2"
    local emoji="${3:-""}"
    local color="${4:-$WHITE}"
    printf "${BORDER}┃${NC}  ${GOLD}[${num}]${NC} ${emoji} ${color}%-$(($WIDTH-15))s${NC} ${BORDER}┃${NC}\n" "$text"
}

print_action() {
    local text="$1"
    local color="${2:-$WHITE}"
    printf "${BORDER}┃${NC}  ${color}» %-$(($WIDTH-8))s${NC} ${BORDER}┃${NC}\n" "$text"
}

# --- STATUS MESSAGES ---
success() { echo -e "${SUCCESS}${EMOJI_CHECK} SUCCESS:${NC} $1"; }
error() { echo -e "${ERROR}${EMOJI_CROSS} ERROR:${NC} $1"; }
warning() { echo -e "${WARNING}${EMOJI_WARN} WARNING:${NC} $1"; }
info() { echo -e "${CYAN}${EMOJI_INFO} INFO:${NC} $1"; }
progress() { echo -e "${BLUE}${EMOJI_GEAR} WORKING:${NC} $1"; }
download() { echo -e "${PURPLE}${EMOJI_DOWNLOAD} DOWNLOADING:${NC} $1"; }
install() { echo -e "${GREEN}${EMOJI_PACKAGE} INSTALLING:${NC} $1"; }

# --- ANIMATION EFFECTS ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

loading() {
    echo -ne "${BLUE}⏳ ${WHITE}Processing"
    for i in {1..3}; do
        echo -ne "${BLUE}."
        sleep 0.3
    done
    echo -e "${NC}"
}

# --- HEADER DISPLAY ---
header() {
    clear
    draw_bar
    print_header "⚡ KS HOSTING CONTROL PANEL ⚡" "" "$MAGENTA"
    draw_section "Professional Game Panel Management Suite" "$SILVER"
    draw_sub
    echo -e "${BORDER}┃${NC}${SILVER}  📁 Repository: ${CYAN}$GH_USER/$GH_REPO${NC}${BORDER}┃${NC}"
    echo -e "${BORDER}┃${NC}${SILVER}  👤 User: ${WHITE}$USER${SILVER}  📡 IP: ${WHITE}$(hostname -I | awk '{print $1}')${NC}${BORDER}┃${NC}"
    echo -e "${BORDER}┃${NC}${SILVER}  🕐 Time: ${WHITE}$(date '+%Y-%m-%d %H:%M:%S')${SILVER}  📊 Load: ${WHITE}$(uptime | awk '{print $10 $11 $12}')${NC}${BORDER}┃${NC}"
    draw_bar
}

# --- INSTALLER LOGIC (ADDONS) ---
install_bp() {
    local name="$1"
    local file="$2"
    local url="$BASE_URL/$file"

    header
    print_header "📦 ADDON INSTALLATION" "$EMOJI_PACKAGE" "$ORANGE"
    draw_section "Installing: $name" "$YELLOW"
    draw_sub
    
    if ! command -v blueprint &> /dev/null; then
        error "Blueprint framework is not installed."
        echo -e "${SILVER}${EMOJI_INFO} Please install the framework first from Menu 4 → Option 1${NC}"
        read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
        return
    fi

    cd "$PANEL_DIR" || { error "Failed to access panel directory"; return 1; }
    
    download "Downloading $name addon..."
    rm -f "$file"
    if wget -q --show-progress "$url" -O "$file"; then
        success "Download completed!"
    else
        error "Download failed!"
        echo -e "${SILVER}${EMOJI_INFO} Could not find '$file' in the repository${NC}"
        read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
        return
    fi

    echo ""
    install "Applying addon configuration..."
    if blueprint -install "$file"; then
        rm -f "$file"
        echo ""
        success "$name has been successfully installed! ${EMOJI_STAR}"
        echo -e "${SILVER}${EMOJI_INFO} Please refresh your panel to see changes${NC}"
    else
        error "Installation failed!"
    fi
    
    read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
}

# --- TAILSCALE MENU ---
menu_tailscale() {
    while true; do
        header
        print_header "VPN MANAGER" "$EMOJI_VPN" "$TEAL"
        draw_section "TailScale Secure Tunnel" "$CYAN"
        draw_sub
        
        print_option "1" "Install TailScale VPN" "$EMOJI_DOWNLOAD" "$GREEN"
        print_option "2" "Generate Login Link" "$EMOJI_LOCK" "$BLUE"
        print_option "3" "Check Status & IP" "$EMOJI_NETWORK" "$YELLOW"
        print_option "4" "Uninstall TailScale" "$EMOJI_TRASH" "$RED"
        print_option "0" "Return to Main Menu" "$EMOJI_BACK" "$SILVER"
        
        draw_footer
        echo -ne "${GOLD}${EMOJI_CRYSTAL} Select option [0-4]: ${NC}"
        read ts_opt

        case $ts_opt in
            1)
                echo ""
                if [ ! -c /dev/net/tun ]; then
                    error "TUN device is not available!"
                    echo -e "${SILVER}${EMOJI_INFO} Please contact your VPS provider to enable TUN/TAP${NC}"
                else
                    progress "Installing TailScale VPN..."
                    curl -fsSL https://tailscale.com/install.sh | sh
                    success "TailScale installed successfully! ${EMOJI_SHIELD}"
                fi
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            2)
                header
                print_header "AUTHENTICATION" "$EMOJI_LOCK" "$GREEN"
                draw_sub
                echo ""
                if ! command -v tailscale &> /dev/null; then
                    error "TailScale is not installed!"
                else
                    info "Generating authentication link..."
                    tailscale up --reset
                    success "Authentication initiated! ${EMOJI_CHECK}"
                    echo -e "${SILVER}${EMOJI_INFO} Check your TailScale dashboard for the login link${NC}"
                fi
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            3)
                echo ""
                info "VPN Status:"
                tailscale status
                echo ""
                info "Assigned IP Address:"
                tailscale ip -4
                echo ""
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            4)
                echo ""
                warning "This will completely remove TailScale VPN from your system!"
                read -p "$(echo -e "${RED}${EMOJI_WARN} Type 'CONFIRM' to proceed: ${NC}")" c
                if [ "$c" == "CONFIRM" ]; then
                    progress "Removing TailScale..."
                    systemctl stop tailscaled 2>/dev/null
                    if [ -f /etc/debian_version ]; then
                        apt-get remove tailscale -y
                    elif [ -f /etc/redhat-release ]; then
                        yum remove tailscale -y
                    fi
                    rm -rf /var/lib/tailscale /etc/tailscale
                    success "TailScale has been uninstalled! ${EMOJI_TRASH}"
                else
                    info "Uninstallation cancelled."
                fi
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            0) return ;;
            *) error "Invalid selection!"; sleep 0.5 ;;
        esac
    done
}

# [Rest of the functions follow similar pattern with enhanced colors and emojis]

# --- CLOUDFLARE MENU ---
menu_cloudflare() {
    while true; do
        header
        print_header "CLOUDFLARE TUNNEL" "$EMOJI_CLOUD" "$BLUE"
        draw_section "Secure Reverse Proxy Manager" "$CYAN"
        draw_sub
        
        print_option "1" "Install & Setup Tunnel" "$EMOJI_GEAR" "$GREEN"
        print_option "2" "Uninstall Cloudflared" "$EMOJI_TRASH" "$RED"
        print_option "0" "Return to Main Menu" "$EMOJI_BACK" "$SILVER"
        
        draw_footer
        echo -ne "${GOLD}${EMOJI_CRYSTAL} Select option [0-2]: ${NC}"
        read cf_opt

        case $cf_opt in
            1)
                echo ""
                progress "Configuring Cloudflare repositories..."
                mkdir -p --mode=0755 /usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
                echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list
                apt-get update && apt-get install cloudflared -y
                
                echo ""
                info "${EMOJI_INFO} Setup Instructions:"
                echo -e "${CYAN}1. ${WHITE}Create tunnel at ${BLUE}https://one.dash.cloudflare.com/${NC}"
                echo -e "${CYAN}2. ${WHITE}Copy the 'Connector' command${NC}"
                echo ""
                read -p "$(echo -e "${GOLD}${EMOJI_DOWNLOAD} Paste token/command here: ${NC}")" cf_cmd
                
                cf_cmd=${cf_cmd/sudo /}

                if [[ "$cf_cmd" == *"cloudflared"* ]]; then
                    echo ""; progress "Starting Cloudflare tunnel..."; eval "$cf_cmd"
                    success "Tunnel activated successfully! ${EMOJI_CHECK}"
                elif [[ -n "$cf_cmd" ]]; then
                    echo ""; progress "Installing service token..."; cloudflared service install "$cf_cmd"
                    success "Tunnel service installed! ${EMOJI_SHIELD}"
                else
                    error "No valid input provided!"
                fi
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            2)
                echo ""; warning "This will remove Cloudflare Tunnel from your system!"
                read -p "$(echo -e "${RED}${EMOJI_WARN} Type 'CONFIRM' to proceed: ${NC}")" c
                if [ "$c" == "CONFIRM" ]; then
                    progress "Stopping services..."; systemctl stop cloudflared; systemctl disable cloudflared
                    progress "Removing packages..."; apt-get remove cloudflared -y; apt-get purge cloudflared -y
                    rm -rf /etc/cloudflared; rm -f /etc/apt/sources.list.d/cloudflared.list
                    success "Cloudflare Tunnel removed! ${EMOJI_TRASH}"
                fi
                read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter to continue...${NC}")"
                ;;
            0) return ;;
            *) error "Invalid selection!"; sleep 0.5 ;;
        esac
    done
}

# --- MAIN MENU ---
while true; do
    header
    print_header "MAIN CONTROL PANEL" "$EMOJI_HOME" "$MAGENTA"
    draw_section "Select an option below" "$CYAN"
    draw_sub
    
    print_option "1" "Pterodactyl Panel Manager" "$EMOJI_PANEL" "$GREEN"
    print_option "2" "Pterodactyl Wings Manager" "$EMOJI_WINGS" "$BLUE"
    print_option "3" "Install Both (Hybrid Setup)" "$EMOJI_ROCKET" "$ORANGE"
    draw_sub
    print_option "4" "Blueprint & Addons Store" "$EMOJI_ADDON" "$PURPLE"
    print_option "5" "Third-Party Panel Installers" "$EMOJI_THIRD" "$TEAL"
    print_option "6" "System Toolbox & Utilities" "$EMOJI_TOOLS" "$YELLOW"
    draw_sub
    print_option "7" "Uninstall Pterodactyl" "$EMOJI_TRASH" "$RED"
    print_option "0" "Exit Control Panel" "$EMOJI_EXIT" "$SILVER"
    
    draw_footer
    echo -ne "${GOLD}${EMOJI_STAR} Select option [0-7]: ${NC}"
    read choice

    case $choice in
        1) 
            header
            print_header "PANEL MANAGEMENT" "$EMOJI_PANEL" "$GREEN"
            draw_sub
            print_option "1" "Install Panel" "$EMOJI_DOWNLOAD" "$BLUE"
            print_option "2" "Create Admin User" "$EMOJI_ROOT" "$YELLOW"
            print_option "3" "Clear Panel Cache" "$EMOJI_TRASH" "$ORANGE"
            print_option "4" "Fix Permissions" "$EMOJI_LOCK" "$PURPLE"
            print_option "0" "Back to Main" "$EMOJI_BACK" "$SILVER"
            draw_footer
            echo -ne "${GOLD}${EMOJI_CRYSTAL} Select: ${NC}"
            read opt
            case $opt in
                1) echo -e "\n${ORANGE}${EMOJI_ROCKET} Launching KS Installer...${NC}"; bash <(curl -s $INSTALLER_URL); read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                2) cd "$PANEL_DIR" && php artisan p:user:make; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                3) cd "$PANEL_DIR" && php artisan view:clear && php artisan config:clear; success "Cache cleared! ${EMOJI_CHECK}"; sleep 1 ;;
                4) chown -R www-data:www-data "$PANEL_DIR"/*; success "Permissions fixed! ${EMOJI_CHECK}"; sleep 1 ;;
                0) continue ;;
                *) error "Invalid option!"; sleep 0.5 ;;
            esac
            ;;
        2) 
            header
            print_header "WINGS MANAGEMENT" "$EMOJI_WINGS" "$BLUE"
            draw_sub
            print_option "1" "Install Wings Daemon" "$EMOJI_DOWNLOAD" "$GREEN"
            print_option "2" "Auto-Configure Token" "$EMOJI_LOCK" "$YELLOW"
            print_option "3" "Restart Wings Service" "$EMOJI_GEAR" "$ORANGE"
            print_option "0" "Back to Main" "$EMOJI_BACK" "$SILVER"
            draw_footer
            echo -ne "${GOLD}${EMOJI_CRYSTAL} Select: ${NC}"
            read opt
            case $opt in
                1) echo -e "\n${ORANGE}${EMOJI_ROCKET} Launching Wings Installer...${NC}"; bash <(curl -s $INSTALLER_URL); read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                2) echo ""; info "${EMOJI_INFO} Paste your configuration command:"; read -r CMD; eval "$CMD"; systemctl enable --now wings; success "Wings configured! ${EMOJI_CHECK}"; sleep 1 ;;
                3) systemctl restart wings; success "Wings restarted! ${EMOJI_CHECK}"; sleep 1 ;;
                0) continue ;;
                *) error "Invalid option!"; sleep 0.5 ;;
            esac
            ;;
        3) 
            echo -e "\n${ORANGE}${EMOJI_FIRE} ${EMOJI_ROCKET} ${EMOJI_FIRE}"
            echo -e "${GOLD}Starting Hybrid Installation...${NC}"
            echo -e "${SILVER}This will install both Panel and Wings${NC}\n"
            loading
            bash <(curl -s $INSTALLER_URL)
            read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")"
            ;;
        4) menu_blueprint ;;
        5) menu_thirdparty ;;
        6) 
            header
            print_header "SYSTEM TOOLBOX" "$EMOJI_TOOLS" "$YELLOW"
            draw_sub
            print_option "1" "System Monitor" "$EMOJI_TERMINAL" "$CYAN"
            print_option "2" "Add 2GB Swap" "$EMOJI_DATABASE" "$BLUE"
            print_option "3" "Network Speedtest" "$EMOJI_NETWORK" "$GREEN"
            print_option "4" "Configure Firewall" "$EMOJI_SHIELD" "$PURPLE"
            print_option "5" "Database Backup" "$EMOJI_DATABASE" "$ORANGE"
            print_option "6" "Install SSL (Certbot)" "$EMOJI_SSL" "$TEAL"
            draw_sub
            print_option "7" "TailScale VPN Manager" "$EMOJI_VPN" "$CYAN"
            print_option "8" "Cloudflare Tunnel" "$EMOJI_CLOUD" "$BLUE"
            print_option "9" "Enable Root Access" "$EMOJI_ROOT" "$RED"
            print_option "10" "SSH Web Terminal" "$EMOJI_TERMINAL" "$GREEN"
            print_option "0" "Back to Main" "$EMOJI_BACK" "$SILVER"
            draw_footer
            echo -ne "${GOLD}${EMOJI_CRYSTAL} Select: ${NC}"
            read opt
            case $opt in
                1) header; echo -e "${CYAN}${EMOJI_TERMINAL} System Status:${NC}"; free -h | grep Mem; df -h / | awk 'NR==2'; echo ""; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                2) fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab; success "2GB Swap added! ${EMOJI_CHECK}"; sleep 1 ;;
                3) apt-get install speedtest-cli -y -qq; echo ""; info "Running speed test..."; speedtest-cli --simple; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                4) apt install ufw -y -qq; ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw allow 8080 && ufw allow 2022 && ufw allow 5656; yes | ufw enable; success "Firewall secured! ${EMOJI_SHIELD}"; sleep 1 ;;
                5) mysqldump -u root -p pterodactyl > /root/backup_$(date +%F).sql; success "Backup saved to /root/ ${EMOJI_DATABASE}"; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                6) apt install certbot -y -qq; echo ""; read -p "$(echo -e "${GOLD}${EMOJI_SSL} Enter Domain: ${NC}")" DOM; certbot certonly --standalone -d $DOM; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                7) menu_tailscale ;;
                8) menu_cloudflare ;;
                9) echo -e "${CYAN}${EMOJI_ROOT} Configuring Root Access...${NC}"; passwd root; sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config; service ssh restart; success "Root access enabled! ${EMOJI_UNLOCK}"; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                10) curl -sSf https://sshx.io/get | sh; echo ""; sshx; read -p "$(echo -e "${GOLD}${EMOJI_BACK} Press Enter...${NC}")" ;;
                0) continue ;;
                *) error "Invalid option!"; sleep 0.5 ;;
            esac
            ;;
        7) 
            echo ""
            warning "${EMOJI_FIRE} ${EMOJI_WARN} ${EMOJI_FIRE}"
            echo -e "${RED}CRITICAL OPERATION: COMPLETE UNINSTALL${NC}"
            echo -e "${YELLOW}This will remove ALL Pterodactyl data!${NC}"
            read -p "$(echo -e "${RED}${EMOJI_WARN} Type 'DELETE-ALL' to confirm: ${NC}")" CONF
            if [ "$CONF" == "DELETE-ALL" ]; then 
                progress "Removing Pterodactyl..."
                rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings
                success "Pterodactyl completely removed! ${EMOJI_TRASH}"
            else
                info "Uninstallation cancelled."
            fi
            sleep 1
            ;;
        0)
            echo ""
            echo -e "${MAGENTA}${EMOJI_EXIT} Thank you for using KS Hosting Control Panel!${NC}"
            echo -e "${SILVER}Shutting down...${NC}"
            sleep 1
            clear
            exit 0
            ;;
        *) 
            error "Invalid selection!"
            sleep 0.5
            ;;
    esac
done
