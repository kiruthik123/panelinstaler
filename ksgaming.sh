#!/usr/bin/env bash
# =========================================================
# KS HOSTING - Enterprise Panel Management Suite
# Version: 3.0.0 | Professional Edition
# Features:
#  - Animated boot sequence with audio feedback
#  - Unified panel installation hub (5+ control panels)
#  - Blueprint-based addon management system
#  - Automated network configuration
#  - Comprehensive system toolbox
#  - Professional UI with smooth animations
# =========================================================

set -euo pipefail
IFS=$'\n\t'

# ---------------- Configuration ----------------
readonly GH_USER="kiruthik123"
readonly GH_REPO="panelinstaler"
readonly GH_BRANCH="main"
readonly BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
readonly PANEL_DIR="/var/www/pterodactyl"
readonly WIDTH=70
readonly VERSION="3.0.0"

# ---------------- ANSI Color Codes ----------------
readonly NC='\033[0m'
readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly BLUE='\033[1;34m'
readonly YELLOW='\033[1;33m'
readonly PURPLE='\033[1;35m'
readonly CYAN='\033[1;36m'
readonly WHITE='\033[1;97m'
readonly GRAY='\033[1;90m'
readonly ORANGE='\033[1;38;5;208m'
readonly MAGENTA='\033[1;95m'

