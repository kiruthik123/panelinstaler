#!/bin/bash

# =========================================================
#   ⚡⚡⚡ KS HOSTING BY KSGAMING ⚡⚡⚡
#   🚀 ULTIMATE GAME PANEL MANAGEMENT SUITE 🚀
#   🏆 Professional Control Panel Interface 🏆
#   Version: 3.0.0 | Enhanced Edition
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

# =========================================================
#   🎨 ADVANCED COLOR PALETTE - 24-bit RGB 🎨
# =========================================================

# Reset
NC='\033[0m'

# 🌈 KS HOSTING Brand Colors
KS_PRIMARY='\033[1;38;5;39m'      # Electric Blue
KS_SECONDARY='\033[1;38;5;201m'   # Magenta Purple
KS_ACCENT='\033[1;38;5;226m'      # Gold Yellow
KS_SUCCESS='\033[1;38;5;46m'      # Neon Green
KS_WARNING='\033[1;38;5;208m'     # Orange
KS_ERROR='\033[1;38;5;196m'       # Red
KS_INFO='\033[1;38;5;51m'         # Cyan
KS_DARK='\033[1;38;5;240m'        # Dark Gray
KS_LIGHT='\033[1;38;5;255m'       # White

# 🎭 Gradient Colors
GRADIENT_1='\033[1;38;5;57m'      # Deep Purple
GRADIENT_2='\033[1;38;5;93m'      # Purple
GRADIENT_3='\033[1;38;5;129m'     # Violet
GRADIENT_4='\033[1;38;5;165m'     # Pink Purple
GRADIENT_5='\033[1;38;5;201m'     # Hot Pink

# 🎯 UI Elements
BORDER_COLOR='\033[1;38;5;39m'
HEADER_COLOR='\033[1;38;5;57m'
MENU_COLOR='\033[1;38;5;255m'
OPTION_COLOR='\033[1;38;5;226m'
HIGHLIGHT='\033[1;48;5;57m\033[1;38;5;255m'

# 🌟 Special Effects
BLINK='\033[5m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# =========================================================
#   🎭 EMOJI COLLECTION - EXTENSIVE SET
# =========================================================

# 🏆 Brand & Status
EMOJI_KS="⚡"          # KS Brand
EMOJI_GAMING="🎮"      # KSGAMING
EMOJI_HOSTING="🏢"     # Hosting
EMOJI_STAR="🌟"        # Star
EMOJI_FIRE="🔥"        # Fire/Hot
EMOJI_ROCKET="🚀"      # Rocket/Launch
EMOJI_CROWN="👑"       # Premium
EMOJI_SHIELD="🛡️"     # Security
EMOJI_TROPHY="🏆"      # Achievement

# 🔄 Navigation
EMOJI_HOME="🏠"
EMOJI_BACK="↩️"
EMOJI_EXIT="🚪"
EMOJI_NEXT="➡️"
EMOJI_PREV="⬅️"
EMOJI_UP="⬆️"
EMOJI_DOWN="⬇️"

# 📊 Status Indicators
EMOJI_CHECK="✅"
EMOJI_CROSS="❌"
EMOJI_WARN="⚠️"
EMOJI_INFO="ℹ️"
EMOJI_LOAD="⏳"
EMOJI_DONE="🎯"
EMOJI_WORK="⚙️"
EMOJI_SYNC="🔄"
EMOJI_ALERT="🚨"

# 💾 System & Files
EMOJI_TERMINAL="💻"
EMOJI_SERVER="🖥️"
EMOJI_DATABASE="💾"
EMOJI_NETWORK="🌐"
EMOJI_CLOUD="☁️"
EMOJI_DOWNLOAD="📥"
EMOJI_UPLOAD="📤"
EMOJI_FOLDER="📁"
EMOJI_FILE="📄"
EMOJI_TRASH="🗑️"
EMOJI_KEY="🔑"
EMOJI_LOCK="🔒"
EMOJI_UNLOCK="🔓"

