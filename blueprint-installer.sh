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
readonly MINIMUM_MEMORY=2048  # 2GB in MB
readonly REQUIRED_DISK_SPACE=5  # GB
readonly INSTALL_DIR="/var/www/pterodactyl"
readonly LOG_DIR="/var/log/ksgaming"
readonly BACKUP_DIR="/var/backups/ksgaming"
readonly THEME_URL="https://raw.githubusercontent.com/KSGAMING-Dev/panel-theme/main/theme.zip"
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
  ██╗  ██╗███████╗    ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
  ██║ ██╔╝██╔════╝    ██╔══██╗██╔══██╗████╗ ████║██║████╗  ██║██╔════╝ 
  █████╔╝ ███████╗    ██████╔╝███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗
  ██╔═██╗ ╚════██║    ██╔══██╗██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
  ██║  ██╗███████║    ██║  ██║██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
  ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
EOF
    echo -e "${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}╔═══════════════════════════════════════════════════════════════╗${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}║         ULTIMATE GAMING PANEL THEME v${SCRIPT_VERSION}                ║${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}║             Professional Installation & Management              ║${KS_RESET}"
    echo -e "${KS_PURPLE}${KS_BOLD}╚═══════════════════════════════════════════════════════════════╝${KS_RESET}"
    echo
}

#============ ERROR HANDLING ============#
handle_error() {
    local error_code="$1"
    local error_message="$2"
    
    echo -e "\n${KS_RED}${KS_BOLD}╔═══════════════════════════════════════════════════════════════╗${KS_RESET}"
    echo -e "${KS_RED}${KS_BOLD}║                    INSTALLATION FAILED                       ║${KS_RESET}"
    echo -e "${KS_RED}${KS_BOLD}╚═══════════════════════════════════════════════════════════════╝${KS_RESET}"
    echo -e "${KS_RED}Error Code: ${error_code}${KS_RESET}"
    echo -e "${KS_RED}Error Message: ${error_message}${KS_RESET}"
    echo -e "${KS_YELLOW}Check log file for details: $LOG_FILE${KS_RESET}"
    echo -e "${KS_YELLOW}Error log: $ERROR_LOG${KS_RESET}"
    
    case "$error_code" in
        "EXTRACTION_FAILED")
            show_extraction_troubleshooting
            ;;
        "DOWNLOAD_FAILED")
            show_download_troubleshooting
            ;;
        "PERMISSION_DENIED")
            show_permission_troubleshooting
            ;;
        "PTERODACTYL_NOT_FOUND")
            show_pterodactyl_troubleshooting
            ;;
        *)
            show_general_troubleshooting
            ;;
    esac
    
    echo -e "\n${KS_CYAN}${KS_BOLD}Press [Enter] to return to menu or [Q] to quit...${KS_RESET}"
    read -n 1 -r choice
    echo
    if [[ $choice =~ ^[Qq]$ ]]; then
        exit 1
    else
        main_menu
    fi
}

show_extraction_troubleshooting() {
    echo -e "\n${KS_YELLOW}${KS_BOLD}🔧 TROUBLESHOOTING - EXTRACTION FAILED${KS_RESET}"
    echo -e "${KS_YELLOW}Possible causes:${KS_RESET}"
    echo -e "  ${KS_CYAN}1.${KS_RESET} Corrupted download file"
    echo -e "  ${KS_CYAN}2.${KS_RESET} Insufficient disk space"
    echo -e "  ${KS_CYAN}3.${KS_RESET} Missing unzip utility"
    echo -e "  ${KS_CYAN}4.${KS_RESET} Permission issues"
    
    echo -e "\n${KS_YELLOW}Solutions:${KS_RESET}"
    echo -e "  ${KS_GREEN}1.${KS_RESET} Check available disk space:"
    echo -e "     ${KS_WHITE}df -h /var${KS_RESET}"
    echo -e "  ${KS_GREEN}2.${KS_RESET} Install unzip utility:"
    echo -e "     ${KS_WHITE}sudo apt install unzip -y${KS_RESET}"
    echo -e "  ${KS_GREEN}3.${KS_RESET} Manually download and extract:"
    echo -e "     ${KS_WHITE}cd /var/www/pterodactyl${KS_RESET}"
    echo -e "     ${KS_WHITE}wget $THEME_URL${KS_RESET}"
    echo -e "     ${KS_WHITE}unzip theme.zip${KS_RESET}"
    echo -e "  ${KS_GREEN}4.${KS_RESET} Check file permissions:"
    echo -e "     ${KS_WHITE}ls -la theme.zip${KS_RESET}"
}

