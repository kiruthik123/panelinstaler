#!/usr/bin/env bash
# =========================================================
# KS HOSTING BY KSGAMING - PROFESSIONAL INSTALLER
# Clean, box-style UI with essential functionality
# =========================================================

set -euo pipefail
IFS=$'\n\t'

# ---------------- Config ----------------
GH_USER="kiruthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/installer/main/install.sh"

PANEL_DIR="/var/www/pterodactyl"
WIDTH=70

# ---------------- Colors ----------------
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GREY='\033[1;90m'
ORANGE='\033[1;33m'

# ---------------- Utilities (UI) ----------------
draw_line() {
    printf "${BLUE}+%*s+${NC}\n" "$((WIDTH-2))" '' | tr ' ' '-'
}

draw_header() {
    printf "${BLUE}+%*s+${NC}\n" "$((WIDTH-2))" '' | tr ' ' '='
}

print_center() {
    local text="$1"
    local color="${2:-$WHITE}"
    local len=${#text}
    local pad=$(( (WIDTH - len - 2) / 2 ))
    printf "${BLUE}|${NC}%*s${color}%s${NC}%*s${BLUE}|${NC}\n" $pad "" "$text" $((WIDTH - len - pad - 2)) ""
}

print_left() {
    local text="$1"
    local color="${2:-$WHITE}"
    printf "${BLUE}|${NC} ${color}%-${WIDTH-4}s${NC} ${BLUE}|${NC}\n" "$text"
}

print_option() {
    local idx="$1"
    local text="$2"
    local color="${3:-$WHITE}"
    printf "${BLUE}|${NC} [${CYAN}${idx}${NC}] ${color}%-${WIDTH-10}s${NC} ${BLUE}|${NC}\n" "$text"
}

print_info() {
    local text="$1"
    local color="${2:-$CYAN}"
    printf "${BLUE}|${NC} ${color}▶${NC} ${WHITE}%-${WIDTH-8}s${NC} ${BLUE}|${NC}\n" "$text"
}

print_success() {
    printf "${GREEN}✓${NC} $1\n"
}

print_error() {
    printf "${RED}✗${NC} $1\n"
}

print_warning() {
    printf "${YELLOW}⚠${NC} $1\n"
}

# ---------------- Progress Bar ----------------
run_with_progress() {
    local msg="$1"
    local cmd="$2"
    
    printf "\n${CYAN}▶${NC} ${WHITE}%s...${NC}\n" "$msg"
    
    # Simple progress indicator
    local i=0
    while kill -0 $! 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        case $i in
            0) printf "\r${CYAN}[    ]${NC}" ;;
            1) printf "\r${CYAN}[■   ]${NC}" ;;
            2) printf "\r${CYAN}[■■  ]${NC}" ;;
            3) printf "\r${CYAN}[■■■ ]${NC}" ;;
        esac
        sleep 0.5
    done
    
    # Run the actual command
    set +e
    eval "$cmd" > /tmp/installer.log 2>&1
    local EXIT=$?
    set -e
    
    printf "\r"
    if [ $EXIT -eq 0 ]; then
        printf "${GREEN}✓${NC} ${WHITE}%s completed${NC}\n" "$msg"
    else
        printf "${RED}✗${NC} ${WHITE}%s failed${NC}\n" "$msg"
        [ -f /tmp/installer.log ] && tail -10 /tmp/installer.log
    fi
    
    return $EXIT
}

# ---------------- Header ----------------
print_header() {
    clear
    draw_header
    print_center "╔═╗╔═╗   ╦ ╦╔═╗╔═╗╦ ╦╔═╗╦  ╔═╗" "$PURPLE"
    print_center "║ ╦╠═╝   ║║║╠═╣╠═╝║ ║║ ║║  ╚═╗" "$BLUE"
    print_center "╚═╝╩     ╚╩╝╩ ╩╩  ╚═╝╚═╝╩═╝╚═╝" "$CYAN"
    print_center "╔═╗╔═╗╔═╗╦═╗╔═╗╔═╗╔╦╗╔═╗╦ ╦" "$PURPLE"
    print_center "╠═╣╠═╝║ ║╠╦╝║╣ ║╣  ║ ║ ║╚╦╝" "$BLUE"
    print_center "╩ ╩╩  ╚═╝╩╚═╚═╝╚═╝ ╩ ╚═╝ ╩ " "$CYAN"
    print_center "KS HOSTING BY KSGAMING" "$YELLOW"
    draw_line
    print_center "Repository: $GH_USER/$GH_REPO" "$GREEN"
    print_center "Branch: $GH_BRANCH" "$GREEN"
    draw_line
    local user_ip="$(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    print_center "User: $USER | IP: $user_ip" "$GREY"
    print_center "$(date '+%Y-%m-%d %H:%M:%S')" "$GREY"
    draw_line
}

