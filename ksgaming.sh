#!/usr/bin/env bash
# =================================================================================
# 🚀 KSGAMING HOSTING SUITE - ULTIMATE INSTALLATION MANAGER
# ⭐ Version: 4.0.0 | 🌟 Environment: Enterprise | 🔐 Security: Military-Grade
# ⚡ Copyright © 2024 KSGAMING. All Rights Reserved.
# 🎮 Professional Game Hosting Solutions | 🏆 Enterprise Ready
# =================================================================================

set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'

# ============================ 🌟 CONFIGURATION ============================
readonly CONFIG_FILE="/etc/ksgaming/config.conf"
readonly LOG_FILE="/var/log/ksgaming/installer.log"
readonly BRAND_NAME="KSGAMING"
readonly BRAND_TAGLINE="Professional Game Hosting"
readonly VERSION="4.0.0"
readonly TERM_WIDTH=72

# Repository Configuration
declare -A REPOSITORIES=(
    ["MAIN"]="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"
    ["INSTALLER"]="https://raw.githubusercontent.com/kiruthik123/installer/main"
    ["BLUEPRINT"]="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"
    ["ADDONS"]="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"
)

# Application Paths
readonly PANEL_DIR="/var/www/pterodactyl"
readonly WINGS_DIR="/etc/pterodactyl"

# ============================ 🎨 COLOR SYSTEM ============================
declare -A COLORS=(
    ["RESET"]=$'\033[0m'
    ["BLACK"]=$'\033[0;30m'
    ["RED"]=$'\033[1;31m'
    ["GREEN"]=$'\033[1;32m'
    ["YELLOW"]=$'\033[1;33m'
    ["BLUE"]=$'\033[1;34m'
    ["MAGENTA"]=$'\033[1;35m'
    ["CYAN"]=$'\033[1;36m'
    ["WHITE"]=$'\033[1;37m'
    ["ORANGE"]=$'\033[1;38;5;208m'
    ["PURPLE"]=$'\033[1;38;5;93m'
    ["PINK"]=$'\033[1;38;5;199m'
    ["NEON_BLUE"]=$'\033[1;38;5;45m'
    ["NEON_GREEN"]=$'\033[1;38;5;46m'
    ["NEON_PINK"]=$'\033[1;38;5;201m'
    ["GOLD"]=$'\033[1;38;5;220m'
    ["SILVER"]=$'\033[1;38;5;250m'
)

# ============================ 🎮 EMOJI SET ================================
declare -A EMOJI=(
    ["SUCCESS"]="✅"
    ["ERROR"]="❌"
    ["WARNING"]="⚠️"
    ["INFO"]="ℹ️"
    ["LOADING"]="⏳"
    ["DOWNLOAD"]="📥"
    ["INSTALL"]="🔧"
    ["CONFIGURE"]="⚙️"
    ["SECURITY"]="🔐"
    ["NETWORK"]="🌐"
    ["DATABASE"]="🗄️"
    ["BACKUP"]="💾"
    ["RESTART"]="🔄"
    ["ROCKET"]="🚀"
    ["STAR"]="⭐"
    ["FIRE"]="🔥"
    ["GEM"]="💎"
    ["CROWN"]="👑"
    ["TROPHY"]="🏆"
    ["MEDAL"]="🏅"
    ["SHIELD"]="🛡️"
    ["TOOLS"]="🛠️"
    ["CLOUD"]="☁️"
    ["SERVER"]="🖥️"
    ["GLOBE"]="🌍"
    ["LIGHTNING"]="⚡"
    ["KEY"]="🔑"
    ["LOCK"]="🔒"
    ["UNLOCK"]="🔓"
    ["BELL"]="🔔"
    ["MUSIC"]="🎵"
    ["GAME"]="🎮"
    ["PARTY"]="🎉"
    ["CHECK"]="✔️"
    ["CROSS"]="✖️"
    ["HOURGLASS"]="⏳"
    ["CLOCK"]="🕐"
    ["CALENDAR"]="📅"
    ["FOLDER"]="📁"
    ["FILE"]="📄"
    ["GEAR"]="⚙️"
    ["HAMMER"]="🔨"
    ["WRENCH"]="🔧"
    ["SCREWDRIVER"]="🪛"
    ["PLUG"]="🔌"
    ["BATTERY"]="🔋"
    ["MAGNIFY"]="🔍"
    ["FLAG"]="🚩"
    ["WARNING"]="🚨"
    ["BULB"]="💡"
    ["HEART"]="❤️"
    ["DIAMOND"]="💎"
    ["SPARKLE"]="✨"
    ["COMET"]="☄️"
    ["SATELLITE"]="🛰️"
    ["ALIEN"]="👽"
    ["ROBOT"]="🤖"
    ["WIZARD"]="🧙"
    ["NINJA"]="🥷"
    ["PIRATE"]="🏴‍☠️"
)