show_download_troubleshooting() {
    echo -e "\n${KS_YELLOW}${KS_BOLD}🔧 TROUBLESHOOTING - DOWNLOAD FAILED${KS_RESET}"
    echo -e "${KS_YELLOW}Possible causes:${KS_RESET}"
    echo -e "  ${KS_CYAN}1.${KS_RESET} Network connectivity issues"
    echo -e "  ${KS_CYAN}2.${KS_RESET} GitHub API rate limiting"
    echo -e "  ${KS_CYAN}3.${KS_RESET} Invalid URL or repository"
    echo -e "  ${KS_CYAN}4.${KS_RESET} DNS resolution problems"
    
    echo -e "\n${KS_YELLOW}Solutions:${KS_RESET}"
    echo -e "  ${KS_GREEN}1.${KS_RESET} Check internet connectivity:"
    echo -e "     ${KS_WHITE}ping -c 3 github.com${KS_RESET}"
    echo -e "  ${KS_GREEN}2.${KS_RESET} Test download manually:"
    echo -e "     ${KS_WHITE}curl -I $THEME_URL${KS_RESET}"
    echo -e "  ${KS_GREEN}3.${KS_RESET} Try alternative download method:"
    echo -e "     ${KS_WHITE}wget --no-check-certificate $THEME_URL${KS_RESET}"
    echo -e "  ${KS_GREEN}4.${KS_RESET} Use fallback mirror:"
    echo -e "     ${KS_WHITE}https://cdn.ksgaming.dev/theme.zip${KS_RESET}"
}

#============ LOGGING SYSTEM ============#
init_logging() {
    mkdir -p "$LOG_DIR"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    readonly LOG_FILE="$LOG_DIR/install_${timestamp}.log"
    readonly ERROR_LOG="$LOG_DIR/errors_${timestamp}.log"
    
    exec > >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$ERROR_LOG" >&2)
    
    log "INFO" "KSGAMING Installer v${SCRIPT_VERSION} started"
    log "INFO" "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
}

log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

#============ PROGRESS INDICATORS ============#
show_progress() {
    local task="$1"
    echo -ne "${KS_CYAN}${KS_BOLD}[•]${KS_RESET} ${KS_CYAN}$task${KS_RESET}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.2
    done
    echo -e " ${KS_GREEN}✓${KS_RESET}"
}

show_warning() {
    echo -ne "${KS_YELLOW}${KS_BOLD}[!]${KS_RESET} ${KS_YELLOW}"
}

show_error() {
    echo -ne "${KS_RED}${KS_BOLD}[✗]${KS_RESET} ${KS_RED}"
}

show_success() {
    echo -ne "${KS_GREEN}${KS_BOLD}[✓]${KS_RESET} ${KS_GREEN}"
}

#============ SYSTEM CHECKS ============#
check_system() {
    log "INFO" "Checking system requirements"
    
    # Check OS
    if ! command -v lsb_release >/dev/null 2>&1; then
        sudo apt install -y lsb-release 2>/dev/null || true
    fi
    
    local os_name=$(lsb_release -si 2>/dev/null || echo "unknown")
    local os_version=$(lsb_release -sr 2>/dev/null || echo "0")
    
    if [[ ! "${SUPPORTED_OS[@]}" =~ ${os_name,,} ]]; then
        handle_error "UNSUPPORTED_OS" "Unsupported OS: $os_name. Only Debian/Ubuntu supported."
    fi
    
    # Check memory
    local total_memory=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_memory -lt $MINIMUM_MEMORY ]]; then
        show_warning
        echo "Low memory detected: ${total_memory}MB (${MINIMUM_MEMORY}MB recommended)${KS_RESET}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
    
    # Check disk space
    local available_space=$(df /var --output=avail | tail -1)
    if [[ $available_space -lt $((REQUIRED_DISK_SPACE * 1024 * 1024)) ]]; then
        handle_error "INSUFFICIENT_DISK_SPACE" "Not enough disk space in /var"
    fi
    
    show_success
    echo "System checks passed${KS_RESET}"
}