# ---------------- Blueprint / Addon helpers ----------------
install_bp() {
    local name="$1"
    local file="$2"
    local url="$BASE_URL/$file"
    
    print_header
    print_center "INSTALLING: $name" "$YELLOW"
    draw_line
    
    if ! command -v blueprint &>/dev/null; then
        print_error "Blueprint framework is not installed. Run Blueprint Install first."
        read -p "Press Enter to continue..."
        return
    fi
    
    mkdir -p "$PANEL_DIR"
    cd "$PANEL_DIR" || return
    
    run_with_progress "Downloading $file" "wget -q --show-progress '$url' -O '$file'"
    
    if [ ! -f "$file" ]; then
        print_error "Download failed."
        read -p "Press Enter to continue..."
        return
    fi
    
    run_with_progress "Installing $name" "blueprint -install '$file'"
    rm -f "$file"
    
    print_success "Addon installed successfully!"
    read -p "Press Enter to continue..."
}

uninstall_addon() {
    while true; do
        print_header
        print_center "UNINSTALL ADDON" "$RED"
        draw_line
        print_option "1" "Recolor Theme"
        print_option "2" "Sidebar Theme"
        print_option "3" "Server Backgrounds"
        print_option "4" "Euphoria Theme"
        print_option "5" "MC Tools"
        print_option "6" "MC Logs"
        print_option "7" "Player Listing"
        print_option "8" "Votifier Tester"
        print_option "9" "Database Editor"
        print_option "10" "Subdomain Manager"
        draw_line
        print_option "M" "Manual ID"
        print_option "0" "Back"
        draw_header
        
        read -p "Select: " rm_opt
        case $rm_opt in
            1) id="recolor" ;;
            2) id="sidebar" ;;
            3) id="serverbackgrounds" ;;
            4) id="euphoria" ;;
            5) id="mctools" ;;
            6) id="mclogs" ;;
            7) id="playerlisting" ;;
            8) id="votifiertester" ;;
            9) id="dbedit" ;;
            10) id="subdomains" ;;
            M|m) read -p "Enter Addon ID: " id ;;
            0) return ;;
            *) print_error "Invalid option"; continue ;;
        esac
        
        cd "$PANEL_DIR" || return
        run_with_progress "Removing $id" "blueprint -remove '$id'"
        print_success "Addon removed successfully!"
        read -p "Press Enter to continue..."
        return
    done
}

uninstall_framework() {
    print_header
    print_center "UNINSTALL BLUEPRINT FRAMEWORK" "$RED"
    draw_line
    print_warning "This will remove all blueprint extensions"
    draw_line
    
    read -p "Type 'YES' to confirm: " c
    if [[ "$c" == "YES" ]]; then
        run_with_progress "Removing blueprint" "rm -rf /usr/local/bin/blueprint '$PANEL_DIR/blueprint'"
        print_success "Blueprint framework uninstalled!"
    else
        print_info "Operation cancelled."
    fi
    read -p "Press Enter to continue..."
}