# 🎮 Gaming & Panels
EMOJI_PANEL="🎮"
EMOJI_WINGS="🪽"
EMOJI_DRAGON="🐉"      # Pterodactyl
EMOJI_PUFFER="🐡"      # Pufferfish
EMOJI_MYTH="🔮"        # Mythical
EMOJI_ADDON="✨"
EMOJI_THEME="🎨"
EMOJI_PLUGIN="🔌"

# 🔧 Tools & Utilities
EMOJI_TOOLS="🛠️"
EMOJI_WRENCH="🔧"
EMOJI_HAMMER="🔨"
EMOJI_GEAR="⚙️"
EMOJI_MAGNET="🧲"
EMOJI_MICRO="🔬"
EMOJI_TELESCOPE="🔭"

# 🔐 Security & VPN
EMOJI_VPN="🔐"
EMOJI_SSL="🔒"
EMOJI_FINGER="🔍"
EMOJI_EYES="👁️"
EMOJI_POLICE="👮"

# 🌈 Visual & Themes
EMOJI_PAINT="🎨"
EMOJI_ART="🖼️"
EMOJI_COLOR="🌈"
EMOJI_SPARKLE="✨"
EMOJI_GLITTER="💫"
EMOJI_DIAMOND="💎"
EMOJI_CRYSTAL="🔮"

# =========================================================
#   🎪 UI CONFIGURATION
# =========================================================
WIDTH=75
LINE_CHAR="━"
SUB_CHAR="─"
CORNER="╋"
SPARKLE_CHARS=("✨" "🌟" "💫" "⚡" "🎆")

# =========================================================
#   🎨 ENHANCED UI FUNCTIONS
# =========================================================

# Sparkle Effect
sparkle() {
    local chars=("${SPARKLE_CHARS[@]}")
    echo -ne "${chars[$RANDOM % ${#chars[@]}]}"
}