# ============================ 📊 LOGGING SYSTEM ==========================
log() {
    local level="$1" message="$2" emoji="${EMOJI[$level]:-📝}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        "SUCCESS") color="${COLORS[GREEN]}" ;;
        "ERROR") color="${COLORS[RED]}" ;;
        "WARNING") color="${COLORS[YELLOW]}" ;;
        "INFO") color="${COLORS[CYAN]}" ;;
        *) color="${COLORS[WHITE]}" ;;
    esac
    
    echo -e "${COLORS[GRAY]}[$timestamp] ${emoji} ${color}$message${COLORS[RESET]}"
    echo "[$timestamp] $level: $message" >> "$LOG_FILE"
}

# ============================ 🎭 ANIMATION ENGINE ========================
show_rocket_launch() {
    clear
    local frames=(
        "          🌌                   "
        "          🚀                   "
        "          🚀 🌠                "
        "          🚀  🌠               "
        "          🚀   🌠              "
        "           🚀    🌠            "
        "            🚀     🌠          "
        "             🚀      🌠        "
        "              🚀       🌠      "
        "               🚀        🌠    "
        "                🚀         🌠  "
        "                 🚀          🌠"
        "                  🚀           "
        "                   🚀          "
        "                    🚀         "
        "                     🚀        "
        "                      🚀       "
        "                       🚀      "
    )
    
    for frame in "${frames[@]}"; do
        clear
        echo -e "\n\n\n"
        echo -e "          ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[RESET]}"
        echo -e "          ${COLORS[NEON_PINK]}▓▓                            ▓▓${COLORS[RESET]}"
        echo -e "          ${COLORS[NEON_PINK]}▓▓   ${COLORS[NEON_BLUE]}KSGAMING HOSTING SUITE${COLORS[NEON_PINK]}   ▓▓${COLORS[RESET]}"
        echo -e "          ${COLORS[NEON_PINK]}▓▓                            ▓▓${COLORS[RESET]}"
        echo -e "          ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[RESET]}\n"
        echo -e "          ${frame}"
        echo -e "\n${COLORS[NEON_GREEN]}          Initializing Quantum Core...${COLORS[RESET]}"
        sleep 0.08
    done
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='🌑🌒🌓🌔🌕🌖🌗🌘'
    
    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 7); do
            echo -ne "\r${COLORS[NEON_PINK]}${spinstr:$i:1}${COLORS[RESET]} $2"
            sleep $delay
        done
    done
    echo -ne "\r${COLORS[GREEN]}${EMOJI[SUCCESS]}${COLORS[RESET]} $2\n"
}

neon_rainbow_border() {
    local colors=("${COLORS[NEON_PINK]}" "${COLORS[NEON_BLUE]}" "${COLORS[NEON_GREEN]}" "${COLORS[YELLOW]}" "${COLORS[PURPLE]}")
    local border="╔════════════════════════════════════════════════════════════════════╗"
    
    for color in "${colors[@]}"; do
        printf "\r${color}%s${COLORS[RESET]}" "$border"
        sleep 0.05
    done
    printf "\n"
}