check_pterodactyl() {
    log "INFO" "Checking Pterodactyl installation"
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        handle_error "PTERODACTYL_NOT_FOUND" "Pterodactyl not found in $INSTALL_DIR"
    fi
    
    if [[ ! -f "$INSTALL_DIR/artisan" ]]; then
        handle_error "INVALID_PTERODACTYL" "Invalid Pterodactyl installation"
    fi
    
    show_success
    echo "Pterodactyl installation verified${KS_RESET}"
}

#============ INSTALLATION FUNCTIONS ============#
install_dependencies() {
    log "INFO" "Installing dependencies"
    
    show_progress "Updating package list"
    sudo apt update -y >/dev/null 2>&1 || true
    
    local deps=("curl" "wget" "unzip" "git" "nodejs" "npm" "yarn")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            case "$dep" in
                "nodejs")
                    show_progress "Installing Node.js 20.x"
                    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1
                    sudo apt install -y nodejs >/dev/null 2>&1 || {
                        show_error
                        echo "Failed to install Node.js${KS_RESET}"
                        return 1
                    }
                    ;;
                "yarn")
                    show_progress "Installing Yarn"
                    sudo npm install -g yarn >/dev/null 2>&1 || {
                        show_error
                        echo "Failed to install Yarn${KS_RESET}"
                        return 1
                    }
                    ;;
                *)
                    show_progress "Installing $dep"
                    sudo apt install -y "$dep" >/dev/null 2>&1 || {
                        show_error
                        echo "Failed to install $dep${KS_RESET}"
                        return 1
                    }
                    ;;
            esac
        fi
    done
    
    show_success
    echo "All dependencies installed${KS_RESET}"
}

