#!/bin/bash
#==============================================================================
#   🚀 KS GAMING PANEL THEME INSTALLER (Professional Edition)
#      Optimized for Debian/Ubuntu + Pterodactyl Control Panel
#      Official KS Gaming Theme - Version 2.0
#      Copyright © 2024 KS Gaming Solutions. All rights reserved.
#==============================================================================

set -o errexit
set -o pipefail
set -o nounset

#============ ENVIRONMENT CONFIGURATION ============#
readonly SCRIPT_VERSION="2.0.0"
readonly SUPPORTED_OS=("debian" "ubuntu")
readonly MINIMUM_MEMORY=2048  # 2GB in MB
readonly REQUIRED_PANEL_VERSION="1.11.0"
readonly INSTALL_DIR="/var/www/pterodactyl"
readonly LOG_DIR="/var/log/ks-gaming"
readonly BACKUP_DIR="/var/backups/ks-gaming"

#============ COLOR DEFINITIONS ============#
readonly COLOR_BLUE='\033[0;94m'
readonly COLOR_GREEN='\033[0;92m'
readonly COLOR_RED='\033[0;91m'
readonly COLOR_YELLOW='\033[0;93m'
readonly COLOR_CYAN='\033[0;96m'
readonly COLOR_MAGENTA='\033[0;95m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'

