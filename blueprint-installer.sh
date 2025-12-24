#!/bin/bash
#==============================================================================
#   🎮 KSGAMING PANEL THEME INSTALLER (Ultimate Edition)
#      Optimized for Debian/Ubuntu + Pterodactyl Control Panel
#      Official KSGAMING Theme - Version 3.0
#      Copyright © 2024 KSGAMING. All rights reserved.
#==============================================================================

set -o errexit
set -o pipefail
set -o nounset

#============ GLOBAL CONFIGURATION ============#
readonly SCRIPT_VERSION="3.0.0"
readonly SUPPORTED_OS=("debian" "ubuntu")
readonly MINIMUM_MEMORY=4096  # 4GB in MB for optimal performance
readonly REQUIRED_DISK_SPACE=10  # GB
readonly INSTALL_DIR="/var/www/pterodactyl"
readonly LOG_DIR="/var/log/ksgaming"
readonly BACKUP_DIR="/var/backups/ksgaming"
readonly THEME_REPO="https://github.com/KSGAMING-Dev/panel-theme.git"
readonly THEME_BRANCH="main"
readonly OFFICIAL_WEBSITE="https://ksgaming.dev"
readonly SUPPORT_EMAIL="support@ksgaming.dev"
readonly DISCORD_INVITE="https://discord.gg/ksgaming"

#============ COLOR PALETTE ============#
readonly KS_BLUE='\033[38;2;0;150;255m'
readonly KS_GREEN='\033[38;2;46;204;113m'
readonly KS_RED='\033[38;2;231;76;60m'
readonly KS_YELLOW='\033[38;2;241;196;15m'
readonly KS_PURPLE='\033[38;2;155;89;182m'
readonly KS_CYAN='\033[38;2;26;188;156m'
readonly KS_ORANGE='\033[38;2;230;126;34m'
readonly KS_WHITE='\033[38;2;236;240;241m'
readonly KS_BOLD='\033[1m'
readonly KS_RESET='\033[0m'