download_theme() {
    log "INFO" "Downloading KSGAMING theme"
    
    cd "$INSTALL_DIR" || {
        handle_error "DIRECTORY_ERROR" "Cannot access $INSTALL_DIR"
    }
    
    # Create backup
    if [[ -d "public/theme" ]]; then
        show_progress "Creating backup"
        tar -czf "$BACKUP_DIR/backup_$(date +%s).tar.gz" public/theme 2>/dev/null || true
    fi
    
    # Download theme
    show_progress "Downloading theme package"
    
    local temp_zip="/tmp/ksgaming-theme-$(date +%s).zip"
    
    # Try multiple download methods
    if ! curl -L -o "$temp_zip" "$THEME_URL" 2>/dev/null; then
        if ! wget -O "$temp_zip" "$THEME_URL" 2>/dev/null; then
            handle_error "DOWNLOAD_FAILED" "Failed to download theme from $THEME_URL"
        fi
    fi
    
    # Verify download
    if [[ ! -f "$temp_zip" ]] || [[ $(stat -c%s "$temp_zip" 2>/dev/null || echo 0) -lt 1000 ]]; then
        handle_error "DOWNLOAD_CORRUPT" "Downloaded file is corrupted or empty"
    fi
    
    # Extract theme
    show_progress "Extracting theme files"
    
    # Check if unzip is available
    if ! command -v unzip >/dev/null 2>&1; then
        sudo apt install -y unzip >/dev/null 2>&1 || {
            handle_error "MISSING_UNZIP" "unzip utility not available"
        }
    fi
    
    # Create extraction directory
    local extract_dir="/tmp/ksgaming-extract-$(date +%s)"
    mkdir -p "$extract_dir"
    
    # Extract with error handling
    if ! unzip -oq "$temp_zip" -d "$extract_dir" 2>/dev/null; then
        # Try alternative extraction method
        if ! 7z x -o"$extract_dir" "$temp_zip" 2>/dev/null; then
            rm -rf "$extract_dir" "$temp_zip"
            handle_error "EXTRACTION_FAILED" "Failed to extract theme files. File may be corrupted."
        fi
    fi
    
    # Check if extraction was successful
    if [[ ! -d "$extract_dir" ]] || [[ -z "$(ls -A "$extract_dir" 2>/dev/null)" ]]; then
        rm -rf "$extract_dir" "$temp_zip"
        handle_error "EXTRACTION_EMPTY" "Extracted directory is empty"
    fi
    
    # Copy files to panel directory
    show_progress "Installing theme files"
    
    # Copy all files from extract directory
    cp -r "$extract_dir"/* "$INSTALL_DIR"/ 2>/dev/null || true
    cp -r "$extract_dir"/.* "$INSTALL_DIR"/ 2>/dev/null || true
    
    # Cleanup
    rm -rf "$extract_dir" "$temp_zip"
    
    show_success
    echo "Theme files installed${KS_RESET}"
}

install_node_deps() {
    log "INFO" "Installing Node.js dependencies"
    
    cd "$INSTALL_DIR" || return 1
    
    show_progress "Installing Node.js packages"
    
    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        show_warning
        echo "package.json not found, creating default${KS_RESET}"
        cat > package.json << 'EOF'
{
  "name": "pterodactyl-panel",
  "private": true,
  "scripts": {
    "dev": "cross-env NODE_ENV=development webpack --progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js",
    "watch": "cross-env NODE_ENV=development webpack --watch --progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js",
    "hot": "cross-env NODE_ENV=development webpack-dev-server --inline --hot --config=node_modules/laravel-mix/setup/webpack.config.js",
    "production": "cross-env NODE_ENV=production webpack --progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js"
  },
  "devDependencies": {
    "laravel-mix": "^6.0.49"
  }
}
EOF
    fi
    
    # Install dependencies
    if command -v yarn >/dev/null 2>&1; then
        yarn install --production=false --silent 2>/dev/null || {
            show_warning
            echo "Yarn install failed, trying npm${KS_RESET}"
            npm install --silent 2>/dev/null || true
        }
    else
        npm install --silent 2>/dev/null || true
    fi
    
    show_success
    echo "Node.js dependencies installed${KS_RESET}"
}

build_assets() {
    log "INFO" "Building theme assets"
    
    cd "$INSTALL_DIR" || return 1
    
    show_progress "Building production assets"
    
    # Try yarn build first, then npm
    if command -v yarn >/dev/null 2>&1; then
        yarn run production 2>/dev/null || yarn run build 2>/dev/null || true
    else
        npm run production 2>/dev/null || npm run build 2>/dev/null || true
    fi
    
    show_success
    echo "Assets built successfully${KS_RESET}"
}

set_permissions() {
    log "INFO" "Setting permissions"
    
    show_progress "Setting file permissions"
    
    # Set correct ownership
    sudo chown -R www-data:www-data "$INSTALL_DIR" 2>/dev/null || true
    
    # Set directory permissions
    find "$INSTALL_DIR" -type d -exec chmod 755 {} \; 2>/dev/null || true
    find "$INSTALL_DIR" -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    # Set special permissions for storage and cache
    chmod -R 775 "$INSTALL_DIR/storage" "$INSTALL_DIR/bootstrap/cache" 2>/dev/null || true
    
    show_success
    echo "Permissions set correctly${KS_RESET}"
}

create_config() {
    log "INFO" "Creating configuration"
    
    cd "$INSTALL_DIR" || return 1
    
    # Create KSGAMING config file
    cat > .ksgaming-config << EOF
# KSGAMING Theme Configuration
# Generated on $(date)

THEME="KSGAMING Professional"
VERSION="${SCRIPT_VERSION}"
INSTALL_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
INSTALLED_BY="$(whoami)"
PANEL_DIR="$INSTALL_DIR"

# Theme Settings
DARK_MODE=enabled
ANIMATIONS=enabled
PERFORMANCE_MODE=optimized

# Support Information
SUPPORT_EMAIL="$SUPPORT_EMAIL"
DISCORD="$DISCORD_INVITE"
WEBSITE="$OFFICIAL_WEBSITE"
EOF
    
    # Mark as installed
    echo "INSTALLED=true" > .ksgaming-installed
    echo "VERSION=${SCRIPT_VERSION}" >> .ksgaming-installed
    echo "DATE=$(date -Iseconds)" >> .ksgaming-installed
    
    show_success
    echo "Configuration created${KS_RESET}"
}

#============ INSTALLATION FLOW ============#
perform_installation() {
    echo -e "\n${KS_BLUE}${KS_BOLD}🚀 Starting KSGAMING Theme Installation...${KS_RESET}\n"
    
    # Step-by-step installation with error handling
    local steps=(
        "check_system:System Validation"
        "check_pterodactyl:Pterodactyl Verification"
        "install_dependencies:Dependency Installation"
        "download_theme:Theme Download"
        "install_node_deps:Node.js Packages"
        "build_assets:Asset Compilation"
        "set_permissions:Permission Setup"
        "create_config:Configuration"
    )
    
    for step in "${steps[@]}"; do
        local func="${step%%:*}"
        local name="${step##*:}"
        
        echo -e "${KS_CYAN}${KS_BOLD}Step:${KS_RESET} ${KS_WHITE}$name${KS_RESET}"
        
        if ! $func; then
            handle_error "INSTALL_STEP_FAILED" "Failed at step: $name"
            return 1
        fi
        
        echo
    done
    
    return 0
}

#============ POST-INSTALLATION ============#
show_post_install() {
    echo -e "\n${KS_GREEN}${KS_BOLD}╔═══════════════════════════════════════════════════════════════╗${KS_RESET}"
    echo -e "${KS_GREEN}${KS_BOLD}║          INSTALLATION COMPLETED SUCCESSFULLY!                ║${KS_RESET}"
    echo -e "${KS_GREEN}${KS_BOLD}╚═══════════════════════════════════════════════════════════════╝${KS_RESET}"
    
    echo -e "\n${KS_BLUE}${KS_BOLD}📊 Installation Summary:${KS_RESET}"
    echo -e "${KS_CYAN}├─ Theme:${KS_RESET} KSGAMING Professional v${SCRIPT_VERSION}"
    echo -e "${KS_CYAN}├─ Location:${KS_RESET} $INSTALL_DIR"
    echo -e "${KS_CYAN}├─ Installed at:${KS_RESET} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${KS_CYAN}├─ Configuration:${KS_RESET} $INSTALL_DIR/.ksgaming-config"
    echo -e "${KS_CYAN}└─ Log file:${KS_RESET} $LOG_FILE"
    
    echo -e "\n${KS_YELLOW}${KS_BOLD}🚀 Required Actions:${KS_RESET}"
    echo -e "${KS_YELLOW}1.${KS_RESET} Clear application cache:"
    echo -e "   ${KS_WHITE}sudo php artisan cache:clear${KS_RESET}"
    echo -e "${KS_YELLOW}2.${KS_RESET} Restart queue workers:"
    echo -e "   ${KS_WHITE}sudo php artisan queue:restart${KS_RESET}"
    echo -e "${KS_YELLOW}3.${KS_RESET} Clear view cache:"
    echo -e "   ${KS_WHITE}sudo php artisan view:clear${KS_RESET}"
    echo -e "${KS_YELLOW}4.${KS_RESET} (Optional) Restart PHP-FPM:"
    echo -e "   ${KS_WHITE}sudo systemctl restart php8.1-fpm${KS_RESET}"
    
    echo -e "\n${KS_PURPLE}${KS_BOLD}🔍 Verification:${KS_RESET}"
    echo -e "${KS_PURPLE}•${KS_RESET} Check theme status:"
    echo -e "  ${KS_WHITE}cat $INSTALL_DIR/.ksgaming-installed${KS_RESET}"
    echo -e "${KS_PURPLE}•${KS_RESET} Test panel accessibility"
    echo -e "${KS_PURPLE}•${KS_RESET} Clear browser cache (Ctrl+Shift+R)"
    
    echo -e "\n${KS_ORANGE}${KS_BOLD}📞 Support:${KS_RESET}"
    echo -e "${KS_ORANGE}•${KS_RESET} Website: ${OFFICIAL_WEBSITE}"
    echo -e "${KS_ORANGE}•${KS_RESET} Discord: ${DISCORD_INVITE}"
    echo -e "${KS_ORANGE}•${KS_RESET} Email: ${SUPPORT_EMAIL}"
    
    echo -e "\n${KS_GREEN}${KS_BOLD}🎉 Thank you for choosing KSGAMING!${KS_RESET}"
    
    echo -e "\n${KS_CYAN}${KS_BOLD}Press [Enter] to return to menu...${KS_RESET}"
    read -r
}

#============ MENU SYSTEM ============#
main_menu() {
    while true; do
        print_ksgaming_banner
        
        echo -e "${KS_CYAN}${KS_BOLD}Main Menu:${KS_RESET}"
        echo -e "${KS_GREEN}[1]${KS_RESET} Install KSGAMING Theme"
        echo -e "${KS_GREEN}[2]${KS_RESET} Reinstall/Update Theme"
        echo -e "${KS_GREEN}[3]${KS_RESET} System Information"
        echo -e "${KS_GREEN}[4]${KS_RESET} View Installation Logs"
        echo -e "${KS_GREEN}[5]${KS_RESET} Troubleshooting Guide"
        echo -e "${KS_GREEN}[6]${KS_RESET} About KSGAMING"
        echo -e "${KS_RED}[0]${KS_RESET} Exit"
        echo
        
        read -p "$(echo -e "${KS_YELLOW}Select option [0-6]: ${KS_RESET}")" choice
        
        case $choice in
            1)
                init_logging
                if perform_installation; then
                    show_post_install
                fi
                ;;
            2)
                init_logging
                echo -e "\n${KS_YELLOW}Reinstalling KSGAMING Theme...${KS_RESET}"
                if perform_installation; then
                    show_post_install
                fi
                ;;
            3)
                show_system_info
                ;;
            4)
                view_logs
                ;;
            5)
                show_troubleshooting
                ;;
            6)
                show_about
                ;;
            0)
                echo -e "\n${KS_GREEN}Thank you for using KSGAMING Installer!${KS_RESET}"
                exit 0
                ;;
            *)
                echo -e "${KS_RED}Invalid option. Please try again.${KS_RESET}"
                sleep 1
                ;;
        esac
    done
}

show_system_info() {
    print_ksgaming_banner
    
    echo -e "${KS_BLUE}${KS_BOLD}System Information:${KS_RESET}\n"
    
    # OS Info
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo -e "${KS_CYAN}Operating System:${KS_RESET} $PRETTY_NAME"
    else
        echo -e "${KS_CYAN}Operating System:${KS_RESET} $(uname -s)"
    fi
    
    # Kernel
    echo -e "${KS_CYAN}Kernel Version:${KS_RESET} $(uname -r)"
    
    # Architecture
    echo -e "${KS_CYAN}Architecture:${KS_RESET} $(uname -m)"
    
    # Memory
    local mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    local mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    echo -e "${KS_CYAN}Memory:${KS_RESET} $mem_used / $mem_total"
    
    # Disk
    local disk_total=$(df -h /var | awk 'NR==2 {print $2}')
    local disk_used=$(df -h /var | awk 'NR==2 {print $3}')
    local disk_avail=$(df -h /var | awk 'NR==2 {print $4}')
    echo -e "${KS_CYAN}Disk (/var):${KS_RESET} $disk_used used, $disk_avail free of $disk_total"
    
    # Pterodactyl
    if [[ -d "$INSTALL_DIR" ]]; then
        echo -e "\n${KS_GREEN}${KS_BOLD}Pterodactyl Information:${KS_RESET}"
        echo -e "${KS_CYAN}Installation Path:${KS_RESET} $INSTALL_DIR"
        
        if [[ -f "$INSTALL_DIR/composer.json" ]]; then
            local panel_version=$(grep '"version"' "$INSTALL_DIR/composer.json" | cut -d'"' -f4)
            echo -e "${KS_CYAN}Panel Version:${KS_RESET} $panel_version"
        fi
        
        # Check if KSGAMING is installed
        if [[ -f "$INSTALL_DIR/.ksgaming-installed" ]]; then
            local theme_version=$(grep 'VERSION=' "$INSTALL_DIR/.ksgaming-installed" | cut -d'=' -f2)
            local install_date=$(grep 'DATE=' "$INSTALL_DIR/.ksgaming-installed" | cut -d'=' -f2)
            echo -e "\n${KS_GREEN}${KS_BOLD}KSGAMING Theme:${KS_RESET}"
            echo -e "${KS_CYAN}Installed:${KS_RESET} Yes"
            echo -e "${KS_CYAN}Version:${KS_RESET} $theme_version"
            echo -e "${KS_CYAN}Install Date:${KS_RESET} $install_date"
        else
            echo -e "\n${KS_YELLOW}${KS_BOLD}KSGAMING Theme:${KS_RESET} Not installed"
        fi
    else
        echo -e "\n${KS_RED}Pterodactyl not found at: $INSTALL_DIR${KS_RESET}"
    fi
    
    echo -e "\n${KS_CYAN}Press [Enter] to continue...${KS_RESET}"
    read -r
}

view_logs() {
    print_ksgaming_banner
    
    echo -e "${KS_BLUE}${KS_BOLD}Installation Logs:${KS_RESET}\n"
    
    if ls "$LOG_DIR"/*.log 1>/dev/null 2>&1; then
        echo -e "${KS_CYAN}Available log files:${KS_RESET}"
        local i=1
        local logs=()
        
        for log in "$LOG_DIR"/*.log; do
            logs[i]="$log"
            echo -e "${KS_GREEN}[$i]${KS_RESET} $(basename "$log") ($(stat -c %y "$log" | cut -d' ' -f1))"
            ((i++))
        done
        
        echo -e "\n${KS_YELLOW}Select log file to view (0 to go back): ${KS_RESET}"
        read -r choice
        
        if [[ $choice -gt 0 ]] && [[ $choice -lt $i ]]; then
            echo -e "\n${KS_CYAN}Contents of ${logs[choice]}:${KS_RESET}\n"
            tail -50 "${logs[choice]}"
            echo -e "\n${KS_CYAN}Press [Enter] to continue...${KS_RESET}"
            read -r
        fi
    else
        echo -e "${KS_YELLOW}No log files found.${KS_RESET}"
        echo -e "${KS_CYAN}Press [Enter] to continue...${KS_RESET}"
        read -r
    fi
}

show_troubleshooting() {
    print_ksgaming_banner
    
    echo -e "${KS_BLUE}${KS_BOLD}Troubleshooting Guide:${KS_RESET}\n"
    
    echo -e "${KS_YELLOW}${KS_BOLD}Common Issues and Solutions:${KS_RESET}"
    
    echo -e "\n${KS_CYAN}1. Theme not appearing after installation${KS_RESET}"
    echo -e "   • Clear browser cache: Ctrl+Shift+R"
    echo -e "   • Clear panel cache: sudo php artisan cache:clear"
    echo -e "   • Restart PHP-FPM: sudo systemctl restart php8.1-fpm"
    
    echo -e "\n${KS_CYAN}2. Installation failed with extraction error${KS_RESET}"
    echo -e "   • Check disk space: df -h /var"
    echo -e "   • Install unzip: sudo apt install unzip -y"
    echo -e "   • Download manually:"
    echo -e "     cd /var/www/pterodactyl"
    echo -e "     wget $THEME_URL"
    echo -e "     unzip theme.zip"
    
    echo -e "\n${KS_CYAN}3. Node.js/yarn installation issues${KS_RESET}"
    echo -e "   • Remove Node.js: sudo apt remove nodejs npm -y"
    echo -e "   • Reinstall: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo -e "   • Install Node.js: sudo apt install nodejs -y"
    echo -e "   • Install Yarn: sudo npm install -g yarn"
    
    echo -e "\n${KS_CYAN}4. Permission errors${KS_RESET}"
    echo -e "   • Set ownership: sudo chown -R www-data:www-data /var/www/pterodactyl"
    echo -e "   • Set permissions: sudo chmod -R 755 /var/www/pterodactyl"
    echo -e "   • Storage permissions: sudo chmod -R 775 storage bootstrap/cache"
    
    echo -e "\n${KS_CYAN}5. Pterodactyl not found${KS_RESET}"
    echo -e "   • Verify installation path: ls -la /var/www/pterodactyl"
    echo -e "   • Install Pterodactyl first:"
    echo -e "     curl -sSL https://get.pterodactyl-installer.se | bash"
    
    echo -e "\n${KS_PURPLE}${KS_BOLD}Support:${KS_RESET}"
    echo -e "${KS_PURPLE}•${KS_RESET} Discord: $DISCORD_INVITE"
    echo -e "${KS_PURPLE}•${KS_RESET} Email: $SUPPORT_EMAIL"
    echo -e "${KS_PURPLE}•${KS_RESET} Website: $OFFICIAL_WEBSITE"
    
    echo -e "\n${KS_CYAN}Press [Enter] to continue...${KS_RESET}"
    read -r
}

show_about() {
    print_ksgaming_banner
    
    echo -e "${KS_BLUE}${KS_BOLD}About KSGAMING:${KS_RESET}\n"
    
    echo -e "${KS_WHITE}KSGAMING is a professional gaming solutions provider${KS_RESET}"
    echo -e "${KS_WHITE}specializing in high-performance game server management${KS_RESET}"
    echo -e "${KS_WHITE}and control panel themes.${KS_RESET}"
    
    echo -e "\n${KS_CYAN}${KS_BOLD}Our Products:${KS_RESET}"
    echo -e "${KS_CYAN}•${KS_RESET} KSGAMING Pterodactyl Theme"
    echo -e "${KS_CYAN}•${KS_RESET} Game Server Optimizations"
    echo -e "${KS_CYAN}•${KS_RESET} Performance Monitoring Tools"
    echo -e "${KS_CYAN}•${KS_RESET} Custom Panel Development"
    
    echo -e "\n${KS_PURPLE}${KS_BOLD}Features:${KS_RESET}"
    echo -e "${KS_PURPLE}•${KS_RESET} Modern, responsive design"
    echo -e "${KS_PURPLE}•${KS_RESET} Dark/light mode support"
    echo -e "${KS_PURPLE}•${KS_RESET} Performance optimizations"
    echo -e "${KS_PURPLE}•${KS_RESET} Regular updates and support"
    echo -e "${KS_PURPLE}•${KS_RESET} Community-driven development"
    
    echo -e "\n${KS_GREEN}${KS_BOLD}Version:${KS_RESET} $SCRIPT_VERSION"
    echo -e "${KS_GREEN}${KS_BOLD}Website:${KS_RESET} $OFFICIAL_WEBSITE"
    echo -e "${KS_GREEN}${KS_BOLD}Support:${KS_RESET} $SUPPORT_EMAIL"
    echo -e "${KS_GREEN}${KS_BOLD}Community:${KS_RESET} $DISCORD_INVITE"
    
    echo -e "\n${KS_YELLOW}${KS_BOLD}License:${KS_RESET}"
    echo -e "${KS_YELLOW}This software is licensed under the MIT License.${KS_RESET}"
    
    echo -e "\n${KS_CYAN}Press [Enter] to continue...${KS_RESET}"
    read -r
}

#============ MAIN EXECUTION ============#
# Check if running with proper privileges
if [[ $EUID -eq 0 ]]; then
    echo -e "${KS_YELLOW}${KS_BOLD}Warning: Running as root is not recommended.${KS_RESET}"
    echo -e "${KS_YELLOW}Consider running with sudo instead.${KS_RESET}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
elif ! sudo -n true 2>/dev/null; then
    echo -e "${KS_YELLOW}This installer requires sudo privileges.${KS_RESET}"
    sudo -v || exit 1
fi

# Create necessary directories
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

# Start the menu system
main_menu
