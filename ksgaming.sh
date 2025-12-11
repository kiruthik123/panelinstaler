#!/usr/bin/env bash
#
# Skyport Panel/Wings Comprehensive Installation Script
# Professional deployment tool for Skyport game server management platform
#
# System Requirements: Debian/Ubuntu-based Linux distribution
# Version: 2.0.0
#

set -euo pipefail

# --- Configuration ---
readonly PANEL_DIR="/etc/skyport"
readonly WINGS_DIR="/etc/skyportd"
readonly PANEL_REPO="https://github.com/skyport-team/panel"
readonly WINGS_REPO="https://github.com/skyport-team/skyportd"
readonly NODE_VERSION="22.x"
readonly SCRIPT_NAME="skyport-installer"
readonly LOG_FILE="/var/log/skyport-install.log"

# --- Color and Formatting Constants ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color
readonly DIVIDER="================================================================"

# --- Logging Functions ---
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "\n${CYAN}▶ ${BOLD}$1${NC}" | tee -a "$LOG_FILE"
}

# --- Validation Functions ---
validate_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script requires elevated privileges. Please execute with 'sudo'."
        exit 1
    fi
}

validate_system() {
    if ! [[ -f /etc/debian_version || -f /etc/lsb-release ]]; then
        log_error "Unsupported operating system. This script requires Debian/Ubuntu."
        exit 1
    fi
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# --- Installation Functions ---
install_docker() {
    log_step "Installing Docker Engine"
    
    if check_command docker; then
        log_info "Docker is already installed"
        return
    fi

    log_info "Adding Docker repository and installing..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh > /dev/null 2>&1
    
    if systemctl enable --now docker > /dev/null 2>&1; then
        log_success "Docker Engine installed and service enabled"
    else
        log_error "Docker installation failed"
        exit 1
    fi
}

install_nodejs() {
    log_step "Installing Node.js Runtime"
    
    if check_command node && node --version | grep -q "v22"; then
        log_info "Node.js v22 is already installed"
        return
    fi

    log_info "Configuring NodeSource repository..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
        gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION nodistro main" | \
        tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    
    apt-get update > /dev/null 2>&1
    
    if apt-get install -y nodejs git > /dev/null 2>&1; then
        log_success "Node.js $NODE_VERSION and Git installed successfully"
    else
        log_error "Node.js installation failed"
        exit 1
    fi
}

install_prerequisites() {
    log_step "Installing System Prerequisites"
    
    apt-get update > /dev/null 2>&1
    apt-get install -y curl gnupg ca-certificates > /dev/null 2>&1
    
    install_docker
    install_nodejs
    
    log_success "All prerequisites installed"
}

# --- Panel Installation ---
install_panel() {
    log_step "Initiating Skyport Panel Installation"
    
    if [[ -d "$PANEL_DIR" ]]; then
        log_warning "Panel directory '$PANEL_DIR' already exists. Installation aborted."
        return 1
    fi

    install_prerequisites

    log_step "Cloning Skyport Panel Repository"
    if git clone "$PANEL_REPO" "$PANEL_DIR" > /dev/null 2>&1; then
        log_success "Repository cloned successfully"
    else
        log_error "Failed to clone repository"
        return 1
    fi

    cd "$PANEL_DIR"

    log_step "Installing Node.js Dependencies"
    if npm install --silent; then
        log_success "Dependencies installed"
    else
        log_error "npm installation failed"
        return 1
    fi

    log_step "Configuring Panel"
    cp example_config.json config.json
    
    log_step "Initializing Database"
    if npm run seed --silent; then
        log_success "Database seeded"
    else
        log_warning "Database seeding encountered issues"
    fi

    log_step "Creating Administrator Account"
    npm run createUser

    log_step "Configuring System Service"
    cat > /etc/systemd/system/skyport-panel.service << EOF
[Unit]
Description=Skyport Panel Service
Documentation=https://github.com/skyport-team/panel
After=network.target docker.service
Requires=docker.service

[Service]
Type=exec
User=root
WorkingDirectory=$PANEL_DIR
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal
SyslogIdentifier=skyport-panel
LimitNOFILE=65536
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable skyport-panel.service > /dev/null 2>&1
    
    log_success "Panel installation completed successfully"
    
    cat << EOF

${GREEN}${DIVIDER}
                    PANEL INSTALLATION COMPLETE
${DIVIDER}${NC}

${BOLD}Configuration:${NC}
  • Configuration File: ${PANEL_DIR}/config.json
  • Service Name: skyport-panel.service
  • Installation Path: ${PANEL_DIR}

${BOLD}Next Steps:${NC}
  1. Edit configuration: ${CYAN}nano ${PANEL_DIR}/config.json${NC}
  2. Start the service: ${CYAN}systemctl start skyport-panel${NC}
  3. Monitor logs: ${CYAN}journalctl -u skyport-panel -f${NC}

${YELLOW}⚠ Action Required: Update database configuration in config.json${NC}
${DIVIDER}
EOF
}

# --- Wings Installation ---
install_wings() {
    log_step "Initiating Skyport Wings Installation"
    
    if [[ -d "$WINGS_DIR" ]]; then
        log_warning "Wings directory '$WINGS_DIR' already exists. Installation aborted."
        return 1
    fi

    install_prerequisites

    log_step "Cloning Skyport Wings Repository"
    if git clone "$WINGS_REPO" "$WINGS_DIR" > /dev/null 2>&1; then
        log_success "Repository cloned successfully"
    else
        log_error "Failed to clone repository"
        return 1
    fi

    cd "$WINGS_DIR"

    log_step "Installing Node.js Dependencies"
    if npm install --silent; then
        log_success "Dependencies installed"
    else
        log_error "npm installation failed"
        return 1
    fi

    log_step "Configuring Wings"
    cp example_config.json config.json

    log_step "Configuring System Service"
    cat > /etc/systemd/system/skyport-wings.service << EOF
[Unit]
Description=Skyport Wings Daemon
Documentation=https://github.com/skyport-team/skyportd
After=network.target docker.service
Requires=docker.service
PartOf=docker.service

[Service]
Type=exec
User=root
WorkingDirectory=$WINGS_DIR
ExecStart=/usr/bin/node $WINGS_DIR/index.js
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=skyport-wings
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable skyport-wings.service > /dev/null 2>&1
    
    log_success "Wings installation completed successfully"
    
    cat << EOF

${GREEN}${DIVIDER}
                    WINGS INSTALLATION COMPLETE
${DIVIDER}${NC}

${BOLD}Configuration:${NC}
  • Configuration File: ${WINGS_DIR}/config.json
  • Service Name: skyport-wings.service
  • Installation Path: ${WINGS_DIR}

${BOLD}Next Steps:${NC}
  1. Edit configuration: ${CYAN}nano ${WINGS_DIR}/config.json${NC}
  2. Configure panel connection in config.json
  3. Start the service: ${CYAN}systemctl start skyport-wings${NC}
  4. Monitor logs: ${CYAN}journalctl -u skyport-wings -f${NC}

${YELLOW}⚠ Action Required: Configure panel connection in config.json${NC}
${DIVIDER}
EOF
}

# --- Main Execution ---
main() {
    clear
    
    echo -e "${MAGENTA}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                Skyport Deployment Manager                 ║"
    echo "║                 Professional Installer v2.0               ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    validate_root
    validate_system
    
    # Create log file
    > "$LOG_FILE"
    log_info "Installation started at $(date)"
    log_info "System: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2)"
    
    while true; do
        echo -e "\n${CYAN}${BOLD}Deployment Selection${NC}"
        echo -e "${BLUE}${DIVIDER}${NC}"
        echo -e "${BOLD}Select component to install:${NC}"
        echo -e "  ${GREEN}1)${NC} 🖥️  Skyport Panel (Control Panel)"
        echo -e "     ${CYAN}• Web Interface & API${NC}"
        echo -e "     ${CYAN}• Database Required${NC}"
        echo ""
        echo -e "  ${GREEN}2)${NC} 🚀 Skyport Wings (Game Node)"
        echo -e "     ${CYAN}• Docker-based Game Servers${NC}"
        echo -e "     ${CYAN}• High Performance Required${NC}"
        echo ""
        echo -e "  ${GREEN}3)${NC} 📋 Display System Information"
        echo -e "  ${GREEN}4)${NC} 🚪 Exit Installer"
        echo -e "${BLUE}${DIVIDER}${NC}"
        
        read -rp "$(echo -e ${BOLD}'Enter selection [1-4]: '${NC})" choice
        
        case $choice in
            1)
                install_panel
                ;;
            2)
                install_wings
                ;;
            3)
                log_step "System Information"
                echo -e "${BOLD}OS:${NC} $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2)"
                echo -e "${BOLD}Kernel:${NC} $(uname -r)"
                echo -e "${BOLD}Architecture:${NC} $(uname -m)"
                echo -e "${BOLD}Memory:${NC} $(free -h | awk '/^Mem:/ {print $2}')"
                echo -e "${BOLD}Storage:${NC} $(df -h / | awk 'NR==2 {print $4}') available"
                ;;
            4)
                log_info "Installation completed. Log saved to: $LOG_FILE"
                echo -e "${GREEN}Thank you for using Skyport Installer${NC}"
                exit 0
                ;;
            *)
                log_error "Invalid selection. Please choose 1, 2, 3, or 4."
                ;;
        esac
        
        if [[ $choice == 1 || $choice == 2 ]]; then
            read -rp "$(echo -e ${BOLD}'Press Enter to continue...'${NC})" -n1
        fi
    done
}

# Error handling
trap 'log_error "Installation interrupted at line $LINENO"; exit 1' INT TERM

main "$@"