# ---------------- Blueprint menu ----------------
menu_blueprint() {
    while true; do
        print_header
        print_center "BLUEPRINT SYSTEM" "$CYAN"
        draw_line
        print_option "1" "Install Framework (Custom)"
        print_option "2" "Open KS Addon Store"
        print_option "3" "Update All Extensions"
        print_option "4" "Toggle Dev Mode"
        print_option "5" "Uninstall Addon"
        print_option "6" "Uninstall Framework"
        print_option "0" "Back"
        draw_header
        
        read -p "Select: " opt
        case $opt in
            1)
                mkdir -p "$PANEL_DIR"
                cd "$PANEL_DIR" || continue
                run_with_progress "Downloading blueprint-installer.sh" \
                    "wget -q '$BASE_URL/blueprint-installer.sh' -O blueprint-installer.sh"
                
                if [ -f blueprint-installer.sh ]; then
                    run_with_progress "Running blueprint-installer.sh" \
                        "bash blueprint-installer.sh"
                    rm -f blueprint-installer.sh
                    print_success "Blueprint framework installed!"
                else
                    print_error "Installer not found."
                fi
                read -p "Press Enter to continue..." ;;
            2) menu_addons_blueprint ;;
            3)
                cd "$PANEL_DIR" || continue
                run_with_progress "Upgrading blueprint extensions" "blueprint -upgrade"
                read -p "Press Enter to continue..." ;;
            4)
                if [ -f "$PANEL_DIR/.env" ]; then
                    run_with_progress "Setting dev mode" \
                        "sed -i 's/APP_ENV=production/APP_ENV=local/g' '$PANEL_DIR/.env'"
                else
                    print_error ".env file not found."
                fi
                read -p "Press Enter to continue..." ;;
            5) uninstall_addon ;;
            6) uninstall_framework ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Addons & Blueprints menu ----------------
menu_addons_blueprint() {
    while true; do
        print_header
        print_center "ADDONS & BLUEPRINT MANAGER" "$PURPLE"
        draw_line
        print_left "-- BLUEPRINT --" "$CYAN"
        print_option "1" "Blueprint Install (Framework)" "$GREEN"
        
        print_left "-- THEMES --" "$ORANGE"
        print_option "2" "Recolor Theme"
        print_option "3" "Sidebar Theme"
        print_option "4" "Server Backgrounds"
        print_option "5" "Euphoria Theme"
        
        print_left "-- UTILITIES --" "$ORANGE"
        print_option "6" "MC Tools (Editor)"
        print_option "7" "MC Logs (Live Console)"
        print_option "8" "Player Listing"
        print_option "9" "Votifier Tester"
        print_option "10" "Database Editor"
        print_option "11" "Subdomains Manager"
        
        draw_line
        print_option "12" "Uninstall Addon" "$RED"
        print_option "13" "Uninstall Blueprint Framework" "$RED"
        print_option "0" "Back" "$GREY"
        draw_header
        
        read -p "Select Addon [0-13]: " opt
        case $opt in
            1) menu_blueprint ;;
            2) install_bp "Recolor Theme" "recolor.blueprint" ;;
            3) install_bp "Sidebar Theme" "sidebar.blueprint" ;;
            4) install_bp "Server Backgrounds" "serverbackgrounds.blueprint" ;;
            5) install_bp "Euphoria Theme" "euphoriatheme.blueprint" ;;
            6) install_bp "MC Tools" "mctools.blueprint" ;;
            7) install_bp "MC Logs" "mclogs.blueprint" ;;
            8) install_bp "Player List" "playerlisting.blueprint" ;;
            9) install_bp "Votifier Tester" "votifiertester.blueprint" ;;
            10) install_bp "DB Editor" "dbedit.blueprint" ;;
            11) install_bp "Subdomain Manager" "subdomains.blueprint" ;;
            12) uninstall_addon ;;
            13) uninstall_framework ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Panel installers ----------------
menu_pufferpanel() {
    print_header
    run_with_progress "Downloading & running PufferPanel installer" \
        "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/pufferpanel/main/Install.sh)"
    read -p "Press Enter to continue..."
}

menu_mythicaldash() {
    print_header
    run_with_progress "Downloading & running MythicalDash installer" \
        "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/mythicaldash/main/install.sh)"
    read -p "Press Enter to continue..."
}

menu_skyport_panel() {
    print_header
    run_with_progress "Downloading & running Skyport installer" \
        "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/skyport/main/install.sh)"
    read -p "Press Enter to continue..."
}

menu_airlink_panel() {
    print_header
    run_with_progress "Downloading & running AirLink installer" \
        "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/airlink/main/install.sh)"
    read -p "Press Enter to continue..."
}