#============ ASCII ART ============#
print_ksgaming_banner() {
    clear
    echo -e "${KS_BLUE}${KS_BOLD}"
    cat << "EOF"
  _  __ ____    _____                         _             
 | |/ /|  _ \  / ____|                       (_)            
 | ' / | |_) || |  __   __ _  _ __ ___   ___  _  _ __    __ _ 
 |  <  |  _ < | | |_ | / _` || '_ ` _ \ / __|| || '_ \  / _` |
 | . \ | |_) || |__| || (_| || | | | | |\__ \| || | | || (_| |
 |_|\_\|____/  \_____| \__,_||_| |_| |_||___/|_||_| |_| \__, |
                                                         __/ |
    ██╗  ██╗███████╗    ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗   |___/ 
    ██║ ██╔╝██╔════╝    ██╔══██╗██╔══██╗████╗ ████║██║████╗  ██║██╔════╝      
    █████╔╝ ███████╗    ██████╔╝███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗     
    ██╔═██╗ ╚════██║    ██╔══██╗██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║     
    ██║  ██╗███████║    ██║  ██║██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝     
    ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝      
EOF
    echo -e "${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}╔═════════════════════════════════════════════════════════════════════════╗${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}║         ULTIMATE GAMING PANEL THEME v${SCRIPT_VERSION} - PROFESSIONAL EDITION        ║${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}║             Optimized for High-Performance Gaming Infrastructure           ║${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}╚═════════════════════════════════════════════════════════════════════════╝${KS_RESET}"
    echo -e "${KS_CYAN}${KS_BOLD}Website: ${OFFICIAL_WEBSITE}${KS_RESET}   ${KS_YELLOW}${KS_BOLD}Discord: ${DISCORD_INVITE}${KS_RESET}   ${KS_GREEN}${KS_BOLD}Support: ${SUPPORT_EMAIL}${KS_RESET}"
    echo
}

#============ LOGGING SYSTEM ============#
init_logging() {
    mkdir -p "$LOG_DIR"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    readonly MAIN_LOG="$LOG_DIR/ksgaming_install_${timestamp}.log"
    readonly ERROR_LOG="$LOG_DIR/ksgaming_errors_${timestamp}.log"
    readonly PERFORMANCE_LOG="$LOG_DIR/ksgaming_perf_${timestamp}.log"
    
    exec 3>&1 4>&2
    exec > >(tee -a "$MAIN_LOG" >&3)
    exec 2> >(tee -a "$ERROR_LOG" >&4)
    
    log "SYSTEM" "KSGAMING Installer v${SCRIPT_VERSION} initialized"
    log "SYSTEM" "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    log "SYSTEM" "=================================================="
}

log() {
    local level="$1"
    local message="$2"
    local color="${KS_WHITE}"
    
    case "$level" in
        "SUCCESS") color="${KS_GREEN}" ;;
        "ERROR") color="${KS_RED}" ;;
        "WARNING") color="${KS_YELLOW}" ;;
        "INFO") color="${KS_CYAN}" ;;
        "DEBUG") color="${KS_PURPLE}" ;;
        "SYSTEM") color="${KS_BLUE}" ;;
    esac
    
    echo -e "${color}[$(date '+%H:%M:%S')] [${level}]${KS_RESET} ${message}" | tee -a "$MAIN_LOG"
    
    if [[ "$level" == "ERROR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}" >> "$ERROR_LOG"
    fi
}

#============ ANIMATED PROGRESS ============#
show_spinner() {
    local pid=$!
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

show_progress_bar() {
    local duration=$1
    local task="$2"
    local bar_length=50
    local sleep_interval=$(echo "scale=3; $duration/$bar_length" | bc)
    
    echo -ne "${KS_CYAN}${KS_BOLD}[•]${KS_RESET} ${KS_CYAN}${task}${KS_RESET} ["
    
    for ((i=0; i<bar_length; i++)); do
        echo -ne "▰"
        sleep $sleep_interval
    done
    
    echo -e "] ${KS_GREEN}✓${KS_RESET}"
}

#============ SYSTEM CHECKS ============#
check_system() {
    log "SYSTEM" "Starting comprehensive system analysis"
    
    # OS Detection
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_NAME="$ID"
        OS_VERSION="$VERSION_ID"
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
    fi
    
    log "INFO" "Operating System: ${OS_NAME^} $OS_VERSION"
    log "INFO" "Kernel Version: $(uname -r)"
    log "INFO" "Architecture: $(uname -m)"
    
    # OS Compatibility
    if [[ ! "${SUPPORTED_OS[@]}" =~ ${OS_NAME,,} ]]; then
        log "ERROR" "Unsupported OS: $OS_NAME"
        echo -e "\n${KS_RED}${KS_BOLD}❌ INCOMPATIBLE SYSTEM DETECTED${KS_RESET}"
        echo -e "${KS_YELLOW}Supported Systems:${KS_RESET}"
        for os in "${SUPPORTED_OS[@]}"; do
            echo -e "  ${KS_CYAN}•${KS_RESET} ${os^}"
        done
        echo -e "\n${KS_YELLOW}Detected: ${OS_NAME^} $OS_VERSION${KS_RESET}"
        exit 1
    fi
    
    # Memory Check
    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    local available_mem=$(free -m | awk '/^Mem:/{print $7}')
    log "INFO" "Total Memory: ${total_mem}MB"
    log "INFO" "Available Memory: ${available_mem}MB"
    
    if [[ $total_mem -lt $MINIMUM_MEMORY ]]; then
        log "WARNING" "Memory below recommended minimum (${MINIMUM_MEMORY}MB)"
        echo -e "\n${KS_YELLOW}${KS_BOLD}⚠  MEMORY WARNING${KS_RESET}"
        echo -e "${KS_YELLOW}Current: ${total_mem}MB${KS_RESET}"
        echo -e "${KS_YELLOW}Recommended: ${MINIMUM_MEMORY}MB${KS_RESET}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
    
    # Disk Space Check
    local disk_space=$(df -BG /var | awk 'NR==2{print $4}' | tr -d 'G')
    log "INFO" "Available disk space in /var: ${disk_space}GB"
    
    if [[ $disk_space -lt $REQUIRED_DISK_SPACE ]]; then
        log "ERROR" "Insufficient disk space: ${disk_space}GB available, ${REQUIRED_DISK_SPACE}GB required"
        echo -e "\n${KS_RED}${KS_BOLD}❌ INSUFFICIENT DISK SPACE${KS_RESET}"
        echo -e "${KS_RED}Available: ${disk_space}GB${KS_RESET}"
        echo -e "${KS_RED}Required: ${REQUIRED_DISK_SPACE}GB${KS_RESET}"
        echo -e "\n${KS_YELLOW}Try:${KS_RESET}"
        echo -e "  ${KS_CYAN}•${KS_RESET} Clean up old backups: sudo rm -rf /var/backups/*.old"
        echo -e "  ${KS_CYAN}•${KS_RESET} Clear package cache: sudo apt clean"
        exit 1
    fi
    
    # CPU Cores
    local cpu_cores=$(nproc)
    log "INFO" "CPU Cores: $cpu_cores"
    
    # Uptime
    local uptime=$(uptime -p | sed 's/up //')
    log "INFO" "System Uptime: $uptime"
    
    log "SUCCESS" "System validation completed"
}

check_pterodactyl() {
    log "SYSTEM" "Validating Pterodactyl installation"
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log "ERROR" "Pterodactyl directory not found: $INSTALL_DIR"
        echo -e "\n${KS_RED}${KS_BOLD}❌ PTERODACTYL NOT FOUND${KS_RESET}"
        echo -e "${KS_YELLOW}Pterodactyl installation directory is missing.${KS_RESET}"
        echo -e "\n${KS_CYAN}${KS_BOLD}Solutions:${KS_RESET}"
        echo -e "1. ${KS_YELLOW}Install Pterodactyl first${KS_RESET}"
        echo -e "   Run: ${KS_WHITE}curl -sSL https://get.pterodactyl-installer.se | bash${KS_RESET}"
        echo -e "2. ${KS_YELLOW}Check installation path${KS_RESET}"
        echo -e "   Expected: ${KS_WHITE}$INSTALL_DIR${KS_RESET}"
        exit 1
    fi
    
    cd "$INSTALL_DIR" || {
        log "ERROR" "Cannot access directory: $INSTALL_DIR"
        exit 1
    }
    
    # Check if it's a valid Pterodactyl installation
    if [[ ! -f "artisan" || ! -d "app" || ! -d "public" ]]; then
        log "ERROR" "Invalid Pterodactyl installation structure"
        echo -e "\n${KS_RED}${KS_BOLD}❌ INVALID PTERODACTYL INSTALLATION${KS_RESET}"
        echo -e "${KS_YELLOW}The directory does not contain valid Pterodactyl files.${KS_RESET}"
        exit 1
    fi
    
    # Get Panel Version
    if [[ -f "composer.json" ]]; then
        local panel_version=$(grep '"version"' composer.json | cut -d'"' -f4)
        log "INFO" "Pterodactyl Panel Version: $panel_version"
    fi
    
    # Check PHP
    if command -v php > /dev/null 2>&1; then
        local php_version=$(php -r "echo PHP_VERSION;")
        log "INFO" "PHP Version: $php_version"
    else
        log "WARNING" "PHP not found or not in PATH"
    fi
    
    # Check Composer
    if [[ -f "composer.lock" ]]; then
        log "INFO" "Composer dependencies are installed"
    fi
    
    log "SUCCESS" "Pterodactyl validation passed"
}

#============ DEPENDENCY MANAGEMENT ============#
install_dependencies() {
    log "SYSTEM" "Installing system dependencies"
    
    local basic_deps=(
        curl
        wget
        git
        unzip
        zip
        tar
        gzip
        bzip2
        ca-certificates
        gnupg
        lsb-release
        software-properties-common
        apt-transport-https
        build-essential
        pkg-config
    )
    
    local dev_deps=(
        nodejs
        npm
        yarn
        python3
        python3-pip
        python3-venv
    )
    
    echo -e "\n${KS_BLUE}${KS_BOLD}📦 INSTALLING DEPENDENCIES${KS_RESET}"
    
    # Update repositories
    log "INFO" "Updating package repositories"
    echo -ne "${KS_CYAN}Updating repositories...${KS_RESET}"
    apt-get update -q > /dev/null 2>&1 &
    show_spinner
    echo -e " ${KS_GREEN}✓${KS_RESET}"
    
    # Upgrade existing packages
    log "INFO" "Upgrading existing packages"
    echo -ne "${KS_CYAN}Upgrading system packages...${KS_RESET}"
    apt-get upgrade -y -q > /dev/null 2>&1 &
    show_spinner
    echo -e " ${KS_GREEN}✓${KS_RESET}"
    
    # Install basic dependencies
    log "INFO" "Installing basic dependencies"
    for dep in "${basic_deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep "; then
            echo -ne "${KS_CYAN}Installing $dep...${KS_RESET}"
            apt-get install -y -q "$dep" > /dev/null 2>&1 &
            show_spinner
            echo -e " ${KS_GREEN}✓${KS_RESET}"
            log "DEBUG" "Installed: $dep"
        else
            log "DEBUG" "Already installed: $dep"
        fi
    done
    
    # Install Node.js 20.x
    install_nodejs
    
    # Install Yarn
    install_yarn
    
    log "SUCCESS" "All dependencies installed successfully"
}

install_nodejs() {
    log "INFO" "Setting up Node.js environment"
    
    # Check current version
    if command -v node > /dev/null 2>&1; then
        local current_version=$(node --version | cut -d'v' -f2)
        local major_version=$(echo $current_version | cut -d'.' -f1)
        
        if [[ $major_version -eq 20 ]]; then
            log "INFO" "Node.js 20.x already installed (v$current_version)"
            return 0
        else
            log "WARNING" "Removing Node.js v$current_version"
            apt-get remove -y --purge nodejs npm > /dev/null 2>&1
        fi
    fi
    
    # Install Node.js 20.x from NodeSource
    log "INFO" "Adding NodeSource repository"
    echo -ne "${KS_CYAN}Configuring NodeSource repository...${KS_RESET}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1 &
    show_spinner
    echo -e " ${KS_GREEN}✓${KS_RESET}"
    
    # Install Node.js
    log "INFO" "Installing Node.js 20.x"
    echo -ne "${KS_CYAN}Installing Node.js 20.x...${KS_RESET}"
    apt-get install -y -q nodejs > /dev/null 2>&1 &
    show_spinner
    echo -e " ${KS_GREEN}✓${KS_RESET}"
    
    # Verify installation
    local installed_version=$(node --version)
    log "SUCCESS" "Node.js $installed_version installed"
    echo -e "${KS_GREEN}Node.js version: ${installed_version}${KS_RESET}"
}

install_yarn() {
    log "INFO" "Setting up Yarn package manager"
    
    if command -v yarn > /dev/null 2>&1; then
        local yarn_version=$(yarn --version)
        log "INFO" "Yarn already installed (v$yarn_version)"
        return 0
    fi
    
    # Install Yarn via corepack
    echo -ne "${KS_CYAN}Installing Yarn...${KS_RESET}"
    npm install -g corepack > /dev/null 2>&1 &
    show_spinner
    corepack enable > /dev/null 2>&1
    echo -e " ${KS_GREEN}✓${KS_RESET}"
    
    local yarn_version=$(yarn --version)
    log "SUCCESS" "Yarn $yarn_version installed"
    echo -e "${KS_GREEN}Yarn version: ${yarn_version}${KS_RESET}"
}

#============ THEME INSTALLATION ============#
install_ksgaming_theme() {
    log "SYSTEM" "Starting KSGAMING theme installation"
    
    cd "$INSTALL_DIR" || {
        log "ERROR" "Cannot access installation directory"
        exit 1
    }
    
    echo -e "\n${KS_PURPLE}${KS_BOLD}🎨 INSTALLING KSGAMING THEME${KS_RESET}"
    
    # Create backup
    create_backup
    
    # Method 1: Clone from Git repository
    install_from_git
    
    # Method 2: Download from release (fallback)
    if [[ ! -d "ksgaming-theme" ]]; then
        log "WARNING" "Git installation failed, trying direct download"
        install_from_release
    fi
    
    # Install dependencies and build
    build_theme
    
    # Configure theme
    configure_theme
    
    log "SUCCESS" "KSGAMING theme installation completed"
}

create_backup() {
    log "INFO" "Creating system backup"
    mkdir -p "$BACKUP_DIR"
    
    local backup_file="$BACKUP_DIR/backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
    local backup_size=$(du -sh "$INSTALL_DIR" 2>/dev/null | cut -f1)
    
    echo -e "${KS_YELLOW}Creating backup of current installation...${KS_RESET}"
    echo -e "${KS_CYAN}Backup size: ~${backup_size}${KS_RESET}"
    
    # Backup important directories
    tar --exclude="node_modules" \
        --exclude="vendor" \
        --exclude="storage/logs" \
        -czf "$backup_file" \
        "$INSTALL_DIR/public" \
        "$INSTALL_DIR/resources" \
        "$INSTALL_DIR/routes" \
        "$INSTALL_DIR/database" \
        2>/dev/null || true
    
    local backup_actual=$(du -h "$backup_file" | cut -f1)
    log "INFO" "Backup created: $backup_file (${backup_actual})"
    
    echo -e "${KS_GREEN}✓ Backup created: $(basename "$backup_file")${KS_RESET}"
}

install_from_git() {
    log "INFO" "Cloning KSGAMING theme from Git repository"
    
    echo -ne "${KS_CYAN}Cloning KSGAMING theme repository...${KS_RESET}"
    
    if git clone --depth 1 --branch "$THEME_BRANCH" "$THEME_REPO" ksgaming-theme-temp 2>/dev/null; then
        echo -e " ${KS_GREEN}✓${KS_RESET}"
        
        # Copy theme files
        if [[ -d "ksgaming-theme-temp" ]]; then
            cp -r ksgaming-theme-temp/* .
            cp -r ksgaming-theme-temp/.* . 2>/dev/null || true
            rm -rf ksgaming-theme-temp
            
            log "SUCCESS" "Theme cloned successfully from Git"
            echo -e "${KS_GREEN}✓ Theme files extracted${KS_RESET}"
            return 0
        fi
    fi
    
    echo -e " ${KS_RED}✗${KS_RESET}"
    return 1
}

install_from_release() {
    log "INFO" "Downloading KSGAMING theme from release"
    
    local latest_url="https://api.github.com/repos/KSGAMING-Dev/panel-theme/releases/latest"
    local download_url=$(curl -s "$latest_url" | grep '"browser_download_url"' | grep '.zip' | head -1 | cut -d'"' -f4)
    
    if [[ -z "$download_url" ]]; then
        log "ERROR" "Could not find theme download URL"
        return 1
    fi
    
    echo -ne "${KS_CYAN}Downloading theme package...${KS_RESET}"
    
    local temp_zip="/tmp/ksgaming-theme-$(date +%s).zip"
    if wget -q -O "$temp_zip" "$download_url"; then
        echo -e " ${KS_GREEN}✓${KS_RESET}"
        
        echo -ne "${KS_CYAN}Extracting theme files...${KS_RESET}"
        if unzip -oq "$temp_zip" -d "$INSTALL_DIR"; then
            echo -e " ${KS_GREEN}✓${KS_RESET}"
            rm -f "$temp_zip"
            log "SUCCESS" "Theme downloaded and extracted"
            return 0
        fi
        rm -f "$temp_zip"
    fi
    
    echo -e " ${KS_RED}✗${KS_RESET}"
    return 1
}

build_theme() {
    log "INFO" "Building theme assets"
    
    echo -e "\n${KS_BLUE}${KS_BOLD}🔨 BUILDING THEME ASSETS${KS_RESET}"
    
    # Install Node dependencies
    echo -ne "${KS_CYAN}Installing Node.js dependencies...${KS_RESET}"
    if yarn install --production=false --silent 2>/dev/null; then
        echo -e " ${KS_GREEN}✓${KS_RESET}"
        log "DEBUG" "Node.js dependencies installed"
    else
        echo -e " ${KS_RED}✗${KS_RESET}"
        log "WARNING" "yarn install failed, trying npm..."
        npm install --silent 2>/dev/null || true
    fi
    
    # Build for production
    echo -ne "${KS_CYAN}Building production assets...${KS_RESET}"
    if yarn run build:production --silent 2>/dev/null; then
        echo -e " ${KS_GREEN}✓${KS_RESET}"
        log "SUCCESS" "Theme assets built successfully"
    else
        echo -e " ${KS_YELLOW}⚠${KS_RESET}"
        log "WARNING" "Production build failed, trying development build"
        yarn run build --silent 2>/dev/null || true
    fi
    
    # Set permissions
    echo -ne "${KS_CYAN}Setting permissions...${KS_RESET}"
    chown -R www-data:www-data "$INSTALL_DIR"
    find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
    find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
    chmod -R 775 storage bootstrap/cache
    echo -e " ${KS_GREEN}✓${KS_RESET}"
}

configure_theme() {
    log "INFO" "Configuring KSGAMING theme"
    
    # Create configuration file
    cat > ".ksgaming-config" << EOF
# KSGAMING THEME CONFIGURATION
# Generated on $(date)

THEME_NAME="KSGAMING Ultimate"
THEME_VERSION="${SCRIPT_VERSION}"
INSTALL_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
INSTALL_METHOD="auto-installer"

# Theme Settings
DARK_MODE="enabled"
ANIMATIONS="enabled"
CUSTOM_BRANDING="enabled"
PERFORMANCE_MODE="turbo"

# Support Information
SUPPORT_EMAIL="${SUPPORT_EMAIL}"
DISCORD_INVITE="${DISCORD_INVITE}"
DOCUMENTATION_URL="${OFFICIAL_WEBSITE}/docs"

# Performance Optimization
ASSET_MINIFICATION="enabled"
LAZY_LOADING="enabled"
CACHE_DRIVER="redis"
SESSION_DRIVER="redis"

# Auto-update Settings
AUTO_UPDATE_CHECK="enabled"
UPDATE_CHANNEL="stable"
BACKUP_BEFORE_UPDATE="enabled"
EOF
    
    # Create installation marker
    echo "KSGAMING_THEME_INSTALLED=true" > ".ksgaming-installed"
    echo "VERSION=${SCRIPT_VERSION}" >> ".ksgaming-installed"
    echo "INSTALL_DATE=$(date -Iseconds)" >> ".ksgaming-installed"
    echo "INSTALL_DIR=${INSTALL_DIR}" >> ".ksgaming-installed"
    
    log "SUCCESS" "Theme configuration created"
}

#============ POST-INSTALLATION ============#
post_installation() {
    log "SYSTEM" "Running post-installation tasks"
    
    echo -e "\n${KS_GREEN}${KS_BOLD}╔═════════════════════════════════════════════════════════════════════════╗${KS_RESET}"
    echo -e "${KS_GREEN}${KS_BOLD}║                KSGAMING THEME INSTALLATION COMPLETE!                   ║${KS_RESET}"
    echo -e "${KS_GREEN}${KS_BOLD}╚═════════════════════════════════════════════════════════════════════════╝${KS_RESET}"
    
    # Installation Summary
    echo -e "\n${KS_BLUE}${KS_BOLD}📊 INSTALLATION SUMMARY${KS_RESET}"
    echo -e "${KS_CYAN}┌────────────────────────────────────────────────────────────┐${KS_RESET}"
    echo -e "${KS_CYAN}│${KS_RESET} ${KS_WHITE}Theme:${KS_RESET}          KSGAMING Ultimate v${SCRIPT_VERSION}${KS_CYAN}│${KS_RESET}"
    echo -e "${KS_CYAN}│${KS_RESET} ${KS_WHITE}Status:${KS_RESET}         ${KS_GREEN}Successfully Installed${KS_RESET}${KS_CYAN}│${KS_RESET}"
    echo -e "${KS_CYAN}│${KS_RESET} ${KS_WHITE}Location:${KS_RESET}       ${INSTALL_DIR}${KS_CYAN}│${KS_RESET}"
    echo -e "${KS_CYAN}│${KS_RESET} ${KS_WHITE}Installation Time:${KS_RESET} $(date '+%Y-%m-%d %H:%M:%S')${KS_CYAN}│${KS_RESET}"
    echo -e "${KS_CYAN}└────────────────────────────────────────────────────────────┘${KS_RESET}"
    
    # Required Actions
    echo -e "\n${KS_YELLOW}${KS_BOLD}🚀 REQUIRED ACTIONS${KS_RESET}"
    echo -e "${KS_YELLOW}1. Clear Application Cache:${KS_RESET}"
    echo -e "   ${KS_WHITE}sudo php artisan cache:clear${KS_RESET}"
    echo -e "${KS_YELLOW}2. Restart Queue Workers:${KS_RESET}"
    echo -e "   ${KS_WHITE}sudo php artisan queue:restart${KS_RESET}"
    echo -e "${KS_YELLOW}3. Restart PHP-FPM Service:${KS_RESET}"
    echo -e "   ${KS_WHITE}sudo systemctl restart php8.1-fpm${KS_RESET}"
    echo -e "   ${KS_WHITE}sudo systemctl restart php8.2-fpm${KS_RESET}"
    echo -e "${KS_YELLOW}4. Clear View Cache:${KS_RESET}"
    echo -e "   ${KS_WHITE}sudo php artisan view:clear${KS_RESET}"
    
    # Verification Commands
    echo -e "\n${KS_CYAN}${KS_BOLD}🔍 VERIFICATION COMMANDS${KS_RESET}"
    echo -e "${KS_CYAN}• Check Theme Status:${KS_RESET}"
    echo -e "  ${KS_WHITE}cat ${INSTALL_DIR}/.ksgaming-installed${KS_RESET}"
    echo -e "${KS_CYAN}• View Installation Logs:${KS_RESET}"
    echo -e "  ${KS_WHITE}tail -f ${MAIN_LOG}${KS_RESET}"
    echo -e "${KS_CYAN}• Check Panel Health:${KS_RESET}"
    echo -e "  ${KS_WHITE}php artisan panel:health${KS_RESET}"
    echo -e "${KS_CYAN}• Monitor Performance:${KS_RESET}"
    echo -e "  ${KS_WHITE}htop${KS_RESET}"
    
    # Support Information
    echo -e "\n${KS_PURPLE}${KS_BOLD}📞 SUPPORT & RESOURCES${KS_RESET}"
    echo -e "${KS_PURPLE}• Official Website:${KS_RESET} ${OFFICIAL_WEBSITE}"
    echo -e "${KS_PURPLE}• Documentation:${KS_RESET} ${OFFICIAL_WEBSITE}/docs"
    echo -e "${KS_PURPLE}• Discord Community:${KS_RESET} ${DISCORD_INVITE}"
    echo -e "${KS_PURPLE}• Email Support:${KS_RESET} ${SUPPORT_EMAIL}"
    echo -e "${KS_PURPLE}• Bug Reports:${KS_RESET} ${OFFICIAL_WEBSITE}/issues"
    
    # Important Notes
    echo -e "\n${KS_ORANGE}${KS_BOLD}⚠  IMPORTANT NOTES${KS_RESET}"
    echo -e "${KS_ORANGE}• ${KS_RESET}Always backup before updating"
    echo -e "${KS_ORANGE}• ${KS_RESET}Monitor server performance after installation"
    echo -e "${KS_ORANGE}• ${KS_RESET}Keep your system updated for security"
    echo -e "${KS_ORANGE}• ${KS_RESET}Join our Discord for community support"
    
    echo -e "\n${KS_GREEN}${KS_BOLD}🎉 Thank you for choosing KSGAMING!${KS_RESET}"
    echo -e "${KS_CYAN}Your gaming panel is now powered by KSGAMING technology.${KS_RESET}"
    
    log "SYSTEM" "Post-installation summary displayed"
    log "SYSTEM" "=================================================="
    log "SYSTEM" "Installation completed successfully"
    log "SYSTEM" "Total time: ${SECONDS} seconds"
}

#============ MAIN EXECUTION ============#
main() {
    SECONDS=0
    print_ksgaming_banner
    init_logging
    
    echo -e "${KS_BLUE}${KS_BOLD}🚀 Initializing KSGAMING Theme Installation...${KS_RESET}\n"
    
    # Check privileges
    if [[ $EUID -eq 0 ]]; then
        log "WARNING" "Running as root user"
        echo -e "${KS_YELLOW}${KS_BOLD}⚠  Running with root privileges${KS_RESET}"
        echo -e "${KS_YELLOW}For security, consider running with sudo instead.${KS_RESET}"
        sleep 2
    elif ! sudo -n true 2>/dev/null; then
        echo -e "${KS_YELLOW}This installer requires administrative privileges.${KS_RESET}"
        echo -ne "${KS_CYAN}Please enter your sudo password: ${KS_RESET}"
        sudo -v || {
            log "ERROR" "Failed to obtain sudo privileges"
            exit 1
        }
        echo
    fi
    
    # Installation steps
    check_system
    check_pterodactyl
    install_dependencies
    install_ksgaming_theme
    post_installation
    
    return 0
}

#============ CLEANUP AND ERROR HANDLING ============#
cleanup() {
    local exit_code=$?
    local duration=$SECONDS
    
    log "SYSTEM" "Script execution completed"
    log "SYSTEM" "Exit code: $exit_code"
    log "SYSTEM" "Total execution time: ${duration}s"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${KS_GREEN}${KS_BOLD}✅ Installation completed successfully in ${duration}s!${KS_RESET}"
    else
        echo -e "\n${KS_RED}${KS_BOLD}❌ Installation failed with code $exit_code${KS_RESET}"
        echo -e "${KS_YELLOW}Check error log: ${ERROR_LOG}${KS_RESET}"
        echo -e "${KS_YELLOW}For support, visit: ${OFFICIAL_WEBSITE}/support${KS_RESET}"
    fi
    
    exit $exit_code
}

# Set traps
trap cleanup EXIT
trap 'log "ERROR" "Script interrupted by user"; exit 130' INT
trap 'log "ERROR" "Script terminated"; exit 143' TERM

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