# ---------------- Utility Functions ----------------
log_info()    { echo -e "${CYAN}[ℹ]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }
log_debug()   { echo -e "${GRAY}[DEBUG]${NC} $1"; }

draw_line() {
    local char="${1:-=}" color="${2:-$BLUE}"
    printf "${color}%*s${NC}\n" "$WIDTH" "" | tr " " "$char"
}

print_center() {
    local text="$1" color="${2:-$WHITE}"
    local len=${#text} pad=$(((WIDTH - len) / 2))
    printf "${BLUE}│${NC}%*s${color}%s${NC}%*s${BLUE}│${NC}\n" "$pad" "" "$text" "$((WIDTH - len - pad))" ""
}

print_option() {
    local num="$1" text="$2" color="${3:-$WHITE}"
    printf "${BLUE}│${NC}  ${CYAN}[%2s]${NC} ${color}%-52s${NC} ${BLUE}│${NC}\n" "$num" "$text"
}

print_header() {
    clear
    draw_line "="
    print_center "╔══════════════════════════════════════════╗" "$PURPLE"
    print_center "║    ██╗  ██╗███████╗    ██╗  ██╗███████╗   ║" "$PURPLE"
    print_center "║   ██║ ██╔╝██╔════╝    ██║ ██╔╝██╔════╝   ║" "$PURPLE"
    print_center "║   █████╔╝ ███████╗    █████╔╝ ███████╗   ║" "$PURPLE"
    print_center "║   ██╔═██╗ ╚════██║    ██╔═██╗ ╚════██║   ║" "$PURPLE"
    print_center "║   ██║  ██╗███████║    ██║  ██╗███████║   ║" "$PURPLE"
    print_center "║   ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝   ║" "$PURPLE"
    print_center "╚══════════════════════════════════════════╝" "$PURPLE"
    print_center "KS HOSTING SUITE v$VERSION" "$CYAN"
    print_center "Enterprise Panel Management Platform" "$GRAY"
    draw_line "="
    print_center "Repository: $GH_USER/$GH_REPO" "$GRAY"
    print_center "User: $(whoami) | Host: $(hostname -s)" "$GRAY"
    print_center "IP: $(ip route get 1 | awk '{print $7}' | head -1)" "$GRAY"
    draw_line "="
}

# ---------------- Animation System ----------------
play_chime() {
    for _ in {1..3}; do
        printf "\a"
        sleep 0.05
    done
}

neon_border() {
    local colors=("\033[1;95m" "\033[1;96m" "\033[1;92m" "\033[1;93m" "\033[1;94m")
    local border line=""
    for ((i=0; i<WIDTH; i++)); do line+="═"; done
    
    for cycle in {1..2}; do
        for color in "${colors[@]}"; do
            printf "\r${color}%s${NC}" "$line"
            sleep 0.03
        done
    done
    printf "\n"
}

progress_bar() {
    local duration="${1:-2}"
    local width=50
    local increment=$((100 / width))
    
    for ((i=0; i<=width; i++)); do
        printf "\r${GREEN}["
        for ((j=0; j<i; j++)); do printf "█"; done
        for ((j=i; j<width; j++)); do printf "░"; done
        printf "] %3d%%${NC}" $((i * increment))
        sleep "$(bc <<< "scale=3; $duration/$width")"
    done
    printf "\n"
}

transition_screen() {
    play_chime
    printf "\n${CYAN}Initializing module..."
    progress_bar 0.8
    printf "${NC}\n"
}

# ---------------- Execution Wrapper ----------------
execute_task() {
    local description="$1"
    local command="$2"
    
    printf "\n${CYAN}▶ ${description}...${NC}\n"
    printf "${GRAY}Executing: ${command:0:60}...${NC}\n"
    
    # Start progress indicator in background
    (
        while true; do
            for s in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
                printf "\r${CYAN}%s${NC} Processing" "$s"
                sleep 0.08
            done
        done
    ) & spinner_pid=$!
    
    # Execute command
    set +e
    eval "$command" > /tmp/ksh_install.log 2>&1
    local exit_code=$?
    set -e
    
    # Stop spinner
    kill "$spinner_pid" 2>/dev/null || true
    wait "$spinner_pid" 2>/dev/null || true
    
    printf "\r"
    if [ $exit_code -eq 0 ]; then
        printf "${GREEN}✓ ${description} completed successfully${NC}\n"
        return 0
    else
        printf "${RED}✗ ${description} failed (code: ${exit_code})${NC}\n"
        log_debug "Last 5 lines of output:"
        tail -5 /tmp/ksh_install.log | while read line; do log_debug "  $line"; done
        return $exit_code
    fi
}

# ---------------- Boot Sequence ----------------
boot_sequence() {
    clear
    neon_border
    
    # ASCII Art Animation
    local frames=(
        "   ██╗  ██╗███████╗    ██╗  ██╗███████╗"
        "  ██║ ██╔╝██╔════╝    ██║ ██╔╝██╔════╝"
        "  █████╔╝ ███████╗    █████╔╝ ███████╗"
        "  ██╔═██╗ ╚════██║    ██╔═██╗ ╚════██║"
        "  ██║  ██╗███████║    ██║  ██╗███████║"
        "  ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝"
    )
    
    for frame in "${frames[@]}"; do
        printf "  ${PURPLE}${frame}${NC}\n"
        sleep 0.1
    done
    
    printf "\n${CYAN}      KS HOSTING - Enterprise Edition${NC}\n"
    printf "${GRAY}      Initializing control systems...${NC}\n\n"
    
    progress_bar 1.5
    sleep 0.3
}

# ---------------- Blueprint Management ----------------
blueprint_manager() {
    while true; do
        print_header
        print_center "BLUEPRINT MANAGEMENT SYSTEM" "$CYAN"
        draw_line "-"
        print_option "1" "Install Framework"
        print_option "2" "Addon Marketplace"
        print_option "3" "Update All Extensions"
        print_option "4" "Developer Mode"
        print_option "5" "Remove Addon"
        print_option "6" "Uninstall Framework" "$RED"
        draw_line "-"
        print_option "0" "Return to Main Menu" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select option [0-6]: ${NC}")" choice
        
        case $choice in
            1)
                transition_screen
                execute_task "Installing Blueprint Framework" \
                    "mkdir -p '$PANEL_DIR' && cd '$PANEL_DIR' && wget -q 'https://raw.githubusercontent.com/kiruthik123/panelinstaler/main/blueprint-installer.sh' -O blueprint-installer.sh && chmod +x blueprint-installer.sh && ./blueprint-installer.sh"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            2) addon_marketplace ;;
            3)
                transition_screen
                execute_task "Updating Blueprint extensions" \
                    "cd '$PANEL_DIR' && blueprint -upgrade"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            4)
                transition_screen
                execute_task "Enabling Developer Mode" \
                    "[ -f '$PANEL_DIR/.env' ] && sed -i 's/APP_ENV=production/APP_ENV=local/g' '$PANEL_DIR/.env' || echo 'Environment file not found'"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            5) remove_addon ;;
            6)
                print_header
                print_center "UNINSTALL BLUEPRINT FRAMEWORK" "$RED"
                draw_line "-"
                read -p "$(echo -e "${YELLOW}Type 'CONFIRM' to proceed: ${NC}")" confirm
                if [[ "$confirm" == "CONFIRM" ]]; then
                    transition_screen
                    execute_task "Removing Blueprint Framework" \
                        "rm -rf /usr/local/bin/blueprint '$PANEL_DIR/blueprint'"
                fi
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            0) return ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Addon Marketplace ----------------
addon_marketplace() {
    while true; do
        print_header
        print_center "ADDON MARKETPLACE" "$MAGENTA"
        draw_line "-"
        print_center "━ THEMES ━" "$ORANGE"
        print_option "1" "Recolor Theme"
        print_option "2" "Sidebar Theme"
        print_option "3" "Server Backgrounds"
        print_option "4" "Euphoria Theme"
        print_center "━ UTILITIES ━" "$ORANGE"
        print_option "5" "Minecraft Tools Suite"
        print_option "6" "Minecraft Live Console"
        print_option "7" "Player Listing"
        print_option "8" "Votifier Tester"
        print_option "9" "Database Editor"
        print_option "10" "Subdomain Manager"
        draw_line "-"
        print_option "0" "Back to Blueprint Manager" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select addon [0-10]: ${NC}")" choice
        
        case $choice in
            0) return ;;
            [1-9]|10)
                local addons=("" "recolor.blueprint" "sidebar.blueprint" "serverbackgrounds.blueprint" \
                    "euphoriatheme.blueprint" "mctools.blueprint" "mclogs.blueprint" \
                    "playerlisting.blueprint" "votifiertester.blueprint" "dbedit.blueprint" \
                    "subdomains.blueprint")
                local names=("" "Recolor Theme" "Sidebar Theme" "Server Backgrounds" \
                    "Euphoria Theme" "Minecraft Tools" "Minecraft Live Console" \
                    "Player Listing" "Votifier Tester" "Database Editor" "Subdomain Manager")
                
                transition_screen
                execute_task "Installing ${names[$choice]}" \
                    "cd '$PANEL_DIR' && wget -q '$BASE_URL/${addons[$choice]}' -O '${addons[$choice]}' && blueprint -install '${addons[$choice]}' && rm -f '${addons[$choice]}'"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Panel Installation Hub ----------------