#============ ASCII BANNER ============#
print_banner() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    cat << "EOF"
  _  _______   _____                         _____                               
 | |/ /  __ \ / ____|                       / ____|                              
 | ' /| |__) | (___  _ __   __ _  ___ ___  | |  __  __ _ _ __ ___   ___          
 |  < |  _  / \___ \| '_ \ / _` |/ __/ _ \ | | |_ |/ _` | '_ ` _ \ / _ \         
 | . \| | \ \ ____) | |_) | (_| | (_|  __/ | |__| | (_| | | | | | |  __/         
 |_|\_\_|  \_\_____/| .__/ \__,_|\___\___|  \_____|\__,_|_| |_| |_|\___|        
                    | |                                                          
                    |_|        G A M I N G   S O L U T I O N S                   
EOF
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}║    Professional Gaming Panel Theme Installer v${SCRIPT_VERSION}    ║${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}║           Optimized for High-Performance Gaming Servers         ║${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo
}

#============ LOGGING SYSTEM ============#
initialize_logging() {
    mkdir -p "$LOG_DIR"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    readonly LOG_FILE="$LOG_DIR/install_${timestamp}.log"
    readonly ERROR_LOG="$LOG_DIR/errors_${timestamp}.log"
    
    exec > >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$ERROR_LOG" >&2)
    
    log_message "INFO" "KS Gaming Installer v${SCRIPT_VERSION} initialized"
    log_message "INFO" "Installation started at $(date)"
}

log_message() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

#============ VALIDATION FUNCTIONS ============#
validate_environment() {
    log_message "INFO" "Starting environment validation"
    
    # Check OS compatibility
    local os_name=$(lsb_release -si 2>/dev/null || echo "unknown")
    local os_version=$(lsb_release -sr 2>/dev/null || echo "0")
    
    if [[ ! "${SUPPORTED_OS[@]}" =~ ${os_name,,} ]]; then
        fail_with_error "UNSUPPORTED_OS" "This installer only supports Debian/Ubuntu systems. Detected: $os_name"
    fi
    
    log_message "SUCCESS" "OS validated: $os_name $os_version"
    
    # Check memory requirements
    local total_memory=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_memory -lt $MINIMUM_MEMORY ]]; then
        show_warning "Insufficient memory: ${total_memory}MB detected, ${MINIMUM_MEMORY}MB recommended"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
    
    # Check disk space
    local available_space=$(df /var --output=avail | tail -1)
    if [[ $available_space -lt 5242880 ]]; then
        fail_with_error "INSUFFICIENT_DISK_SPACE" "Minimum 5GB free space required in /var"
    fi
    
    log_message "SUCCESS" "System requirements validated successfully"
}

check_pterodactyl_installation() {
    log_message "INFO" "Checking Pterodactyl installation"
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        fail_with_error "PTERODACTYL_NOT_FOUND" "Pterodactyl installation not found in $INSTALL_DIR"
    fi
    
    if [[ ! -f "$INSTALL_DIR/app/Models/User.php" ]]; then
        fail_with_error "INVALID_PTERODACTYL" "Invalid Pterodactyl installation detected"
    fi
    
    # Check panel version
    if [[ -f "$INSTALL_DIR/composer.json" ]]; then
        local panel_version=$(grep '"version"' "$INSTALL_DIR/composer.json" | cut -d'"' -f4)
        log_message "INFO" "Detected Pterodactyl version: $panel_version"
    fi
    
    log_message "SUCCESS" "Pterodactyl installation validated"
}

#============ ERROR HANDLING ============#
fail_with_error() {
    local error_code="$1"
    local error_message="$2"
    
    echo -e "\n${COLOR_RED}${COLOR_BOLD}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_RED}${COLOR_BOLD}║                    INSTALLATION FAILED                       ║${COLOR_RESET}"
    echo -e "${COLOR_RED}${COLOR_BOLD}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo -e "${COLOR_RED}Error Code: $error_code${COLOR_RESET}"
    echo -e "${COLOR_RED}Error Message: $error_message${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}Check log file for details: $LOG_FILE${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}Error log: $ERROR_LOG${COLOR_RESET}"
    
    log_message "ERROR" "Installation failed: $error_code - $error_message"
    
    # Offer troubleshooting
    if [[ $error_code == "PTERODACTYL_NOT_FOUND" ]]; then
        echo -e "\n${COLOR_CYAN}Troubleshooting:${COLOR_RESET}"
        echo "1. Ensure Pterodactyl is installed in $INSTALL_DIR"
        echo "2. Run the installer from the correct panel directory"
        echo "3. Check permissions on /var/www"
    fi
    
    exit 1
}

show_warning() {
    local warning_message="$1"
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}⚠  WARNING:${COLOR_RESET} ${COLOR_YELLOW}$warning_message${COLOR_RESET}"
    log_message "WARNING" "$warning_message"
}

show_success() {
    local success_message="$1"
    echo -e "${COLOR_GREEN}${COLOR_BOLD}✓ SUCCESS:${COLOR_RESET} ${COLOR_GREEN}$success_message${COLOR_RESET}"
    log_message "SUCCESS" "$success_message"
}

#============ PROGRESS INDICATOR ============#
show_progress() {
    local task="$1"
    echo -ne "${COLOR_CYAN}${COLOR_BOLD}[•]${COLOR_RESET} ${COLOR_CYAN}$task${COLOR_RESET}"
    
    # Animated dots
    for i in {1..3}; do
        echo -ne "${COLOR_CYAN}.${COLOR_RESET}"
        sleep 0.2
    done
    echo
}

#============ DEPENDENCY MANAGEMENT ============#
install_dependencies() {
    log_message "INFO" "Installing system dependencies"
    
    local dependencies=(
        curl
        wget
        unzip
        git
        zip
        ca-certificates
        gnupg
        lsb-release
        software-properties-common
        apt-transport-https
    )
    
    show_progress "Updating package repositories"
    apt-get update -q > /dev/null 2>&1 || fail_with_error "UPDATE_FAILED" "Failed to update package repositories"
    
    for dep in "${dependencies[@]}"; do
        show_progress "Checking $dep"
        if ! dpkg -l | grep -q "^ii  $dep "; then
            apt-get install -y -q "$dep" > /dev/null 2>&1 || \
            fail_with_error "DEPENDENCY_FAILED" "Failed to install $dep"
            log_message "INFO" "Installed dependency: $dep"
        fi
    done
    
    show_success "All dependencies installed"
}

#============ NODE.JS MANAGEMENT ============#
setup_node_environment() {
    log_message "INFO" "Setting up Node.js environment"
    
    # Remove existing Node.js if not version 20
    if command -v node > /dev/null 2>&1; then
        local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ $node_version -ne 20 ]]; then
            show_progress "Removing Node.js v$node_version"
            apt-get remove -y --purge nodejs npm > /dev/null 2>&1
            rm -rf /etc/apt/sources.list.d/nodesource.list
            log_message "INFO" "Removed Node.js version $node_version"
        fi
    fi
    
    # Install Node.js 20
    show_progress "Installing Node.js 20.x"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1 || \
        fail_with_error "NODESOURCE_FAILED" "Failed to setup NodeSource repository"
    
    apt-get install -y nodejs > /dev/null 2>&1 || \
        fail_with_error "NODE_INSTALL_FAILED" "Failed to install Node.js"
    
    # Install yarn via corepack
    show_progress "Setting up Yarn package manager"
    npm install -g corepack > /dev/null 2>&1 || \
        fail_with_error "COREPACK_FAILED" "Failed to install corepack"
    
    corepack enable > /dev/null 2>&1
    corepack prepare yarn@stable --activate > /dev/null 2>&1
    
    show_success "Node.js environment configured"
    log_message "INFO" "Node.js $(node --version) installed"
    log_message "INFO" "Yarn $(yarn --version) installed"
}

#============ THEME INSTALLATION ============#
install_ks_theme() {
    log_message "INFO" "Starting KS Gaming theme installation"
    
    cd "$INSTALL_DIR" || fail_with_error "DIRECTORY_CHANGE_FAILED" "Cannot access $INSTALL_DIR"
    
    # Create backup before installation
    create_backup
    
    # Download KS Gaming theme
    show_progress "Downloading KS Gaming theme package"
    
    local theme_url="https://github.com/KS-Gaming-Dev/panel-theme/releases/latest/download/ks-gaming-theme.zip"
    local temp_zip="/tmp/ks-gaming-theme-$(date +%s).zip"
    
    curl -L -o "$temp_zip" "$theme_url" 2>&1 | \
        while read line; do 
            if [[ $line =~ % ]]; then 
                echo -ne "\r${COLOR_CYAN}Downloading: ${line##* }${COLOR_RESET}"
            fi
        done
    
    echo
    [[ ! -f "$temp_zip" ]] && fail_with_error "DOWNLOAD_FAILED" "Theme download failed"
    
    # Extract theme
    show_progress "Extracting theme files"
    unzip -oq "$temp_zip" -d "$INSTALL_DIR" || \
        fail_with_error "EXTRACTION_FAILED" "Failed to extract theme files"
    rm -f "$temp_zip"
    
    # Install frontend dependencies
    show_progress "Installing frontend dependencies"
    yarn install --production=false --silent > /dev/null 2>&1 || \
        fail_with_error "YARN_FAILED" "Failed to install dependencies"
    
    # Build assets
    show_progress "Building theme assets"
    yarn run build:production --silent > /dev/null 2>&1 || \
        fail_with_error "BUILD_FAILED" "Failed to build theme assets"
    
    # Set permissions
    show_progress "Setting correct permissions"
    chown -R www-data:www-data "$INSTALL_DIR"
    find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
    find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
    chmod -R 775 "$INSTALL_DIR/storage" "$INSTALL_DIR/bootstrap/cache"
    
    # Create configuration
    if [[ ! -f "$INSTALL_DIR/.ksgamingrc" ]]; then
        cat > "$INSTALL_DIR/.ksgamingrc" << EOF
# KS Gaming Theme Configuration
# Generated on $(date)

THEME_NAME="KS Gaming Professional"
THEME_VERSION="${SCRIPT_VERSION}"
INSTALL_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
MAINTENANCE_MODE="false"
CACHE_DRIVER="redis"
SESSION_DRIVER="redis"

# Performance Settings
ASSET_CACHING="enabled"
COMPRESSION="enabled"
LAZY_LOADING="enabled"
EOF
    fi
    
    # Mark installation
    echo "KS_GAMING_THEME_INSTALLED=true" > "$INSTALL_DIR/.ksgaming-installed"
    echo "INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')" >> "$INSTALL_DIR/.ksgaming-installed"
    echo "INSTALL_VERSION=${SCRIPT_VERSION}" >> "$INSTALL_DIR/.ksgaming-installed"
    
    show_success "KS Gaming theme installed successfully"
    log_message "SUCCESS" "Theme installation completed"
}

create_backup() {
    log_message "INFO" "Creating installation backup"
    
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
    
    show_progress "Creating system backup"
    
    # Backup important directories
    tar -czf "$backup_file" \
        "$INSTALL_DIR/public/themes" \
        "$INSTALL_DIR/resources" \
        "$INSTALL_DIR/routes" \
        "$INSTALL_DIR/database/migrations" \
        2>/dev/null || true
    
    log_message "INFO" "Backup created: $backup_file"
    show_success "System backup created"
}

#============ POST-INSTALLATION ============#
post_installation() {
    log_message "INFO" "Running post-installation tasks"
    
    echo -e "\n${COLOR_GREEN}${COLOR_BOLD}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_GREEN}${COLOR_BOLD}║          KS GAMING THEME INSTALLATION COMPLETE              ║${COLOR_RESET}"
    echo -e "${COLOR_GREEN}${COLOR_BOLD}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    
    echo -e "\n${COLOR_CYAN}${COLOR_BOLD}📊 Installation Summary:${COLOR_RESET}"
    echo -e "${COLOR_CYAN}├─ Theme:${COLOR_RESET} KS Gaming Professional v${SCRIPT_VERSION}"
    echo -e "${COLOR_CYAN}├─ Location:${COLOR_RESET} $INSTALL_DIR"
    echo -e "${COLOR_CYAN}├─ Installed at:${COLOR_RESET} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${COLOR_CYAN}├─ Log file:${COLOR_RESET} $LOG_FILE"
    echo -e "${COLOR_CYAN}└─ Backup:${COLOR_RESET} $BACKUP_DIR"
    
    echo -e "\n${COLOR_MAGENTA}${COLOR_BOLD}🚀 Required Actions:${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}1.${COLOR_RESET} Clear application cache:"
    echo -e "   ${COLOR_YELLOW}sudo php artisan cache:clear${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}2.${COLOR_RESET} Restart queue workers:"
    echo -e "   ${COLOR_YELLOW}sudo php artisan queue:restart${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}3.${COLOR_RESET} Restart PHP-FPM service:"
    echo -e "   ${COLOR_YELLOW}sudo systemctl restart php-fpm${COLOR_RESET}"
    
    echo -e "\n${COLOR_GREEN}${COLOR_Bold}🔧 Verification Commands:${COLOR_RESET}"
    echo -e "   ${COLOR_CYAN}Check theme status:${COLOR_RESET} cat $INSTALL_DIR/.ksgaming-installed"
    echo -e "   ${COLOR_CYAN}View installation logs:${COLOR_RESET} tail -f $LOG_FILE"
    echo -e "   ${COLOR_CYAN}Check panel health:${COLOR_RESET} php artisan panel:health"
    
    echo -e "\n${COLOR_YELLOW}${COLOR_BOLD}⚠  Important Notes:${COLOR_RESET}"
    echo -e "   • Always create backups before updating"
    echo -e "   • Monitor server performance after installation"
    echo -e "   • Report issues to support@ks-gaming.dev"
    
    echo -e "\n${COLOR_GREEN}${COLOR_BOLD}🎉 Thank you for choosing KS Gaming Solutions!${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Visit https://docs.ks-gaming.dev for documentation and support${COLOR_RESET}"
    
    log_message "SUCCESS" "Post-installation summary displayed"
}

#============ MAIN EXECUTION ============#
main() {
    print_banner
    initialize_logging
    
    echo -e "${COLOR_BLUE}${COLOR_BOLD}Initializing KS Gaming Theme Installation...${COLOR_RESET}\n"
    
    # Check for sudo privileges
    if [[ $EUID -eq 0 ]]; then
        show_warning "Running as root user - consider using sudo for specific commands"
    elif ! sudo -n true 2>/dev/null; then
        echo -e "${COLOR_YELLOW}This installer requires sudo privileges.${COLOR_RESET}"
        sudo -v || fail_with_error "PRIVILEGE_ERROR" "Insufficient privileges"
    fi
    
    # Run installation steps
    validate_environment
    check_pterodactyl_installation
    install_dependencies
    setup_node_environment
    install_ks_theme
    post_installation
    
    log_message "SUCCESS" "KS Gaming theme installation completed successfully"
    return 0
}

# Cleanup on exit
cleanup() {
    local exit_code=$?
    log_message "INFO" "Script exiting with code $exit_code"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${COLOR_GREEN}${COLOR_BOLD}✅ Installation completed successfully!${COLOR_RESET}"
    fi
    
    exit $exit_code
}

trap cleanup EXIT INT TERM

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