pulse_logo() {
    local colors=("${COLORS[NEON_PINK]}" "${COLORS[NEON_BLUE]}" "${COLORS[GOLD]}" "${COLORS[NEON_GREEN]}")
    local logo=(
        "${COLORS[NEON_PINK]}╔═╗${COLORS[NEON_BLUE]}╔═╗${COLORS[GOLD]}╔═╗${COLORS[NEON_GREEN]}╔═╗${COLORS[NEON_PINK]}╔═╗${COLORS[NEON_BLUE]}╦ ╦${COLORS[GOLD]}╔═╗${COLORS[NEON_GREEN]}╦ ╦"
        "${COLORS[NEON_PINK]}╠═╝${COLORS[NEON_BLUE]}╠═╣${COLORS[GOLD]}║  ${COLORS[NEON_GREEN]}╠═╣${COLORS[NEON_PINK]}║ ║${COLORS[NEON_BLUE]}╠═╣${COLORS[GOLD]}║ ║${COLORS[NEON_GREEN]}║║║"
        "${COLORS[NEON_PINK]}╩  ${COLORS[NEON_BLUE]}╩ ╩${COLORS[GOLD]}╚═╝${COLORS[NEON_GREEN]}╩ ╩${COLORS[NEON_PINK]}╚═╝${COLORS[NEON_BLUE]}╩ ╩${COLORS[GOLD]}╚═╝${COLORS[NEON_GREEN]}╚╩╝"
    )
    
    for i in {1..3}; do
        for color in "${colors[@]}"; do
            clear
            echo -e "\n\n"
            for line in "${logo[@]}"; do
                echo -e "          $line"
            done
            echo -e "\n          ${color}██╗  ██╗███████╗    ███████╗ █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ ${COLORS[RESET]}"
            echo -e "          ${color}╚██╗██╔╝██╔════╝    ██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔════╝ ${COLORS[RESET]}"
            echo -e "          ${color} ╚███╔╝ ███████╗    ███████╗███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗${COLORS[RESET]}"
            echo -e "          ${color} ██╔██╗ ╚════██║    ╚════██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║${COLORS[RESET]}"
            echo -e "          ${color}██╔╝ ██╗███████║    ███████║██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝${COLORS[RESET]}"
            echo -e "          ${color}╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ${COLORS[RESET]}"
            echo -e "\n          ${color}${EMOJI[ROCKET]} ${BRAND_NAME} ${EMOJI[CROWN]} ${BRAND_TAGLINE} ${EMOJI[LIGHTNING]}${COLORS[RESET]}"
            sleep 0.1
        done
    done
}

quantum_loader() {
    local message="$1"
    local i=0
    local dots=""
    
    echo -ne "\r${COLORS[NEON_BLUE]}${EMOJI[SATELLITE]}${COLORS[RESET]} ${message}"
    
    while true; do
        case $((i % 4)) in
            0) echo -ne "\r${COLORS[NEON_BLUE]}${EMOJI[SATELLITE]}${COLORS[RESET]} ${message}${COLORS[NEON_PINK]}.  ${COLORS[RESET]}" ;;
            1) echo -ne "\r${COLORS[NEON_BLUE]}${EMOJI[SATELLITE]}${COLORS[RESET]} ${message}${COLORS[NEON_PINK]}.. ${COLORS[RESET]}" ;;
            2) echo -ne "\r${COLORS[NEON_BLUE]}${EMOJI[SATELLITE]}${COLORS[RESET]} ${message}${COLORS[NEON_PINK]}...${COLORS[RESET]}" ;;
            3) echo -ne "\r${COLORS[NEON_BLUE]}${EMOJI[SATELLITE]}${COLORS[RESET]} ${message}${COLORS[NEON_PINK]}   ${COLORS[RESET]}" ;;
        esac
        i=$((i + 1))
        sleep 0.2
    done
}

# ============================ 🎪 UI COMPONENTS ===========================
draw_banner() {
    echo -e "${COLORS[NEON_PINK]}╔════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}                                                                    ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[GOLD]}${EMOJI[CROWN]} ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_BLUE]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[GOLD]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_PINK]}${EMOJI[CROWN]}${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓${COLORS[NEON_BLUE]}▓▓▓▓▓▓▓▓▓▓${COLORS[GOLD]}▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_GREEN]}▓▓▓▓▓▓▓▓▓▓${COLORS[PURPLE]}▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_PINK]}▓▓${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓${COLORS[NEON_BLUE]}▓▓${COLORS[RESET]} ${COLORS[NEON_BLUE]}${EMOJI[ROCKET]} KSGAMING${COLORS[RESET]} ${COLORS[NEON_BLUE]}▓▓${COLORS[GOLD]}▓▓${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[CROWN]} HOSTING${COLORS[RESET]} ${COLORS[GOLD]}▓▓${COLORS[NEON_GREEN]}▓▓${COLORS[RESET]} ${COLORS[NEON_GREEN]}${EMOJI[LIGHTNING]} SUITE${COLORS[RESET]} ${COLORS[NEON_GREEN]}▓▓${COLORS[PURPLE]}▓▓${COLORS[RESET]}  ${COLORS[PURPLE]}${EMOJI[STAR]}${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓${COLORS[NEON_BLUE]}▓▓▓▓▓▓▓▓▓▓${COLORS[GOLD]}▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_GREEN]}▓▓▓▓▓▓▓▓▓▓${COLORS[PURPLE]}▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_PINK]}▓▓${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}  ${COLORS[GOLD]}${EMOJI[CROWN]} ${COLORS[NEON_PINK]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_BLUE]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[GOLD]}▓▓▓▓▓▓▓▓▓▓▓▓▓▓${COLORS[NEON_PINK]}${EMOJI[CROWN]}${COLORS[RESET]}  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}                                                                    ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
}