panel_hub() {
    while true; do
        print_header
        print_center "PANEL INSTALLATION HUB" "$YELLOW"
        draw_line "-"
        print_option "1" "Pterodactyl Panel (Game Hosting)" "$GREEN"
        print_option "2" "PufferPanel (Game Hosting)" "$GREEN"
        print_option "3" "MythicalDash (Web Dashboard)" "$CYAN"
        print_option "4" "Skyport Panel (Web Dashboard)" "$CYAN"
        print_option "5" "AirLink Panel (Game Hosting)" "$GREEN"
        draw_line "-"
        print_option "0" "Return to Main Menu" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select panel [0-5]: ${NC}")" choice
        
        case $choice in
            1) install_pterodactyl ;;
            2) 
                transition_screen
                execute_task "Installing PufferPanel" \
                    "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/pufferpanel/main/Install.sh)"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            3)
                transition_screen
                execute_task "Installing MythicalDash" \
                    "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/mythicaldash/main/install.sh)"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            4)
                transition_screen
                execute_task "Installing Skyport Panel" \
                    "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/skyport/main/install.sh)"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            5)
                transition_screen
                execute_task "Installing AirLink Panel" \
                    "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/airlink/main/install.sh)"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            0) return ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# ---------------- System Toolbox ----------------
system_toolbox() {
    while true; do
        print_header
        print_center "SYSTEM TOOLBOX" "$ORANGE"
        draw_line "-"
        print_center "━ NETWORK ━" "$CYAN"
        print_option "1" "Auto Port Configuration"
        print_option "2" "Firewall Management (UFW)"
        print_option "3" "Cloudflare Tunnel Setup"
        print_option "4" "Tailscale VPN Manager"
        print_center "━ SECURITY ━" "$CYAN"
        print_option "5" "SSL Certificate (Certbot)"
        print_option "6" "SSH Configuration"
        print_option "7" "Root Access Management"
        print_center "━ MAINTENANCE ━" "$CYAN"
        print_option "8" "System Resources Monitor"
        print_option "9" "Swap Memory Configuration"
        print_option "10" "Database Backup Utility"
        print_option "11" "Network Speed Test"
        draw_line "-"
        print_option "0" "Return to Main Menu" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select tool [0-11]: ${NC}")" choice
        
        case $choice in
            1) port_configurator ;;
            2)
                transition_screen
                execute_task "Configuring UFW Firewall" \
                    "apt-get update && apt-get install -y ufw && ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw allow 8080/tcp && ufw --force enable"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            3) cloudflare_manager ;;
            4) tailscale_manager ;;
            5)
                read -p "$(echo -e "${YELLOW}Enter domain name: ${NC}")" domain
                transition_screen
                execute_task "Obtaining SSL Certificate for $domain" \
                    "apt-get update && apt-get install -y certbot && certbot certonly --standalone -d '$domain' --non-interactive --agree-tos"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            6)
                transition_screen
                execute_task "Installing SSHX Web Terminal" \
                    "curl -sSf https://sshx.io/get | sh"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            7)
                transition_screen
                execute_task "Configuring Root Access" \
                    "passwd root && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && systemctl restart sshd"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            8)
                print_header
                print_center "SYSTEM RESOURCES" "$CYAN"
                draw_line "-"
                printf "${BLUE}│${NC}${GREEN} Memory:${NC} "; free -h | awk '/^Mem:/ {print $3 "/" $2}'
                printf "${BLUE}│${NC}${GREEN} Storage:${NC} "; df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}'
                printf "${BLUE}│${NC}${GREEN} CPU Load:${NC} "; uptime | awk -F'load average:' '{print $2}'
                printf "${BLUE}│${NC}${GREEN} Uptime:${NC} "; uptime -p
                draw_line "-"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            9)
                transition_screen
                execute_task "Configuring 2GB Swap Memory" \
                    "fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && echo '/swapfile none swap sw 0 0' >> /etc/fstab"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            10)
                read -p "$(echo -e "${YELLOW}MySQL Root Password: ${NC}")" -s sql_pass
                echo
                transition_screen
                execute_task "Creating Database Backup" \
                    "mysqldump -u root -p'$sql_pass' --all-databases > /root/db_backup_$(date +%Y%m%d_%H%M%S).sql"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            11)
                transition_screen
                execute_task "Running Network Speed Test" \
                    "apt-get update && apt-get install -y speedtest-cli && speedtest-cli --simple"
                read -p "$(echo -e "${GRAY}Press Enter to continue...${NC}")" ;;
            0) return ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Main Menu ----------------
main_menu() {
    while true; do
        print_header
        print_center "MAIN CONTROL PANEL" "$GREEN"
        draw_line "-"
        print_option "1" "Panel Installation Hub" "$YELLOW"
        print_option "2" "Blueprint & Addon Manager" "$MAGENTA"
        print_option "3" "System Toolbox" "$ORANGE"
        draw_line "-"
        print_option "0" "Exit KS Hosting Suite" "$RED"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Enter selection [0-3]: ${NC}")" choice
        
        case $choice in
            1) transition_screen; panel_hub ;;
            2) transition_screen; blueprint_manager ;;
            3) transition_screen; system_toolbox ;;
            0) 
                printf "\n${GREEN}Thank you for using KS Hosting Suite${NC}\n"
                printf "${GRAY}Shutting down services...${NC}\n"
                progress_bar 0.8
                clear
                exit 0 ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Execution ----------------
if [[ $EUID -ne 0 ]]; then
    log_error "This installer must be run as root"
    exit 1
fi

trap 'log_error "Installation interrupted"; exit 130' INT TERM

boot_sequence
main_menu