menu_pterodactyl_install() {
    while true; do
        print_header
        print_center "PTERODACTYL INSTALLER" "$ORANGE"
        draw_line
        print_option "1" "Install Pterodactyl Panel"
        print_option "2" "Install Pterodactyl Wings (Node)"
        print_option "3" "Pterodactyl Blueprint & Addons" "$CYAN"
        print_option "4" "Uninstall Pterodactyl" "$RED"
        print_option "0" "Back" "$GREY"
        draw_header
        
        read -p "Select: " opt
        case $opt in
            1)
                run_with_progress "Running Pterodactyl hybrid installer" \
                    "bash <(curl -s '$INSTALLER_URL')"
                read -p "Press Enter to continue..." ;;
            2)
                run_with_progress "Running Pterodactyl wings installer" \
                    "bash <(curl -s '$INSTALLER_URL')"
                read -p "Press Enter to continue..." ;;
            3) menu_blueprint ;;
            4)
                read -p "Type 'DELETE' to remove Pterodactyl: " CONF
                if [ "$CONF" == "DELETE" ]; then
                    run_with_progress "Removing Pterodactyl data" \
                        "rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings"
                    print_success "Pterodactyl removed!"
                fi
                read -p "Press Enter to continue..." ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 0.5 ;;
        esac
    done
}

menu_panel_installation_hub() {
    while true; do
        print_header
        print_center "PANEL INSTALLATION HUB" "$YELLOW"
        draw_line
        print_option "1" "Pterodactyl Panel (Game/Hosting)" "$YELLOW"
        print_option "2" "PufferPanel (Game/Hosting)" "$YELLOW"
        print_option "3" "MythicalDash Panel (Web/Frontend)" "$YELLOW"
        print_option "4" "Skyport Panel (Web/Frontend)" "$YELLOW"
        print_option "5" "AirLink Panel (Game/Hosting)" "$GREEN"
        draw_line
        print_option "0" "Back" "$RED"
        draw_header
        
        read -p "Select Panel to Install: " hub_opt
        case $hub_opt in
            1) menu_pterodactyl_install ;;
            2) menu_pufferpanel ;;
            3) menu_mythicaldash ;;
            4) menu_skyport_panel ;;
            5) menu_airlink_panel ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Auto Port Opener ----------------
open_port() {
    local port="$1"
    local proto="$2"
    
    if command -v ufw &>/dev/null; then
        ufw allow "${port}/${proto}" >/dev/null 2>&1 || true
    elif command -v iptables &>/dev/null; then
        iptables -C INPUT -p "$proto" --dport "$port" -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -p "$proto" --dport "$port" -j ACCEPT
    fi
}

apply_ports() {
    local arr=("$@")
    for p in "${arr[@]}"; do
        IFS="/" read -r port proto <<< "$p"
        open_port "$port" "$proto"
    done
}

menu_auto_port_opener() {
    while true; do
        print_header
        print_center "AUTO PORT OPENER" "$YELLOW"
        draw_line
        print_left "Required Ports (always opened):" "$CYAN"
        print_info "22/tcp (SSH)"
        print_info "80/tcp (HTTP)"
        print_info "443/tcp (HTTPS)"
        print_info "8080/tcp (Web Panels)"
        draw_line
        print_left "Game Presets:" "$CYAN"
        print_option "1" "Minecraft Java (25565/tcp)"
        print_option "2" "Minecraft Bedrock (19132/udp)"
        print_option "3" "CS2 / CS:GO (27015/udp,27005/udp)"
        print_option "4" "Rust (28015/udp,28016/udp)"
        print_option "5" "FiveM (30120/tcp,30120/udp)"
        print_option "6" "Custom Ports (enter manually)"
        draw_line
        print_option "0" "Back"
        draw_header
        
        read -p "Select game preset: " g
        
        required_ports=("22/tcp" "80/tcp" "443/tcp" "8080/tcp")
        game_ports=()
        
        case $g in
            1) game_ports=("25565/tcp") ;;
            2) game_ports=("19132/udp") ;;
            3) game_ports=("27015/udp" "27005/udp") ;;
            4) game_ports=("28015/udp" "28016/udp") ;;
            5) game_ports=("30120/tcp" "30120/udp") ;;
            6)
                read -p "Enter custom ports (space-separated, e.g. 9000/tcp 9100/udp): " -r custom
                read -r -a game_ports <<< "$custom" ;;
            0) return ;;
            *) continue ;;
        esac
        
        read -p "Extra ports (space-separated, or Enter to skip): " -r extras
        read -r -a extra_ports <<< "$extras"
        
        final_list=("${required_ports[@]}" "${game_ports[@]}" "${extra_ports[@]}")
        
        run_with_progress "Opening ports" "apply_ports \"\${final_list[@]}\""
        
        echo -e "\n${GREEN}✓${NC} Ports processed successfully!"
        echo "${CYAN}▶${NC} Opened ports: ${final_list[*]}"
        read -p "Press Enter to continue..."
        return
    done
}