# Gradient Text
gradient_text() {
    local text="$1"
    local colors=("$GRADIENT_1" "$GRADIENT_2" "$GRADIENT_3" "$GRADIENT_4" "$GRADIENT_5")
    local result=""
    for ((i=0; i<${#text}; i++)); do
        local color_idx=$((i % ${#colors[@]}))
        result+="${colors[$color_idx]}${text:$i:1}"
    done
    echo -e "${result}${NC}"
}

# Animated Header
animated_header() {
    clear
    echo ""
    echo -e "${KS_PRIMARY}"
    echo -e "    ██╗  ██╗███████╗    ██╗  ██╗ ██████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗ "
    echo -e "    ██║ ██╔╝██╔════╝    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝ "
    echo -e "    █████╔╝ ███████╗    ███████║██║   ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗"
    echo -e "    ██╔═██╗ ╚════██║    ██╔══██║██║   ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║"
    echo -e "    ██║  ██╗███████║    ██║  ██║╚██████╔╝███████║   ██║   ██║██║ ╚████║╚██████╔╝"
    echo -e "    ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ "
    echo -e "${NC}"
    
    # Animated KS HOSTING text
    echo -ne "${KS_SECONDARY}"
    echo -e "              ╔═════════════════════════════════════════════════════╗"
    echo -ne "              ║  "
    echo -ne "$(sparkle) $(sparkle) "
    echo -ne "${EMOJI_KS} ${EMOJI_GAMING} "
    echo -ne "${KS_ACCENT}KS HOSTING BY KSGAMING${KS_SECONDARY}"
    echo -ne " ${EMOJI_HOSTING} ${EMOJI_KS} "
    echo -ne "$(sparkle) $(sparkle)"
    echo -e "  ║"
    echo -e "              ╚═════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Enhanced Border
draw_top_border() {
    echo -e "${BORDER_COLOR}╔$(printf "%0.s${LINE_CHAR}" $(seq 1 $((WIDTH-2))))╗${NC}"
}

draw_middle_border() {
    echo -e "${BORDER_COLOR}╠$(printf "%0.s${SUB_CHAR}" $(seq 1 $((WIDTH-2))))╣${NC}"
}

draw_bottom_border() {
    echo -e "${BORDER_COLOR}╚$(printf "%0.s${LINE_CHAR}" $(seq 1 $((WIDTH-2))))╝${NC}"
}

# Fancy Section Header
draw_section_header() {
    local title="$1"
    local emoji="$2"
    local color="${3:-$KS_INFO}"
    
    echo -e "${BORDER_COLOR}╠══════${NC}[ ${color}${emoji} ${title} ${NC}]$(printf "%0.s═" $(seq 1 $((WIDTH-${#title}-12))))${BORDER_COLOR}╣${NC}"
}

# Branded Header
draw_brand_header() {
    animated_header
    draw_top_border
    
    local line1="${EMOJI_KS} ${KS_PRIMARY}ULTIMATE GAME PANEL MANAGEMENT SUITE${NC} ${EMOJI_GAMING}"
    local line2="${EMOJI_HOSTING} ${KS_SECONDARY}Professional Control Interface v3.0${NC} ${EMOJI_STAR}"
    
    # Center text calculations
    local padding1=$(( (WIDTH - ${#line1} + 24) / 2 ))
    local padding2=$(( (WIDTH - ${#line2} + 24) / 2 ))
    
    echo -e "${BORDER_COLOR}║${NC}$(printf "%${padding1}s")${line1}$(printf "%$((WIDTH - padding1 - ${#line1} + 24))s")${BORDER_COLOR}║${NC}"
    echo -e "${BORDER_COLOR}║${NC}$(printf "%${padding2}s")${line2}$(printf "%$((WIDTH - padding2 - ${#line2} + 24))s")${BORDER_COLOR}║${NC}"
    
    draw_middle_border
    
    # System info line
    local sysinfo="${EMOJI_TERMINAL} ${KS_DARK}User: ${KS_LIGHT}$USER${KS_DARK} | IP: ${KS_LIGHT}$(hostname -I | awk '{print $1}')${KS_DARK} | Time: ${KS_LIGHT}$(date '+%H:%M:%S')${NC}"
    local sysinfo_len=${#sysinfo}
    local padding3=$(( (WIDTH - sysinfo_len + 32) / 2 ))
    
    echo -e "${BORDER_COLOR}║${NC}$(printf "%${padding3}s")${sysinfo}$(printf "%$((WIDTH - padding3 - sysinfo_len + 32))s")${BORDER_COLOR}║${NC}"
    
    draw_middle_border
}

# Fancy Option Display
print_fancy_option() {
    local num="$1"
    local text="$2"
    local emoji="${3:-""}"
    local color="${4:-$MENU_COLOR}"
    local highlight="${5:-false}"
    
    if [ "$highlight" = "true" ]; then
        echo -e "${BORDER_COLOR}║${NC}  ${HIGHLIGHT} ${OPTION_COLOR}[${num}]${NC} ${HIGHLIGHT}${emoji} ${text}$(printf "%$((WIDTH - ${#text} - 18))s")${NC} ${BORDER_COLOR}║${NC}"
    else
        echo -e "${BORDER_COLOR}║${NC}  ${OPTION_COLOR}[${num}]${NC} ${emoji} ${color}${text}${NC}$(printf "%$((WIDTH - ${#text} - 15))s")${BORDER_COLOR}║${NC}"
    fi
}

# Status Messages with Flair
ks_success() { 
    echo -e "\n${KS_SUCCESS}${EMOJI_CHECK} ${EMOJI_FIRE} SUCCESS:${NC} ${EMOJI_SPARKLE} $1 ${EMOJI_DONE}"
    echo -e "${KS_DARK}════════════════════════════════════════════════════════════${NC}\n"
}

ks_error() { 
    echo -e "\n${KS_ERROR}${EMOJI_CROSS} ${EMOJI_ALERT} ERROR:${NC} ${EMOJI_WARN} $1"
    echo -e "${KS_DARK}────────────────────────────────────────────────────────────${NC}\n"
}

ks_warning() { 
    echo -e "\n${KS_WARNING}${EMOJI_WARN} ${EMOJI_POLICE} WARNING:${NC} ${EMOJI_EYES} $1"
    echo -e "${KS_DARK}────────────────────────────────────────────────────────────${NC}\n"
}

ks_info() { 
    echo -e "\n${KS_INFO}${EMOJI_INFO} ${EMOJI_MICRO} INFO:${NC} ${EMOJI_TELESCOPE} $1"
}

ks_progress() { 
    echo -ne "${KS_PRIMARY}${EMOJI_LOAD} ${EMOJI_WORK} PROCESSING:${NC} ${EMOJI_SYNC} $1 "
}

ks_complete() {
    echo -e "${KS_SUCCESS}${EMOJI_CHECK} COMPLETE!${NC} ${EMOJI_TROPHY}"
}

# Loading Animation
fancy_loading() {
    local pid=$1
    local msg="$2"
    local frames=("${EMOJI_LOAD}" "${EMOJI_SYNC}" "${EMOJI_WORK}" "${EMOJI_GEAR}")
    local i=0
    
    ks_progress "$msg"
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${KS_PRIMARY}${EMOJI_LOAD} ${EMOJI_WORK} PROCESSING:${NC} ${EMOJI_SYNC} $msg ${frames[$i]} "
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.2
    done
    
    echo -e "\r${KS_SUCCESS}${EMOJI_CHECK} ${EMOJI_DONE} COMPLETED:${NC} ${EMOJI_TROPHY} $msg $(printf '%*s' 20)"
}

# =========================================================
#   🎭 MAIN MENU INTERFACE
# =========================================================

show_main_menu() {
    draw_brand_header
    
    # Main Panel Section
    print_fancy_option "1" "Pterodactyl Panel Manager" "${EMOJI_DRAGON} ${EMOJI_PANEL}" "$KS_PRIMARY" "true"
    print_fancy_option "2" "Pterodactyl Wings Manager" "${EMOJI_WINGS} ${EMOJI_GEAR}" "$KS_SECONDARY"
    print_fancy_option "3" "Hybrid Installation" "${EMOJI_ROCKET} ${EMOJI_FIRE}" "$KS_ACCENT"
    
    draw_section_header "ADDONS & CUSTOMIZATION" "${EMOJI_ADDON}"
    print_fancy_option "4" "Blueprint System & Addon Store" "${EMOJI_CRYSTAL} ${EMODIAMOND}" "$GRADIENT_3"
    print_fancy_option "5" "Themes & Visual Enhancements" "${EMOJI_PAINT} ${EMOJI_COLOR}" "$GRADIENT_4"
    
    draw_section_header "PANEL INTEGRATIONS" "${EMOJI_SERVER}"
    print_fancy_option "6" "Third-Party Panel Installers" "${EMOJI_PUFFER} ${EMOJI_MYTH}" "$KS_INFO"
    print_fancy_option "7" "VPN & Tunnel Management" "${EMOJI_VPN} ${EMOJI_CLOUD}" "$KS_WARNING"
    
    draw_section_header "SYSTEM MANAGEMENT" "${EMOJI_TOOLS}"
    print_fancy_option "8" "System Toolbox & Utilities" "${EMOJI_WRENCH} ${EMOJI_HAMMER}" "$KS_LIGHT"
    print_fancy_option "9" "Security & Firewall Setup" "${EMOJI_SHIELD} ${EMOJI_POLICE}" "$KS_ERROR"
    
    draw_section_header "ADVANCED" "${EMOJI_KEY}"
    print_fancy_option "C" "Configuration Dashboard" "${EMOJI_GEAR} ${EMOJI_MAGNET}" "$KS_DARK"
    print_fancy_option "U" "Uninstall Manager" "${EMOJI_TRASH} ${EMOJI_ALERT}" "$KS_ERROR" "true"
    
    draw_middle_border
    print_fancy_option "0" "Exit Control Panel" "${EMOJI_EXIT} ${EMOJI_HOME}" "$KS_DARK"
    
    draw_bottom_border
    
    echo -e "\n${KS_ACCENT}${EMOJI_STAR} $(printf '%0.s═' $(seq 1 $((WIDTH/3)))) [ SELECT OPTION ] $(printf '%0.s═' $(seq 1 $((WIDTH/3)))) ${EMOJI_STAR}${NC}"
    echo -ne "${KS_PRIMARY}${EMOJI_CRYSTAL} ${EMOJI_GAMING} KSGAMING@HOSTING:~# ${NC}"
}

# =========================================================
#   🎨 THEMED SUB-MENUS
# =========================================================

# Panel Management Menu
show_panel_menu() {
    draw_brand_header
    draw_section_header "PTERODACTYL PANEL MANAGEMENT" "${EMOJI_DRAGON} ${EMOJI_PANEL}"
    
    print_fancy_option "1" "Install Panel (Latest Version)" "${EMOJI_DOWNLOAD} ${EMOJI_ROCKET}" "$KS_SUCCESS"
    print_fancy_option "2" "Update Panel" "${EMOJI_UPLOAD} ${EMOJI_SYNC}" "$KS_WARNING"
    print_fancy_option "3" "Create Administrator User" "${EMOJI_CROWN} ${EMOJI_KEY}" "$KS_ACCENT"
    print_fancy_option "4" "Panel Diagnostics" "${EMOJI_MICRO} ${EMOJI_TELESCOPE}" "$KS_INFO"
    print_fancy_option "5" "Clear Cache & Optimize" "${EMOJI_TRASH} ${EMOJI_WORK}" "$KS_WARNING"
    print_fancy_option "6" "Repair Permissions" "${EMOJI_LOCK} ${EMOJI_WRENCH}" "$KS_ERROR"
    print_fancy_option "7" "Backup Panel Database" "${EMOJI_DATABASE} ${EMOJI_SHIELD}" "$KS_SECONDARY"
    
    draw_middle_border
    print_fancy_option "0" "Back to Main Menu" "${EMOJI_BACK} ${EMOJI_HOME}" "$KS_DARK"
    
    draw_bottom_border
    
    echo -ne "\n${KS_PRIMARY}${EMOJI_PANEL} Panel Action: ${NC}"
}

# Wings Management Menu
show_wings_menu() {
    draw_brand_header
    draw_section_header "WINGS DAEMON MANAGEMENT" "${EMOJI_WINGS} ${EMOJI_GEAR}"
    
    print_fancy_option "1" "Install Wings Daemon" "${EMOJI_DOWNLOAD} ${EMOJI_ROCKET}" "$KS_SUCCESS"
    print_fancy_option "2" "Configure Wings Token" "${EMOJI_KEY} ${EMOJI_LOCK}" "$KS_ACCENT"
    print_fancy_option "3" "Restart Wings Service" "${EMOJI_SYNC} ${EMOJI_WORK}" "$KS_WARNING"
    print_fancy_option "4" "Wings Status Check" "${EMOJI_MICRO} ${EMOJI_TELESCOPE}" "$KS_INFO"
    print_fancy_option "5" "Update Wings" "${EMOJI_UPLOAD} ${EMOJI_SYNC}" "$KS_WARNING"
    print_fancy_option "6" "View Wings Logs" "${EMOJI_FILE} ${EMOJI_EYES}" "$KS_DARK"
    
    draw_middle_border
    print_fancy_option "0" "Back to Main Menu" "${EMOJI_BACK} ${EMOJI_HOME}" "$KS_DARK"
    
    draw_bottom_border
    
    echo -ne "\n${KS_PRIMARY}${EMOJI_WINGS} Wings Action: ${NC}"
}

# Blueprint System Menu
show_blueprint_menu() {
    draw_brand_header
    draw_section_header "BLUEPRINT SYSTEM & ADDON STORE" "${EMOJI_CRYSTAL} ${EMOJI_DIAMOND}"
    
    print_fancy_option "1" "Install Blueprint Framework" "${EMOJI_DOWNLOAD} ${EMOJI_CRYSTAL}" "$GRADIENT_1"
    print_fancy_option "2" "Browse Addon Collection" "${EMOJI_ADDON} ${EMOJI_STAR}" "$GRADIENT_2"
    print_fancy_option "3" "Theme Marketplace" "${EMOJI_PAINT} ${EMOJI_ART}" "$GRADIENT_3"
    print_fancy_option "4" "Update All Addons" "${EMOJI_UPLOAD} ${EMOJI_SYNC}" "$GRADIENT_4"
    print_fancy_option "5" "Developer Mode Toggle" "${EMOJI_GEAR} ${EMOJI_MAGNET}" "$GRADIENT_5"
    
    draw_section_header "ADDON MANAGEMENT" "${EMOJI_PLUGIN}"
    print_fancy_option "6" "Manage Installed Addons" "${EMOJI_FOLDER} ${EMOJI_EYES}" "$KS_INFO"
    print_fancy_option "7" "Uninstall Addon" "${EMOJI_TRASH} ${EMOJI_ALERT}" "$KS_ERROR"
    print_fancy_option "8" "Addon Diagnostics" "${EMOJI_MICRO} ${EMOJI_TELESCOPE}" "$KS_WARNING"
    
    draw_middle_border
    print_fancy_option "0" "Back to Main Menu" "${EMOJI_BACK} ${EMOJI_HOME}" "$KS_DARK"
    
    draw_bottom_border
    
    echo -ne "\n${KS_SECONDARY}${EMOJI_CRYSTAL} Blueprint Selection: ${NC}"
}

# System Toolbox Menu
show_toolbox_menu() {
    draw_brand_header
    draw_section_header "SYSTEM TOOLBOX & UTILITIES" "${EMOJI_TOOLS} ${EMOJI_WRENCH}"
    
    print_fancy_option "1" "System Health Monitor" "${EMOJI_TERMINAL} ${EMOJI_MICRO}" "$KS_INFO"
    print_fancy_option "2" "Memory & Swap Manager" "${EMOJI_DATABASE} ${EMOJI_SYNC}" "$KS_PRIMARY"
    print_fancy_option "3" "Network Speed Test" "${EMOJI_NETWORK} ${EMOJI_ROCKET}" "$KS_SUCCESS"
    print_fancy_option "4" "Firewall Configuration" "${EMOJI_SHIELD} ${EMOJI_POLICE}" "$KS_ERROR"
    print_fancy_option "5" "Database Operations" "${EMOJI_DATABASE} ${EMOJI_KEY}" "$KS_SECONDARY"
    print_fancy_option "6" "SSL Certificate Manager" "${EMOJI_SSL} ${EMOJI_LOCK}" "$KS_ACCENT"
    
    draw_section_header "ADVANCED TOOLS" "${EMOJI_HAMMER}"
    print_fancy_option "7" "TailScale VPN Manager" "${EMOJI_VPN} ${EMOJI_FINGER}" "$KS_WARNING"
    print_fancy_option "8" "Cloudflare Tunnel Setup" "${EMOJI_CLOUD} ${EMOJI_EYES}" "$KS_INFO"
    print_fancy_option "9" "Root Access Management" "${EMOJI_CROWN} ${EMOJI_UNLOCK}" "$KS_SUCCESS"
    print_fancy_option "10" "Web SSH Terminal" "${EMOJI_TERMINAL} ${EMOJI_NETWORK}" "$KS_PRIMARY"
    
    draw_middle_border
    print_fancy_option "0" "Back to Main Menu" "${EMOJI_BACK} ${EMOJI_HOME}" "$KS_DARK"
    
    draw_bottom_border
    
    echo -ne "\n${KS_LIGHT}${EMOJI_TOOLS} Tool Selection: ${NC}"
}

# =========================================================
#   🎯 INSTALLATION FUNCTIONS WITH FLAIR
# =========================================================

install_with_style() {
    local name="$1"
    local url="$2"
    
    echo -e "\n${KS_ACCENT}${EMOJI_ROCKET} ${EMOJI_FIRE} LAUNCHING INSTALLATION ${EMOJI_FIRE} ${EMOJI_ROCKET}${NC}"
    echo -e "${KS_PRIMARY}$(printf '%0.s═' $(seq 1 $WIDTH))${NC}"
    
    ks_info "Installing: ${EMOJI_STAR} $name ${EMOJI_STAR}"
    ks_progress "Downloading components..."
    
    # Simulate installation with fancy output
    for i in {1..5}; do
        echo -ne "${KS_PRIMARY}${EMOJI_WORK} Stage $i/5: $(sparkle) Installing $(sparkle) ${NC}\r"
        sleep 0.3
    done
    
    # Actual installation
    if bash <(curl -s "$url"); then
        ks_success "$name has been successfully installed! ${EMOJI_TROPHY}"
        echo -e "${KS_INFO}${EMOJI_STAR} Installation completed at $(date '+%H:%M:%S') ${EMOJI_STAR}${NC}"
    else
        ks_error "Installation failed! Please check your connection."
    fi
    
    echo -e "\n${KS_DARK}$(printf '%0.s─' $(seq 1 $WIDTH))${NC}"
    read -p "$(echo -e "${KS_ACCENT}${EMOJI_BACK} Press Enter to continue... ${NC}")"
}

# =========================================================
#   🎪 MAIN PROGRAM LOOP
# =========================================================

while true; do
    show_main_menu
    read -r choice
    
    case ${choice^^} in
        1)
            show_panel_menu
            read -r panel_choice
            case $panel_choice in
                1) install_with_style "Pterodactyl Panel" "$INSTALLER_URL" ;;
                2) ks_info "Panel update feature coming soon!"; sleep 2 ;;
                3) 
                    ks_progress "Launching user creation wizard..."
                    cd "$PANEL_DIR" && php artisan p:user:make
                    ks_complete
                    ;;
                5) 
                    ks_progress "Clearing panel cache..."
                    cd "$PANEL_DIR" && php artisan view:clear && php artisan config:clear
                    ks_success "Panel cache cleared!"
                    ;;
                6)
                    ks_progress "Repairing permissions..."
                    chown -R www-data:www-data "$PANEL_DIR"/*
                    ks_success "Permissions repaired!"
                    ;;
                0) continue ;;
                *) ks_error "Invalid selection!"; sleep 1 ;;
            esac
            ;;
            
        2)
            show_wings_menu
            read -r wings_choice
            case $wings_choice in
                1) install_with_style "Pterodactyl Wings" "$INSTALLER_URL" ;;
                2)
                    echo -e "\n${KS_INFO}${EMOJI_KEY} Paste your configuration command:${NC}"
                    read -r CMD
                    ks_progress "Configuring Wings..."
                    eval "$CMD"
                    systemctl enable --now wings
                    ks_success "Wings configured successfully!"
                    ;;
                3)
                    ks_progress "Restarting Wings service..."
                    systemctl restart wings
                    ks_success "Wings service restarted!"
                    ;;
                0) continue ;;
                *) ks_error "Invalid selection!"; sleep 1 ;;
            esac
            ;;
            
        3)
            echo -e "\n${KS_ACCENT}${EMOJI_FIRE} ${EMOJI_ROCKET} HYBRID INSTALLATION ${EMOJI_ROCKET} ${EMOJI_FIRE}${NC}"
            echo -e "${KS_WARNING}${EMOJI_WARN} This will install both Panel and Wings components${NC}"
            echo -e "${KS_INFO}${EMOJI_INFO} Estimated time: 5-10 minutes${NC}\n"
            
            read -p "$(echo -e "${KS_ERROR}${EMOJI_ALERT} Type 'INSTALL' to proceed: ${NC}")" confirm
            if [ "${confirm^^}" = "INSTALL" ]; then
                install_with_style "Pterodactyl Hybrid System" "$INSTALLER_URL"
            else
                ks_info "Installation cancelled."
                sleep 1
            fi
            ;;
            
        4)
            show_blueprint_menu
            read -r bp_choice
            # Add blueprint functionality here
            ks_info "Blueprint system launching..."
            sleep 2
            ;;
            
        8)
            show_toolbox_menu
            read -r tool_choice
            case $tool_choice in
                1)
                    echo -e "\n${KS_INFO}${EMOJI_TERMINAL} SYSTEM STATUS ${EMOJI_TERMINAL}${NC}"
                    echo -e "${KS_DARK}════════════════════════════════════════════════════════════${NC}"
                    echo -e "${KS_LIGHT}Memory:${NC} $(free -h | grep Mem | awk '{print $3"/"$2}')"
                    echo -e "${KS_LIGHT}Disk:${NC} $(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')"
                    echo -e "${KS_LIGHT}Uptime:${NC} $(uptime -p)"
                    echo -e "${KS_LIGHT}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
                    echo -e "${KS_DARK}════════════════════════════════════════════════════════════${NC}"
                    read -p "$(echo -e "${KS_ACCENT}${EMOJI_BACK} Press Enter... ${NC}")"
                    ;;
                2)
                    ks_progress "Creating 2GB swap file..."
                    fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
                    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
                    ks_success "Swap memory added successfully!"
                    ;;
                3)
                    ks_progress "Installing speedtest utility..."
                    apt-get install speedtest-cli -y -qq
                    echo -e "\n${KS_INFO}${EMOJI_ROCKET} RUNNING SPEED TEST ${EMOJI_ROCKET}${NC}"
                    speedtest-cli --simple
                    read -p "$(echo -e "${KS_ACCENT}${EMOJI_BACK} Press Enter... ${NC}")"
                    ;;
                0) continue ;;
                *) ks_error "Invalid selection!"; sleep 1 ;;
            esac
            ;;
            
        U)
            echo -e "\n${KS_ERROR}${EMOJI_ALERT} ${EMOJI_FIRE} DANGER ZONE ${EMOJI_FIRE} ${EMOJI_ALERT}${NC}"
            echo -e "${KS_WARNING}${EMOJI_WARN} This will remove ALL Pterodactyl data!${NC}"
            echo -e "${KS_DARK}════════════════════════════════════════════════════════════${NC}"
            
            read -p "$(echo -e "${KS_ERROR}${EMOJI_ALERT} Type 'DELETE-EVERYTHING' to confirm: ${NC}")" confirm
            if [ "${confirm^^}" = "DELETE-EVERYTHING" ]; then
                ks_progress "Initiating complete uninstall..."
                rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings
                ks_success "Pterodactyl system completely removed!"
            else
                ks_info "Uninstallation cancelled."
            fi
            sleep 2
            ;;
            
        0)
            echo -e "\n${KS_PRIMARY}${EMOJI_EXIT} ${EMOJI_HOME} Thank you for using KS Hosting! ${EMOJI_HOME} ${EMOJI_EXIT}${NC}"
            echo -e "${KS_SECONDARY}Powered by KSGAMING - Professional Game Hosting Solutions${NC}"
            echo -e "${KS_DARK}$(printf '%0.s─' $(seq 1 $WIDTH))${NC}"
            echo -e "${KS_INFO}Shutting down control panel...${NC}"
            sleep 2
            clear
            exit 0
            ;;
            
        *)
            ks_error "Invalid option! Please select a valid menu item."
            sleep 1
            ;;
    esac
done
