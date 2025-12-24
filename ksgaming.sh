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
    print_center "IP: $(ip route get 1 2>/dev/null | awk '{print $7}' | head -1 || echo 'N/A')" "$GRAY"
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
    local steps=50
    
    for ((i=0; i<=steps; i++)); do
        local percent=$((i * 100 / steps))
        local filled=$((i * width / steps))
        local empty=$((width - filled))
        printf "\r${GREEN}["
        printf "%${filled}s" "" | tr ' ' '█'
        printf "%${empty}s" "" | tr ' ' '░'
        printf "] %3d%%${NC}" "$percent"
        sleep "$(bc -l <<< "$duration/$steps")"
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
    printf "${GRAY}Executing command context...${NC}\n"
    
    (
        while true; do
            for s in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
                printf "\r${CYAN}%s${NC} Processing" "$s"
                sleep 0.08
            done
        done
    ) & spinner_pid=$!
    
    set +e
    eval "$command" > /tmp/ksh_install.log 2>&1
    local exit_code=$?
    set -e
    
    kill "$spinner_pid" 2>/dev/null || true
    wait "$spinner_pid" 2>/dev/null || true
    
    printf "\r"
    if [ $exit_code -eq 0 ]; then
        printf "${GREEN}✓ ${description} completed successfully${NC}\n"
        return 0
    else
        printf "${RED}✗ ${description} failed (code: ${exit_code})${NC}\n"
        log_debug "Last 5 lines of output:"
        tail -5 /tmp/ksh_install.log | while read -r line; do log_debug "  $line"; done
        return $exit_code
    fi
}

# ---------------- Boot Sequence ----------------
boot_sequence() {
    clear
    neon_border
    local frames=(
        "    ██╗  ██╗███████╗    ██╗  ██╗███████╗"
        "   ██║ ██╔╝██╔════╝    ██║ ██╔╝██╔════╝"
        "   █████╔╝ ███████╗    █████╔╝ ███████╗"
        "   ██╔═██╗ ╚════██║    ██╔═██╗ ╚════██║"
        "   ██║  ██╗███████║    ██║  ██╗███████║"
        "   ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝"
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

# ---------------- Module: Panels ----------------
panel_hub() {
    while true; do
        print_header
        print_center "PANEL INSTALLATION HUB" "$YELLOW"
        draw_line "-"
        print_option "1" "Pterodactyl Panel (Full Install)" "$GREEN"
        print_option "2" "PufferPanel" "$GREEN"
        print_option "3" "MythicalDash" "$CYAN"
        print_option "4" "Skyport Panel" "$CYAN"
        print_option "5" "AirLink Panel" "$GREEN"
        draw_line "-"
        print_option "0" "Return to Main Menu" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select option: ${NC}")" choice
        case $choice in
            1) transition_screen; execute_task "Installing Pterodactyl" "bash <(curl -s https://pterodactyl-installer.se)" ;;
            2) transition_screen; execute_task "Installing PufferPanel" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/pufferpanel/main/Install.sh)" ;;
            3) transition_screen; execute_task "Installing MythicalDash" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/mythicaldash/main/install.sh)" ;;
            4) transition_screen; execute_task "Installing Skyport" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/skyport/main/install.sh)" ;;
            5) transition_screen; execute_task "Installing AirLink" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/airlink/main/install.sh)" ;;
            0) return ;;
            *) log_error "Invalid selection"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

# ---------------- Module: Blueprints ----------------
blueprint_manager() {
    while true; do
        print_header
        print_center "BLUEPRINT MANAGEMENT SYSTEM" "$CYAN"
        draw_line "-"
        print_option "1" "Install Blueprint Framework"
        print_option "2" "Addon Marketplace"
        print_option "3" "Update All Extensions"
        print_option "4" "Developer Mode Toggle"
        print_option "0" "Return to Main Menu" "$GRAY"
        draw_line "="
        
        read -p "$(echo -e "${CYAN}Select option: ${NC}")" choice
        case $choice in
            1) transition_screen; execute_task "Installing Blueprint" "cd $PANEL_DIR && wget -q ${BASE_URL}/blueprint-installer.sh -O b.sh && chmod +x b.sh && ./b.sh" ;;
            2) addon_marketplace ;;
            3) transition_screen; execute_task "Updating Extensions" "cd $PANEL_DIR && blueprint -upgrade" ;;
            4) transition_screen; execute_task "Toggling Dev Mode" "sed -i 's/APP_ENV=production/APP_ENV=local/g' $PANEL_DIR/.env || echo 'Not found'" ;;
            0) return ;;
        esac
        read -p "Press Enter to continue..."
    done
}

addon_marketplace() {
    while true; do
        print_header
        print_center "ADDON MARKETPLACE" "$MAGENTA"
        draw_line "-"
        print_option "1" "Recolor Theme"
        print_option "2" "Sidebar Theme"
        print_option "3" "Server Backgrounds"
        print_option "0" "Back" "$GRAY"
        draw_line "="
        read -p "Select Addon: " choice
        case $choice in
            0) return ;;
            1) execute_task "Installing Recolor" "cd $PANEL_DIR && blueprint -install recolor.blueprint" ;;
            *) log_warn "Selection not yet implemented" ; sleep 1 ;;
        esac
    done
}

# ---------------- Module: Toolbox ----------------
system_toolbox() {
    while true; do
        print_header
        print_center "SYSTEM TOOLBOX" "$ORANGE"
        draw_line "-"
        print_option "1" "UFW Firewall Setup"
        print_option "2" "SSL (Certbot)"
        print_option "3" "System Resource Monitor"
        print_option "4" "Create 2GB Swap"
        print_option "0" "Return" "$GRAY"
        draw_line "="
        read -p "Select Tool: " choice
        case $choice in
            1) execute_task "Firewall" "apt install -y ufw && ufw allow 22,80,443/tcp && ufw --force enable" ;;
            3) print_header; free -h; df -h; read -p "Enter..." ;;
            4) execute_task "Swap" "fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile" ;;
            0) return ;;
        esac
    done
}

# ---------------- Main Logic ----------------
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
            0) clear; exit 0 ;;
            *) log_error "Invalid selection"; sleep 0.5 ;;
        esac
    done
}

if [[ $EUID -ne 0 ]]; then
    log_error "This installer must be run as root"
    exit 1
fi

trap 'log_error "Installation interrupted"; exit 130' INT TERM
boot_sequence
main_menu