# ---------------- Cloudflare ----------------
menu_cloudflare() {
    while true; do
        print_header
        print_center "CLOUDFLARE TUNNEL MANAGER" "$ORANGE"
        draw_line
        print_option "1" "Install & Setup cloudflared"
        print_option "2" "Uninstall cloudflared"
        print_option "0" "Back"
        draw_header
        
        read -p "Select: " cf_opt
        case $cf_opt in
            1)
                run_with_progress "Installing cloudflared" "
                    mkdir -p --mode=0755 /usr/share/keyrings &&
                    curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | \
                    tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null &&
                    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] \
                    https://pkg.cloudflare.com/cloudflared any main' | \
                    tee /etc/apt/sources.list.d/cloudflared.list &&
                    apt-get update -y &&
                    apt-get install -y cloudflared
                "
                echo -e "${YELLOW}⚠${NC} Visit https://one.dash.cloudflare.com to create a tunnel"
                echo -e "${YELLOW}⚠${NC} Paste connector command below if available"
                read -p "Paste connector command (or Enter to skip): " cf_cmd
                if [[ -n "$cf_cmd" ]]; then
                    run_with_progress "Applying connector command" "$cf_cmd"
                fi
                read -p "Press Enter to continue..." ;;
            2)
                read -p "Type 'REMOVE' to uninstall cloudflared: " c
                if [ "$c" == "REMOVE" ]; then
                    run_with_progress "Removing cloudflared" "
                        systemctl stop cloudflared 2>/dev/null || true;
                        systemctl disable cloudflared 2>/dev/null || true;
                        apt-get remove -y cloudflared || true;
                        apt-get purge -y cloudflared || true;
                        rm -rf /etc/cloudflared;
                        rm -f /etc/apt/sources.list.d/cloudflared.list
                    "
                    print_success "Cloudflare Tunnel removed!"
                fi
                read -p "Press Enter to continue..." ;;
            0) return ;;
        esac
    done
}

# ---------------- Tailscale ----------------
menu_tailscale() {
    while true; do
        print_header
        print_center "TAILSCALE VPN MANAGER" "$ORANGE"
        draw_line
        print_option "1" "Install Tailscale"
        print_option "2" "Run tailscale up (auth)"
        print_option "3" "Status / IP"
        print_option "4" "Uninstall Tailscale"
        print_option "0" "Back"
        draw_header
        
        read -p "Select: " ts_opt
        case $ts_opt in
            1)
                if [ ! -c /dev/net/tun ]; then
                    print_error "TUN/TAP device missing. Ask host to enable."
                    read -p "Press Enter to continue..."
                    continue
                fi
                run_with_progress "Installing Tailscale" \
                    "curl -fsSL https://tailscale.com/install.sh | sh"
                print_success "Tailscale installed!"
                read -p "Press Enter to continue..." ;;
            2)
                if ! command -v tailscale &>/dev/null; then
                    print_error "Tailscale not installed."
                else
                    run_with_progress "Running tailscale up" "tailscale up --reset"
                fi
                read -p "Press Enter to continue..." ;;
            3)
                echo -e "${CYAN}▶${NC} Tailscale Status:"
                tailscale status || true
                echo -e "\n${CYAN}▶${NC} IP Address:"
                tailscale ip -4 || true
                read -p "Press Enter to continue..." ;;
            4)
                read -p "Type 'REMOVE' to uninstall tailscale: " c
                if [ "$c" == "REMOVE" ]; then
                    run_with_progress "Removing Tailscale" "
                        systemctl stop tailscaled 2>/dev/null || true;
                        apt-get remove -y tailscale || true;
                        rm -rf /var/lib/tailscale /etc/tailscale || true
                    "
                    print_success "Tailscale removed!"
                fi
                read -p "Press Enter to continue..." ;;
            0) return ;;
        esac
    done
}

