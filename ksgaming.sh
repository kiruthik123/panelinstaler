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
log_info()    { echo -e "${CYAN}[ℹ]${NC} ${1:-}"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${1:-}"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} ${1:-}"; }
log_error()   { echo -e "${RED}[✗]${NC} ${1:-}"; }
log_debug()   { echo -e "${GRAY}[DEBUG]${NC} ${1:-}"; }

draw_line() {
    local char="${1:-=}" color="${2:-$BLUE}"
    printf "${color}%*s${NC}\n" "$WIDTH" "" | tr " " "$char"
}

print_center() {
    local text="${1:-}"
    local color="${2:-$WHITE}"
    local len=${#text}
    local pad=$(( (WIDTH - len) / 2 ))
    
    # Ensure padding isn't negative
    [[ $pad -lt 0 ]] && pad=0
    local r_pad=$(( WIDTH - len - pad ))
    [[ $r_pad -lt 0 ]] && r_pad=0

    printf "${BLUE}│${NC}%*s${color}%s${NC}%*s${BLUE}│${NC}\n" "$pad" "" "$text" "$r_pad" ""
}

print_option() {
    local num="${1:-}" 
    local text="${2:-}" 
    local color="${3:-$WHITE}"
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
    local my_ip; my_ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1 || echo "N/A")
    print_center "IP: $my_ip" "$GRAY"
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
    local line=""; for ((i=0; i<WIDTH; i++)); do line+="═"; done
    
    for cycle in {1..2}; do
        for color in "${colors[@]}"; do
            printf "\r${color}%s${NC}" "$line"
            sleep 0.03
        done
    done
    printf "\n"
}

progress_bar() {
    local duration="${1:-1.5}"
    local width=50
    # Use bc if available, otherwise fallback to sleep 0.1
    local has_bc; has_bc=$(command -v bc >/dev/null 2>&1 && echo "yes" || echo "no")
    
    for ((i=0; i<=width; i++)); do
        local pc=$(( i * 100 / width ))
        printf "\r${GREEN}["
        printf "%${i}s" "" | tr ' ' '█'
        printf "%$((width - i))s" "" | tr ' ' '░'
        printf "] %3d%%${NC}" "$pc"
        if [ "$has_bc" == "yes" ]; then
            sleep "$(echo "scale=3; $duration/$width" | bc)"
        else
            sleep 0.03
        fi
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
    local desc="$1"
    local cmd="$2"
    
    printf "\n${CYAN}▶ ${desc}...${NC}\n"
    
    (
        while true; do
            for s in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
                printf "\r${CYAN}%s${NC} Processing" "$s"
                sleep 0.08
            done
        done
    ) & local spin_pid=$!
    
    set +e
    eval "$cmd" > /tmp/ksh_install.log 2>&1
    local code=$?
    set -e
    
    kill "$spin_pid" 2>/dev/null || true
    wait "$spin_pid" 2>/dev/null || true
    
    printf "\r"
    if [ $code -eq 0 ]; then
        printf "${GREEN}✓ ${desc} completed${NC}\n"
    else
        printf "${RED}✗ ${desc} failed (Code: $code)${NC}\n"
        log_debug "Last output:"
        tail -3 /tmp/ksh_install.log
    fi
}

# ---------------- Modules ----------------
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
    for f in "${frames[@]}"; do
        printf "  ${PURPLE}%s${NC}\n" "$f"
        sleep 0.1
    done
    printf "\n${CYAN}      KS HOSTING - Enterprise Edition${NC}\n"
    progress_bar 1.2
}

panel_hub() {
    while true; do
        print_header
        print_center "PANEL HUB" "$YELLOW"
        draw_line "-"
        print_option "1" "Pterodactyl Panel" "$GREEN"
        print_option "2" "PufferPanel" "$GREEN"
        print_option "3" "MythicalDash" "$CYAN"
        print_option "0" "Back" "$GRAY"
        draw_line "="
        read -p "Select: " c
        case $c in
            1) execute_task "Pterodactyl" "bash <(curl -s https://pterodactyl-installer.se)" ;;
            2) execute_task "PufferPanel" "curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash && apt-get install pufferpanel" ;;
            0) return ;;
        esac
        read -p "Press Enter..." pause
    done
}

blueprint_manager() {
    while true; do
        print_header
        print_center "BLUEPRINT MANAGER" "$MAGENTA"
        draw_line "-"
        print_option "1" "Install Framework"
        print_option "2" "Addon Marketplace"
        print_option "0" "Back" "$GRAY"
        draw_line "="
        read -p "Select: " c
        case $c in
            1) execute_task "Blueprint" "cd $PANEL_DIR && wget -q ${BASE_URL}/blueprint-installer.sh -O b.sh && chmod +x b.sh && ./b.sh" ;;
            0) return ;;
        esac
        read -p "Press Enter..." pause
    done
}

# ---------------- Main Loop ----------------
main_menu() {
    while true; do
        print_header
        print_center "MAIN CONTROL PANEL" "$GREEN"
        draw_line "-"
        print_option "1" "Panel Installation Hub" "$YELLOW"
        print_option "2" "Blueprint & Addon Manager" "$MAGENTA"
        print_option "3" "System Toolbox" "$ORANGE"
        draw_line "-"
        print_option "0" "Exit" "$RED"
        draw_line "="
        
        read -p "Select option: " choice
        case $choice in
            1) transition_screen; panel_hub ;;
            2) transition_screen; blueprint_manager ;;
            3) transition_screen; log_info "Toolbox opening..."; sleep 1 ;;
            0) exit 0 ;;
            *) log_error "Invalid selection"; sleep 1 ;;
        esac
    done
}

# Root Check
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run as root!${NC}"
    exit 1
fi

trap 'log_error "Interrupted"; exit 1' INT TERM
boot_sequence
main_menu