draw_header() {
    clear
    neon_rainbow_border
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_BLUE]}                     _  __     _                       ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_BLUE]}     /\\/\\   ___  ___| |/ /___ (_) ___  _ __   __ _    ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_BLUE]}    /    \\ / _ \\/ __| ' // _ \\| |/ _ \\| '_ \\ / _\` |   ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_BLUE]}   / /\\/\\ \\  __/ (__| . \\ (_) | | (_) | | | | (_| |   ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_BLUE]}   \\/    \\/\\___|\\___|_|\\_\\___/|_|\\___/|_| |_|\\__,_|   ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]}${COLORS[NEON_PINK]}                                                        ${COLORS[RESET]}${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[ROCKET]} ${BRAND_NAME} ${EMOJI[CROWN]} ${VERSION} ${EMOJI[LIGHTNING]} ${BRAND_TAGLINE} ${EMOJI[STAR]}${COLORS[RESET]} ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[SILVER]}User: ${USER} ${EMOJI[ALIEN]} Host: $(hostname) ${EMOJI[ROBOT]}${COLORS[RESET]} ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
}

print_menu_option() {
    local number="$1" icon="$2" text="$3" color="${4:-${COLORS[WHITE]}}"
    printf "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_BLUE]}[${COLORS[GOLD]}%2s${COLORS[NEON_BLUE]}]${COLORS[RESET]} ${icon} ${color}%-50s${COLORS[RESET]} ${COLORS[NEON_PINK]}║${COLORS[RESET]}\n" "$number" "$text"
}

draw_separator() {
    echo -e "${COLORS[NEON_PINK]}╠════════════════════════════════════════════════════════════════════╣${COLORS[RESET]}"
}

# ============================ ⚡ EXECUTION ENGINE ========================
execute_with_style() {
    local task="$1" command="$2" icon="${3:-${EMOJI[ROCKET]}}"
    
    # Start the spinner
    quantum_loader "${COLORS[NEON_BLUE]}${icon} ${task}${COLORS[RESET]}" &
    local loader_pid=$!
    
    # Execute command
    eval "$command" > /tmp/ksgaming_task.log 2>&1 &
    local task_pid=$!
    
    # Wait for task
    wait $task_pid
    local exit_code=$?
    
    # Stop loader
    kill $loader_pid 2>/dev/null
    wait $loader_pid 2>/dev/null
    
    # Clear line
    echo -ne "\r\033[K"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${COLORS[GREEN]}${EMOJI[SUCCESS]} ${task} completed successfully! ${EMOJI[PARTY]}${COLORS[RESET]}"
        log "SUCCESS" "Task completed: $task"
    else
        echo -e "${COLORS[RED]}${EMOJI[ERROR]} ${task} failed with code $exit_code ${EMOJI[WARNING]}${COLORS[RESET]}"
        log "ERROR" "Task failed: $task (exit code: $exit_code)"
    fi
    
    return $exit_code
}

# ============================ 🎮 MAIN MENU ===============================
show_main_menu() {
    while true; do
        draw_header
        
        echo -e "${COLORS[NEON_PINK]}╔════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[CROWN]} MAIN CONTROL PANEL ${EMOJI[CROWN]}${COLORS[RESET]}                                  ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}╠════════════════════════════════════════════════════════════════════╣${COLORS[RESET]}"
        
        print_menu_option "1" "${EMOJI[SERVER]}" "🎮 Panel Installation Hub"
        print_menu_option "2" "${EMOJI[TOOLS]}" "✨ Addons & Extensions"
        print_menu_option "3" "${EMOJI[WRENCH]}" "⚡ System Tools"
        print_menu_option "4" "${EMOJI[SHIELD]}" "🔒 Security Center"
        print_menu_option "5" "${EMOJI[CLOUD]}" "🌐 Network Manager"
        print_menu_option "6" "${EMOJI[DATABASE]}" "📊 Database Operations"
        print_menu_option "7" "${EMOJI[BACKUP]}" "💾 Backup & Restore"
        print_menu_option "8" "${EMOJI[MAGNIFY]}" "🔍 System Diagnostics"
        print_menu_option "9" "${EMOJI[GEAR]}" "⚙️ Settings & Config"
        
        draw_separator
        
        print_menu_option "U" "${EMOJI[ROCKET]}" "🚀 Ultra Boost Performance"
        print_menu_option "D" "${EMOJI[NINJA]}" "🥷 Developer Mode"
        print_menu_option "M" "${EMOJI[MUSIC]}" "🎵 Easter Eggs"
        
        draw_separator
        
        print_menu_option "0" "${EMOJI[EXIT]}" "🚪 Exit Suite"
        
        echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
        
        echo -e "\n${COLORS[NEON_GREEN]}${EMOJI[LIGHTNING]} ${COLORS[GOLD]}Select option: ${COLORS[RESET]}"
        echo -ne "${COLORS[NEON_PINK]}┌─(${COLORS[NEON_BLUE]}${USER}${COLORS[NEON_PINK]}@${COLORS[GOLD]}ksgaming${COLORS[NEON_PINK]})─[${COLORS[NEON_GREEN]}~${COLORS[NEON_PINK]}]${COLORS[RESET]} "
        echo -ne "${COLORS[GOLD]}\$${COLORS[RESET]} ${COLORS[NEON_BLUE]}➜ ${COLORS[RESET]}"
        
        read -r choice
        
        case "$choice" in
            1) show_panel_menu ;;
            2) show_addons_menu ;;
            3) show_tools_menu ;;
            4) show_security_menu ;;
            5) show_network_menu ;;
            6) show_database_menu ;;
            7) show_backup_menu ;;
            8) show_diagnostics_menu ;;
            9) show_settings_menu ;;
            U|u) ultra_boost_mode ;;
            D|d) developer_mode ;;
            M|m) easter_eggs_menu ;;
            0) exit_suite ;;
            *) 
                echo -e "${COLORS[RED]}${EMOJI[ERROR]} Invalid selection! Try again.${COLORS[RESET]}"
                sleep 1
                ;;
        esac
    done
}

# ============================ 🎮 PANEL MENU =============================
show_panel_menu() {
    while true; do
        draw_header
        echo -e "${COLORS[NEON_PINK]}╔════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[SERVER]} PANEL INSTALLATION HUB ${EMOJI[ROCKET]}${COLORS[RESET]}                           ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}╠════════════════════════════════════════════════════════════════════╣${COLORS[RESET]}"
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_GREEN]}${EMOJI[CROWN]} PREMIUM GAME PANELS ${EMOJI[GAME]}${COLORS[RESET]}                             ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "1" "${EMOJI[ROCKET]}" "Pterodactyl Panel (Recommended)"
        print_menu_option "2" "${EMOJI[FIRE]}" "PufferPanel"
        print_menu_option "3" "${EMOJI[LIGHTNING]}" "AirLink Panel"
        
        draw_separator
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_BLUE]}${EMOJI[CLOUD]} WEB & CONTROL PANELS ${EMOJI[GLOBE]}${COLORS[RESET]}                          ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "4" "${EMOJI[GEM]}" "MythicalDash"
        print_menu_option "5" "${EMOJI[STAR]}" "SkyPort Panel"
        
        draw_separator
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[PURPLE]}${EMOJI[WRENCH]} MANAGEMENT TOOLS ${EMOJI[TOOLS]}${COLORS[RESET]}                              ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "6" "${EMOJI[HAMMER]}" "Wings Daemon Setup"
        print_menu_option "7" "${EMOJI[SCREWDRIVER]}" "Node Configuration"
        print_menu_option "8" "${EMOJI[PLUG]}" "Plugin Manager"
        
        draw_separator
        
        print_menu_option "B" "${EMOJI[BACK]}" "🔙 Back to Main Menu"
        print_menu_option "0" "${EMOJI[EXIT]}" "🚪 Exit"
        
        echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
        
        echo -ne "\n${COLORS[GOLD]}${EMOJI[KEY]} Choose panel: ${COLORS[RESET]}"
        read -r panel_choice
        
        case "$panel_choice" in
            1) install_pterodactyl ;;
            2) install_pufferpanel ;;
            3) install_airlink ;;
            4) install_mythicaldash ;;
            5) install_skyport ;;
            6) install_wings ;;
            7) configure_node ;;
            8) plugin_manager ;;
            B|b) return ;;
            0) exit_suite ;;
            *) 
                echo -e "${COLORS[RED]}${EMOJI[ERROR]} Invalid choice!${COLORS[RESET]}"
                sleep 1
                ;;
        esac
    done
}

# ============================ ✨ ADDONS MENU =============================
show_addons_menu() {
    while true; do
        draw_header
        echo -e "${COLORS[NEON_PINK]}╔════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[SPARKLE]} ADDONS & EXTENSIONS HUB ${EMOJI[GEM]}${COLORS[RESET]}                         ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        echo -e "${COLORS[NEON_PINK]}╠════════════════════════════════════════════════════════════════════╣${COLORS[RESET]}"
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_PINK]}${EMOJI[DIAMOND]} BLUEPRINT FRAMEWORK ${EMOJI[TOOLS]}${COLORS[RESET]}                             ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "1" "${EMOJI[ROCKET]}" "Install Blueprint Framework"
        print_menu_option "2" "${EMOJI[WRENCH]}" "Update All Extensions"
        print_menu_option "3" "${EMOJI[SCREWDRIVER]}" "Developer Mode"
        
        draw_separator
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_GREEN]}${EMOJI[ART]} THEMES & APPEARANCE ${EMOJI[SPARKLE]}${COLORS[RESET]}                           ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "4" "${EMOJI[RAINBOW]}" "Recolor Theme"
        print_menu_option "5" "${EMOJI[PALETTE]}" "Sidebar Theme"
        print_menu_option "6" "${EMOJI[IMAGE]}" "Server Backgrounds"
        print_menu_option "7" "${EMOJI[NEON]}" "Euphoria Theme"
        print_menu_option "8" "${EMOJI[GLOW]}" "Neon Glow Theme"
        
        draw_separator
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[NEON_BLUE]}${EMOJI[TOOLS]} UTILITIES & TOOLS ${EMOJI[WRENCH]}${COLORS[RESET]}                             ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "9" "${EMOJI[PICKAXE]}" "MC Tools (Editor)"
        print_menu_option "10" "${EMOJI[SCROLL]}" "MC Logs (Live Console)"
        print_menu_option "11" "${EMOJI[PEOPLE]}" "Player Listing"
        print_menu_option "12" "${EMOJI[VOTE]}" "Votifier Tester"
        print_menu_option "13" "${EMOJI[DATABASE]}" "Database Editor"
        print_menu_option "14" "${EMOJI[DOMAIN]}" "Subdomain Manager"
        
        draw_separator
        
        echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[RED]}${EMOJI[WARNING]} MAINTENANCE ${EMOJI[TRASH]}${COLORS[RESET]}                                      ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
        print_menu_option "U" "${EMOJI[UNINSTALL]}" "Uninstall Addon"
        print_menu_option "R" "${EMOJI[REMOVE]}" "Remove Framework"
        
        draw_separator
        
        print_menu_option "B" "${EMOJI[BACK]}" "🔙 Back"
        print_menu_option "0" "${EMOJI[EXIT]}" "🚪 Exit"
        
        echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
        
        echo -ne "\n${COLORS[GOLD]}${EMOJI[KEY]} Select addon: ${COLORS[RESET]}"
        read -r addon_choice
        
        # Handle addon installation logic here
        case "$addon_choice" in
            B|b) return ;;
            0) exit_suite ;;
            *) 
                echo -e "${COLORS[YELLOW]}${EMOJI[WARNING]} Feature coming soon!${COLORS[RESET]}"
                sleep 1
                ;;
        esac
    done
}

# ============================ 🎮 GAME-SPECIFIC FUNCTIONS =================
install_pterodactyl() {
    echo -e "\n${COLORS[GOLD]}${EMOJI[ROCKET]} Launching Pterodactyl Installation ${EMOJI[ROCKET]}${COLORS[RESET]}"
    
    execute_with_style "Downloading installer" \
        "curl -sSL ${REPOSITORIES[INSTALLER]}/install.sh -o /tmp/pterodactyl_install.sh" \
        "${EMOJI[DOWNLOAD]}"
    
    if [[ -f "/tmp/pterodactyl_install.sh" ]]; then
        chmod +x /tmp/pterodactyl_install.sh
        
        echo -e "\n${COLORS[NEON_BLUE]}${EMOJI[CHOOSE]} Select installation type:${COLORS[RESET]}"
        echo -e "  ${COLORS[GREEN]}1${COLORS[RESET]} ${EMOJI[SERVER]} Panel Only"
        echo -e "  ${COLORS[GREEN]}2${COLORS[RESET]} ${EMOJI[DRAGON]} Wings Only"
        echo -e "  ${COLORS[GREEN]}3${COLORS[RESET]} ${EMOJI[ROCKET]} Full Stack"
        echo -e "  ${COLORS[GREEN]}4${COLORS[RESET]} ${EMOJI[NINJA]} Custom Install"
        
        read -r install_type
        
        case "$install_type" in
            1)
                execute_with_style "Installing Panel" \
                    "bash /tmp/pterodactyl_install.sh --panel" \
                    "${EMOJI[INSTALL]}"
                ;;
            2)
                execute_with_style "Installing Wings" \
                    "bash /tmp/pterodactyl_install.sh --wings" \
                    "${EMOJI[DRAGON]}"
                ;;
            3)
                execute_with_style "Installing Full Stack" \
                    "bash /tmp/pterodactyl_install.sh --full" \
                    "${EMOJI[ROCKET]}"
                ;;
            4)
                echo -e "${COLORS[NEON_PINK]}${EMOJI[NINJA]} Launching interactive installer...${COLORS[RESET]}"
                bash /tmp/pterodactyl_install.sh
                ;;
        esac
        
        rm -f /tmp/pterodactyl_install.sh
    else
        echo -e "${COLORS[RED]}${EMOJI[ERROR]} Download failed!${COLORS[RESET]}"
    fi
    
    echo -e "\n${COLORS[GOLD]}${EMOJI[PARTY]} Installation complete! ${EMOJI[PARTY]}${COLORS[RESET]}"
    read -p "Press Enter to continue..."
}

# ============================ 🎮 SPECIAL EFFECTS =========================
ultra_boost_mode() {
    echo -e "\n${COLORS[NEON_PINK]}${EMOJI[ROCKET]} ACTIVATING ULTRA BOOST MODE ${EMOJI[LIGHTNING]}${COLORS[RESET]}"
    
    for i in {1..3}; do
        echo -ne "${COLORS[RED]}${EMOJI[FIRE]} "
        echo -ne "${COLORS[ORANGE]}${EMOJI[FIRE]} "
        echo -ne "${COLORS[YELLOW]}${EMOJI[FIRE]} "
        echo -ne "${COLORS[GREEN]}${EMOJI[FIRE]} "
        echo -ne "${COLORS[BLUE]}${EMOJI[FIRE]} "
        echo -ne "${COLORS[PURPLE]}${EMOJI[FIRE]} "
        echo -e "${COLORS[RESET]}"
        sleep 0.1
    done
    
    execute_with_style "Optimizing system" \
        "sysctl -w vm.swappiness=10 && sysctl -w vm.vfs_cache_pressure=50" \
        "${EMOJI[LIGHTNING]}"
    
    execute_with_style "Cleaning cache" \
        "sync && echo 3 > /proc/sys/vm/drop_caches" \
        "${EMOJI[SPARKLE]}"
    
    execute_with_style "Boosting performance" \
        "nice -n -20 ionice -c2 -n0 echo 'Boost applied'" \
        "${EMOJI[ROCKET]}"
    
    echo -e "\n${COLORS[GREEN]}${EMOJI[CHECK]} System boosted to maximum performance! ${EMOJI[PARTY]}${COLORS[RESET]}"
    sleep 2
}

developer_mode() {
    echo -e "\n${COLORS[NEON_PINK]}${EMOJI[NINJA]} ACTIVATING DEVELOPER MODE ${EMOJI[WIZARD]}${COLORS[RESET]}"
    
    # Cool ASCII art
    cat << "EOF"
    ⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀
    ⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀
    ⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀
    ⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⡄
    ⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣇
    ⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
    ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿
    ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿
    ⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⡀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟
    ⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁
    ⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀
    ⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀
    ⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀
EOF
    
    echo -e "${COLORS[NEON_BLUE]}${EMOJI[KEY]} Developer tools unlocked! ${EMOJI[TOOLS]}${COLORS[RESET]}"
    echo -e "${COLORS[NEON_GREEN]}Available commands:${COLORS[RESET]}"
    echo -e "  ${COLORS[CYAN]}debug${COLORS[RESET]} - Enable debug mode"
    echo -e "  ${COLORS[CYAN]}trace${COLORS[RESET]} - Show execution trace"
    echo -e "  ${COLORS[CYAN]}test${COLORS[RESET]} - Run test suite"
    
    read -p "${COLORS[GOLD]}Enter command: ${COLORS[RESET]}" cmd
    echo -e "${COLORS[NEON_PINK]}${EMOJI[WIZARD]} Magic in progress...${COLORS[RESET]}"
    sleep 2
}

# ============================ 🎉 EASTER EGGS =============================
easter_eggs_menu() {
    local eggs=(
        "🎵 Play KSGAMING Anthem"
        "🎮 Secret Game Mode"
        "👽 Contact Aliens"
        "🧙 Summon Wizard"
        "🏴‍☠️ Pirate Mode"
        "🤖 Robot Dance"
        "🌈 Rainbow Mode"
        "⚡ Lightning Storm"
        "🔥 Fireworks Show"
        "✨ Sparkle Effect"
    )
    
    clear
    echo -e "${COLORS[NEON_PINK]}╔════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}║${COLORS[RESET]} ${COLORS[GOLD]}${EMOJI[KEY]} SECRET EASTER EGGS ${EMOJI[EGG]}${COLORS[RESET]}                                      ${COLORS[NEON_PINK]}║${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}╠════════════════════════════════════════════════════════════════════╣${COLORS[RESET]}"
    
    for i in "${!eggs[@]}"; do
        print_menu_option "$((i+1))" "${EMOJI[EGG]}" "${eggs[$i]}"
    done
    
    echo -e "${COLORS[NEON_PINK]}╚════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
    
    read -p "${COLORS[GOLD]}Choose egg: ${COLORS[RESET]}" egg_choice
    
    case $egg_choice in
        1)
            echo -e "\n${COLORS[NEON_PINK]}🎵 Playing KSGAMING Anthem... 🎵${COLORS[RESET]}"
            for note in "♪" "♫" "♬" "🎶" "🎵" "🎶" "♩" "♪"; do
                echo -ne "${COLORS[NEON_PINK]}$note ${COLORS[NEON_BLUE]}$note ${COLORS[GOLD]}$note ${COLORS[RESET]}"
                sleep 0.2
            done
            echo -e "\n${COLORS[GREEN]}${EMOJI[MUSIC]} Anthem complete! ${EMOJI[PARTY]}${COLORS[RESET]}"
            ;;
        5)
            echo -e "\n${COLORS[YELLOW]}🏴‍☠️ Yarrr! Pirate Mode Activated! 🏴‍☠️${COLORS[RESET]}"
            cat << "EOF"
               _
              | |
             _|_|_
           _|_____|_
         _|_________|_
        |  _ _ _ _ _  |
        | |         | |
        | |  KSGAMING| |
        | |  PIRATE  | |
        | |_ _ _ _ _ | |
        |_|_________|_|
           |___   ___|
               | |
               |_|
EOF
            ;;
        10)
            echo -e "\n${COLORS[NEON_PINK]}✨ SPARKLE EFFECT ACTIVATED ✨${COLORS[RESET]}"
            for i in {1..20}; do
                echo -ne "${COLORS[$((RANDOM % 7 + 1))]}${EMOJI[SPARKLE]} "
                sleep 0.05
            done
            echo -e "${COLORS[RESET]}"
            ;;
        *)
            echo -e "${COLORS[YELLOW]}${EMOJI[EGG]} That egg hasn't hatched yet! ${EMOJI[CHICK]}${COLORS[RESET]}"
            ;;
    esac
    
    sleep 2
}

# ============================ 🚀 EXIT SEQUENCE ==========================
exit_suite() {
    clear
    echo -e "\n\n"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿${COLORS[RESET]}"
    echo -e "${COLORS[NEON_PINK]}⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉${COLORS[RESET]}"
    
    echo -e "\n${COLORS[GOLD]}${EMOJI[ROCKET]} Thank you for using KSGAMING Hosting Suite! ${EMOJI[CROWN]}${COLORS[RESET]}"
    echo -e "${COLORS[NEON_GREEN]}${EMOJI[STAR]} Professional Hosting Solutions ${EMOJI[LIGHTNING]}${COLORS[RESET]}"
    echo -e "${COLORS[NEON_BLUE]}${EMOJI[CLOUD]} Visit us at: https://ksgaming.host ${EMOJI[GLOBE]}${COLORS[RESET]}"
    echo -e "\n${COLORS[SILVER]}Shutting down...${COLORS[RESET]}"
    
    for i in {3..1}; do
        echo -ne "${COLORS[RED]}${EMOJI[ROCKET]} $i ${COLORS[RESET]}"
        sleep 1
    done
    
    clear
    exit 0
}

# ============================ 🚀 INITIALIZATION =========================
initialize() {
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Show startup animation
    show_rocket_launch
    pulse_logo
    
    # System check
    echo -e "\n${COLORS[NEON_BLUE]}${EMOJI[MAGNIFY]} Performing system diagnostics...${COLORS[RESET]}"
    execute_with_style "Checking system" "uname -a" "${EMOJI[COMPUTER]}"
    execute_with_style "Checking resources" "free -h" "${EMOJI[BATTERY]}"
    execute_with_style "Checking storage" "df -h /" "${EMOJI[HARDDISK]}"
    
    echo -e "\n${COLORS[GREEN]}${EMOJI[CHECK]} System ready! ${EMOJI[ROCKET]}${COLORS[RESET]}"
    sleep 1
}

# ============================ 🎮 MAIN EXECUTION =========================
main() {
    initialize
    show_main_menu
}

# Trap for clean exit
trap 'echo -e "\n${COLORS[RED]}${EMOJI[WARNING]} Interrupted! Exiting...${COLORS[RESET]}"; exit 1' INT

# Start the suite
main "$@"