# ---------------- Toolbox ----------------
menu_toolbox() {
    while true; do
        print_header
        print_center "SYSTEM TOOLBOX" "$PURPLE"
        draw_line
        print_option "1" "System Monitor"
        print_option "2" "Add 2GB Swap"
        print_option "3" "Network Speedtest"
        print_option "4" "Auto-Firewall (UFW)"
        print_option "5" "Database Backup (mysqldump)"
        print_option "6" "Install SSL (Certbot)"
        print_option "7" "Tailscale Manager" "$ORANGE"
        print_option "8" "Cloudflare Manager" "$ORANGE"
        print_option "9" "Enable Root Access"
        print_option "10" "SSHX (Web Terminal)"
        print_option "11" "Auto Port Opener (Game+Required)"
        print_option "0" "Back"
        draw_header
        
        read -p "Select: " opt
        case $opt in
            1)
                echo -e "${CYAN}▶${NC} Memory Usage:"
                free -h
                echo -e "\n${CYAN}▶${NC} Disk Usage:"
                df -h /
                echo -e "\n${CYAN}▶${NC} Uptime:"
                uptime -p
                read -p "Press Enter to continue..." ;;
            2)
                run_with_progress "Creating 2GB swapfile" "
                    fallocate -l 2G /swapfile &&
                    chmod 600 /swapfile &&
                    mkswap /swapfile &&
                    swapon /swapfile &&
                    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
                "
                print_success "Swap file created!"
                read -p "Press Enter to continue..." ;;
            3)
                run_with_progress "Running speedtest-cli" "
                    apt-get update -y &&
                    apt-get install -y speedtest-cli &&
                    speedtest-cli --simple
                "
                read -p "Press Enter to continue..." ;;
            4)
                run_with_progress "Setting up UFW and basic rules" "
                    apt-get update -y &&
                    apt-get install -y ufw &&
                    ufw allow 22 &&
                    ufw allow 80 &&
                    ufw allow 443 &&
                    ufw allow 8080 &&
                    yes | ufw enable
                "
                print_success "Firewall configured!"
                read -p "Press Enter to continue..." ;;
            5)
                read -p "Enter MySQL root password (input hidden): " -s SQLPASS
                echo
                run_with_progress "Running mysqldump for pterodactyl" "
                    mysqldump -u root -p\"$SQLPASS\" pterodactyl > /root/backup_$(date +%F).sql
                "
                print_success "Backup saved to /root/backup_$(date +%F).sql"
                read -p "Press Enter to continue..." ;;
            6)
                read -p "Enter domain for certbot (example.com): " DOM
                run_with_progress "Installing certbot & obtaining certificate" "
                    apt-get update -y &&
                    apt-get install -y certbot &&
                    certbot certonly --standalone -d \"$DOM\"
                "
                print_success "SSL certificate obtained!"
                read -p "Press Enter to continue..." ;;
            7) menu_tailscale ;;
            8) menu_cloudflare ;;
            9)
                run_with_progress "Enabling root access & setting password" "
                    passwd root;
                    sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config;
                    service ssh restart
                "
                print_success "Root access enabled!"
                read -p "Press Enter to continue..." ;;
            10)
                run_with_progress "Installing SSHX web terminal" \
                    "curl -sSf https://sshx.io/get | sh"
                sshx || true
                print_success "SSHX installed!"
                read -p "Press Enter to continue..." ;;
            11) menu_auto_port_opener ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Main menu ----------------
main_menu() {
    while true; do
        print_header
        print_center "MAIN MENU" "$GREEN"
        draw_line
        print_option "1" "Panel Installation Hub (All Panels)" "$YELLOW"
        print_option "2" "Addons & Blueprint Manager" "$CYAN"
        print_option "3" "System Toolbox (Server Tools)" "$PURPLE"
        draw_line
        print_option "0" "Exit Installer" "$GREY"
        draw_header
        
        echo -ne "${CYAN}▶${NC} Select option: "
        read -r choice
        
        case $choice in
            1) menu_panel_installation_hub ;;
            2) menu_addons_blueprint ;;
            3) menu_toolbox ;;
            0)
                clear
                echo -e "${CYAN}▶${NC} Thank you for using KS HOSTING Installer!\n"
                echo -e "${GREY}Made by KSGAMING${NC}"
                exit 0 ;;
            *) print_error "Invalid Option"; sleep 0.5 ;;
        esac
    done
}

# ---------------- Start ----------------
main_menu
