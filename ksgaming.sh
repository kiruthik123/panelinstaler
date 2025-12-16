#!/usr/bin/env bash
# =========================================================
# KS HOSTING BY KSGAMING - INSTALLER (PROFESSIONAL, FIXED)
# All requested features included and fixed:
#  - Boot screen (pulsing logo + neon border + loading sound)
#  - Menu transition loader + color pulse + sound
#  - Smooth progress bar & run_with_progress wrapper
#  - Panel Installation Hub (Pterodactyl, PufferPanel, MythicalDash, Skyport, AirLink)
#  - Addons & Blueprint manager (Blueprint first) using raw blueprint URL
#  - Auto Port Opener (required ports + game presets + extra)
#  - System Toolbox (Tailscale, Cloudflare, SSHX, UFW, Certbot, etc.)
#  - Stable flow: animations won't clear menu unexpectedly
# =========================================================

set -euo pipefail
IFS=$'\n\t'

# ---------------- Configuration ----------------
GH_USER="kiruthik123"
GH_REPO="panelinstaler"
GH_BRANCH="main"

BASE_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH"
INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/installer/main/install.sh"
BLUEPRINT_INSTALLER_URL="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main/blueprint-installer.sh"

PANEL_DIR="/var/www/pterodactyl"
WIDTH=65

# ---------------- Colors ----------------
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PINK='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
GREY='\033[1;90m'
ORANGE='\033[1;38;5;208m'

# ---------------- UI helpers ----------------
draw_bar()  { printf "${BLUE}%*s${NC}\n" "$WIDTH" '' | tr ' ' '='; }
draw_sub()  { printf "${GREY}%*s${NC}\n" "$WIDTH" '' | tr ' ' '-'; }

print_c() {
    local text="$1"; local color="${2:-$WHITE}"
    local len=${#text}; local pad=$(( (WIDTH - len) / 2 ))
    printf "${BLUE}|${NC}%*s${color}%s${NC}%*s${BLUE}|${NC}\n" $pad "" "$text" $((WIDTH - len - pad)) ""
}

print_opt() {
    local idx="$1"; local text="$2"; local color="${3:-$WHITE}"
    printf "${BLUE}|${NC}  ${CYAN}[${idx}]${NC} ${color}%-45s${NC} ${BLUE}|${NC}\n" "$text"
}

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[DONE]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------------- Progress helpers ----------------
smooth_progress() {
    local total=40; local i=0
    while :; do
        i=$(( (i % total) + 1 ))
        local filled=$(printf '█%.0s' $(seq 1 $i))
        local empty=$(printf '░%.0s' $(seq 1 $((total - i))))
        printf "\r${GREEN}[%s%s] %d%%%s" "$filled" "$empty" $((i*100/total)) "${NC}"
        sleep 0.06
    done
}

# run command while showing progress; returns exit code but does not exit script
run_with_progress() {
    local msg="$1"; local cmd="$2"
    printf "\n${CYAN}%s...${NC}\n" "$msg"
    smooth_progress &>/dev/null & SPID=$!
    set +e
    bash -c "$cmd"
    local EXIT=$?
    set -e
    # stop progress
    kill "$SPID" 2>/dev/null || true
    wait "$SPID" 2>/dev/null || true
    printf "\r"
    if [ $EXIT -eq 0 ]; then
        printf "${GREEN}%s completed successfully.${NC}\n" "$msg"
    else
        printf "${RED}%s failed (exit %d).${NC}\n" "$msg" "$EXIT"
    fi
    return $EXIT
}

# ---------------- Sound & Animations (safe) ----------------
loading_sound() {
    # simple beep chime; safe for most terminals
    printf "\a"; sleep 0.07; printf "\a"; sleep 0.07; printf "\a"
}

neon_glow_border() {
    local cols=("\033[1;95m" "\033[1;94m" "\033[1;96m" "\033[1;92m" "\033[1;93m")
    local border; border="$(printf '%0.s=' $(seq 1 $WIDTH))"
    for cycle in 1 2; do
        for c in "${cols[@]}"; do
            printf "\r${c}%s${NC}" "$border"
            sleep 0.05
        done
    done
    printf "\n"
}

# pulsing logo used only in boot_screen (clears screen) — header uses static logo
pulse_logo() {
    local cols=("\033[1;95m" "\033[1;94m" "\033[1;96m" "\033[1;92m" "\033[1;93m")
    local logo_lines=(
"██╗  ██╗███████╗    ██╗  ██╗███████╗███████╗"
"╚██╗██╔╝██╔════╝    ██║ ██╔╝██╔════╝██╔════╝"
" ╚███╔╝ ███████╗    █████╔╝ █████╗  ███████╗"
" ██╔██╗ ╚════██║    ██╔═██╗ ██╔══╝  ╚════██║"
"██╔╝ ██╗███████║    ██║  ██╗███████╗███████║"
"╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚══════╝"
    )
    for cycle in {1..3}; do
        for c in "${cols[@]}"; do
            clear
            for line in "${logo_lines[@]}"; do
                printf "  ${c}%s${NC}\n" "$line"
            done
            printf "\n            ${c}KS HOSTING BY KSGAMING${NC}\n"
            sleep 0.09
        done
    done
}

# short menu transition loader (does not clear)
menu_transition() {
    loading_sound
    neon_glow_border
    printf "\n${CYAN}Loading Menu:${NC} "
    for i in 1 30; do printf "${GREEN}█${NC}"; sleep 0.02; done
    printf "\n\n"
}

# ---------------- Boot screen (animated) ----------------
boot_screen() {
    clear
    neon_glow_border
    pulse_logo
    printf "\n${YELLOW}Starting KS HOSTING Installer...${NC}\n\n"
    for i in $(seq 1 40); do printf "${PINK}█${NC}"; sleep 0.03; done
    sleep 0.25
    clear
}

# ---------------- Header (static & fast) ----------------
print_logo_static() {
    print_c "██╗  ██╗███████╗    ██╗  ██╗███████╗███████╗" "$PINK"
    print_c "╚██╗██╔╝██╔════╝    ██║ ██╔╝██╔════╝██╔════╝" "$PINK"
    print_c " ╚███╔╝ ███████╗    █████╔╝ █████╗  ███████╗" "$PINK"
    print_c " ██╔██╗ ╚════██║    ██╔═██╗ ██╔══╝  ╚════██║" "$PINK"
    print_c "██╔╝ ██╗███████║    ██║  ██╗███████╗███████║" "$PINK"
    print_c "╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚══════╝" "$PINK"
    print_c "KS HOSTING BY KSGAMING" "$CYAN"
}

header() {
    clear
    # keep header snappy: small glow then static logo
    neon_glow_border
    print_logo_static
    draw_bar
    print_c "Repo: $GH_USER/$GH_REPO" "$CYAN"
    draw_bar
    print_c "User: $USER | IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')" "$GREY"
    draw_bar
}

# ---------------- Blueprint / Addon helpers ----------------
install_bp() {
    local name="$1"; local file="$2"
    local url="$BASE_URL/$file"
    header; print_c "INSTALLING: $name" "$YELLOW"; draw_sub
    if ! command -v blueprint &>/dev/null; then
        error "Blueprint framework not installed. Run Blueprint Install first."
        read -p "Press Enter..."
        return
    fi
    mkdir -p "$PANEL_DIR"; cd "$PANEL_DIR" || return
    run_with_progress "Downloading $file" "wget -q --show-progress \"$url\" -O \"$file\""
    if [ ! -f "$file" ]; then error "Download failed."; read -p "Press Enter..."; return; fi
    run_with_progress "Installing $name via blueprint" "blueprint -install \"$file\""
    rm -f "$file"
    read -p "Press Enter..."
}

uninstall_addon() {
    while true; do
        header; print_c "UNINSTALL ADDON" "$RED"; draw_sub
        print_opt 1 "Recolor Theme"; print_opt 2 "Sidebar Theme"; print_opt 3 "Server Backgrounds"
        print_opt 4 "Euphoria Theme"; print_opt 5 "MC Tools"; print_opt 6 "MC Logs"
        print_opt 7 "Player Listing"; print_opt 8 "Votifier Tester"; print_opt 9 "Database Editor"
        print_opt 10 "Subdomain Manager"
        draw_sub; print_opt M "Manual ID"; print_opt 0 "Back"; draw_bar
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
            M|m) read -p "Enter ID: " id ;;
            0) return ;;
            *) error "Invalid"; continue ;;
        esac
        cd "$PANEL_DIR" || return
        run_with_progress "Removing $id" "blueprint -remove \"$id\""
        read -p "Press Enter..."
        return
    done
}

uninstall_framework() {
    header; print_c "UNINSTALL BLUEPRINT FRAMEWORK" "$RED"; draw_sub
    read -p "Type 'yes' to confirm: " c
    if [[ "$c" == "yes" ]]; then
        run_with_progress "Removing blueprint" "rm -rf /usr/local/bin/blueprint \"$PANEL_DIR/blueprint\""
    else info "Cancelled."; fi
    read -p "Press Enter..."
}

# ---------------- Blueprint menu ----------------
menu_blueprint() {
    while true; do
        header; print_c "BLUEPRINT SYSTEM" "$CYAN"; draw_sub
        print_opt 1 "Install Framework (Custom)"; print_opt 2 "Open KS Addon Store"
        print_opt 3 "Update All Extensions"; print_opt 4 "Toggle Dev Mode"
        print_opt 5 "Uninstall Addon"; print_opt 6 "Uninstall Framework"; print_opt 0 "Back"
        draw_bar; read -p "Select: " opt
        case $opt in
            1)
                mkdir -p "$PANEL_DIR"; cd "$PANEL_DIR" || continue
                run_with_progress "Downloading blueprint-installer.sh" "wget -q \"$BLUEPRINT_INSTALLER_URL\" -O blueprint-installer.sh"
                if [ -f blueprint-installer.sh ]; then
                    run_with_progress "Running blueprint-installer.sh" "bash blueprint-installer.sh"
                    rm -f blueprint-installer.sh
                else error "Installer not found."; fi
                read -p "Press Enter..." ;;
            2) menu_addons_blueprint ;;
            3) cd "$PANEL_DIR" || continue; run_with_progress "Upgrading blueprint extensions" "blueprint -upgrade"; read -p "Press Enter..." ;;
            4) if [ -f "$PANEL_DIR/.env" ]; then run_with_progress "Setting dev mode" "sed -i 's/APP_ENV=production/APP_ENV=local/g' \"$PANEL_DIR/.env\""; else error ".env not found."; fi; read -p "Press Enter..." ;;
            5) uninstall_addon ;;
            6) uninstall_framework ;;
            0) return ;;
            *) error "Invalid"; sleep 0.4 ;;
        esac
    done
}

# ---------------- Addons & Blueprints menu ----------------
menu_addons_blueprint() {
    while true; do
        header; print_c "ADDONS & BLUEPRINTS" "$PINK"; draw_sub
        print_c "-- BLUEPRINT --" "$CYAN"; print_opt 1 "Blueprint Install (Framework Installer)" "$GREEN"
        print_c "-- THEMES --" "$ORANGE"; print_opt 2 "Recolor Theme"; print_opt 3 "Sidebar Theme"
        print_opt 4 "Server Backgrounds"; print_opt 5 "Euphoria Theme"
        print_c "-- UTILITIES --" "$ORANGE"; print_opt 6 "MC Tools (Editor)"; print_opt 7 "MC Logs (Live Console)"
        print_opt 8 "Player Listing"; print_opt 9 "Votifier Tester"; print_opt 10 "Database Editor"; print_opt 11 "Subdomains Manager"
        draw_sub; print_opt 12 "Uninstall Addon" "$RED"; print_opt 13 "Uninstall Blueprint Framework" "$RED"; print_opt 0 "Back" "$GREY"
        draw_bar; read -p "Select Addon [0-13]: " opt
        case $opt in
            1) menu_blueprint ;;
            2) menu_transition; install_bp "Recolor" "recolor.blueprint" ;;
            3) menu_transition; install_bp "Sidebar" "sidebar.blueprint" ;;
            4) menu_transition; install_bp "Backgrounds" "serverbackgrounds.blueprint" ;;
            5) menu_transition; install_bp "Euphoria Theme" "euphoriatheme.blueprint" ;;
            6) menu_transition; install_bp "MC Tools" "mctools.blueprint" ;;
            7) menu_transition; install_bp "MC Logs" "mclogs.blueprint" ;;
            8) menu_transition; install_bp "Player List" "playerlisting.blueprint" ;;
            9) menu_transition; install_bp "Votifier Tester" "votifiertester.blueprint" ;;
            10) menu_transition; install_bp "DB Editor" "dbedit.blueprint" ;;
            11) menu_transition; install_bp "Subdomain Manager" "subdomains.blueprint" ;;
            12) uninstall_addon ;;
            13) uninstall_framework ;;
            0) return ;;
            *) error "Invalid"; sleep 0.4 ;;
        esac
    done
}

# ---------------- Panel installers ----------------
menu_pufferpanel() {
    header
    run_with_progress "Running PufferPanel installer" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/pufferpanel/main/Install.sh)" || true
    read -p "Press Enter..."
}
menu_mythicaldash() {
    header
    run_with_progress "Running MythicalDash installer" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/mythicaldash/main/install.sh)" || true
    read -p "Press Enter..."
}
menu_skyport_panel() {
    header
    run_with_progress "Running Skyport installer" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/skyport/main/install.sh)" || true
    read -p "Press Enter..."
}
menu_airlink_panel() {
    header
    run_with_progress "Running AirLink installer" "bash <(curl -s https://raw.githubusercontent.com/kiruthik123/airlink/main/install.sh)" || true
    read -p "Press Enter..."
}

menu_pterodactyl_install() {
    while true; do
        header; print_c "PTERODACTYL INSTALLER" "$ORANGE"; draw_sub
        print_opt 1 "Install Pterodactyl Panel"; print_opt 2 "Install Pterodactyl Wings (Node)"
        print_opt 3 "Pterodactyl Blueprint & Addons Manager" "$CYAN"; print_opt 4 "Uninstall Pterodactyl" "$RED"; print_opt 0 "Back" "$GREY"
        draw_bar; read -p "Select: " opt
        case $opt in
            1) menu_transition; run_with_progress "Running Pterodactyl hybrid installer" "bash <(curl -s \"$INSTALLER_URL\")"; read -p "Press Enter..." ;;
            2) menu_transition; run_with_progress "Running Wings installer (via hybrid script)" "bash <(curl -s \"$INSTALLER_URL\")"; read -p "Press Enter..." ;;
            3) menu_blueprint ;;
            4) read -p "Type 'yes' to delete Pterodactyl files: " CONF; if [ "$CONF" == "yes" ]; then run_with_progress "Removing Pterodactyl data" "rm -rf /var/www/pterodactyl /etc/pterodactyl /usr/local/bin/wings"; fi; read -p "Press Enter..." ;;
            0) return ;;
            *) error "Invalid"; sleep 0.4 ;;
        esac
    done
}

menu_panel_installation_hub() {
    while true; do
        header; print_c "PANEL INSTALLATION HUB" "$YELLOW"; draw_sub
        print_opt 1 "Pterodactyl Panel (Game/Hosting)" "$YELLOW"
        print_opt 2 "PufferPanel (Game/Hosting)" "$YELLOW"
        print_opt 3 "MythicalDash Panel (Web/Frontend)" "$YELLOW"
        print_opt 4 "Skyport Panel (Web/Frontend)" "$YELLOW"
        print_opt 5 "AirLink Panel (Game/Hosting)" "$GREEN"
        draw_sub; print_opt 0 "Back" "$RED"; draw_bar
        read -p "Select Panel to Install: " hub_opt
        case $hub_opt in
            1) menu_transition; menu_pterodactyl_install ;;
            2) menu_transition; menu_pufferpanel ;;
            3) menu_transition; menu_mythicaldash ;;
            4) menu_transition; menu_skyport_panel ;;
            5) menu_transition; menu_airlink_panel ;;
            0) return ;;
            *) error "Invalid"; sleep 0.4 ;;
        esac
    done
}

# ---------------- Auto Port Opener ----------------
open_port() {
    local port="$1"; local proto="$2"
    if command -v ufw &>/dev/null; then
        ufw allow "${port}/${proto}" >/dev/null 2>&1 || true
    else
        if command -v iptables &>/dev/null; then
            iptables -C INPUT -p "$proto" --dport "$port" -j ACCEPT 2>/dev/null || iptables -A INPUT -p "$proto" --dport "$port" -j ACCEPT
        fi
    fi
}
apply_ports() {
    local arr=("$@")
    for p in "${arr[@]}"; do IFS="/" read -r port proto <<< "$p"; open_port "$port" "$proto"; done
}
menu_auto_port_opener() {
    while true; do
        header; print_c "AUTO PORT OPENER" "$YELLOW"; draw_sub
        print_c "Required Ports (always opened): 22/tcp 20/tcp 443/tcp 8080/tcp" "$CYAN"
        print_c "Game Presets:" "$CYAN"
        print_opt 1 "Minecraft Java (25565/tcp)"; print_opt 2 "Minecraft Bedrock (19132/udp)"
        print_opt 3 "CS2 / CS:GO (27015/udp,27005/udp)"; print_opt 4 "Rust (28015/udp,28016/udp)"
        print_opt 5 "FiveM (30120/tcp,30120/udp)"; print_opt 6 "Custom (enter ports)"
        draw_sub; print_opt 0 "Back"; draw_bar
        read -p "Select game preset: " g
        required_ports=("22/tcp" "20/tcp" "443/tcp" "8080/tcp")
        game_ports=()
        case $g in
            1) game_ports=("25565/tcp") ;;
            2) game_ports=("19132/udp") ;;
            3) game_ports=("27015/udp" "27005/udp") ;;
            4) game_ports=("28015/udp" "28016/udp") ;;
            5) game_ports=("30120/tcp" "30120/udp") ;;
            6) read -p "Enter custom ports (space-separated, e.g. 9000/tcp 9100/udp): " -r custom; read -r -a game_ports <<< "$custom" ;;
            0) return ;;
            *) continue ;;
        esac
        read -p "Extra ports (space-separated, or Enter to skip): " -r extras
        read -r -a extra_ports <<< "$extras"
        final_list=("${required_ports[@]}" "${game_ports[@]}" "${extra_ports[@]}")
        # call apply_ports in a subshell for safety
        run_with_progress "Opening ports" "apply_ports \"\${final_list[@]}\""
        echo -e "\n${GREEN}Ports processed.${NC}"; read -p "Press Enter..."; return
    done
}

# ---------------- Cloudflare & Tailscale ----------------
menu_cloudflare() {
    while true; do
        header; print_c "CLOUDFLARE TUNNEL MANAGER" "$ORANGE"; draw_sub
        print_opt 1 "Install & Setup cloudflared"; print_opt 2 "Uninstall cloudflared"; print_opt 0 "Back"; draw_bar
        read -p "Select: " cf_opt
        case $cf_opt in
            1)
                run_with_progress "Installing cloudflared" "mkdir -p --mode=0755 /usr/share/keyrings && curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list && apt-get update -y && apt-get install -y cloudflared"
                echo -e "${YELLOW}Create a tunnel at https://one.dash.cloudflare.com and paste connector command here.${NC}"
                read -p "Paste connector command (or Enter to skip): " cf_cmd
                if [[ -n "$cf_cmd" ]]; then run_with_progress "Applying connector command" "$cf_cmd"; fi
                read -p "Press Enter..." ;;
            2)
                read -p "Type 'yes' to uninstall cloudflared: " c
                if [ "$c" == "yes" ]; then run_with_progress "Removing cloudflared" "systemctl stop cloudflared 2>/dev/null || true; systemctl disable cloudflared 2>/dev/null || true; apt-get remove -y cloudflared || true; apt-get purge -y cloudflared || true; rm -rf /etc/cloudflared; rm -f /etc/apt/sources.list.d/cloudflared.list"; fi
                read -p "Press Enter..." ;;
            0) return ;;
        esac
    done
}

menu_tailscale() {
    while true; do
        header; print_c "TAILSCALE VPN MANAGER" "$ORANGE"; draw_sub
        print_opt 1 "Install Tailscale"; print_opt 2 "Run tailscale up (auth)"; print_opt 3 "Status / IP"
        print_opt 4 "Uninstall Tailscale"; print_opt 0 "Back"; draw_bar
        read -p "Select: " ts_opt
        case $ts_opt in
            1)
                if [ ! -c /dev/net/tun ]; then error "TUN/TAP device missing. Ask host to enable."; read -p "Press Enter..."; continue; fi
                run_with_progress "Installing Tailscale" "curl -fsSL https://tailscale.com/install.sh | sh"; read -p "Press Enter..." ;;
            2) if ! command -v tailscale &>/dev/null; then error "Tailscale not installed."; else run_with_progress "Running tailscale up" "tailscale up --reset"; fi; read -p "Press Enter..." ;;
            3) tailscale status || true; tailscale ip -4 || true; read -p "Press Enter..." ;;
            4) read -p "Type 'yes' to uninstall tailscale: " c; if [ "$c" == "yes" ]; then run_with_progress "Removing Tailscale" "systemctl stop tailscaled 2>/dev/null || true; apt-get remove -y tailscale || true; rm -rf /var/lib/tailscale /etc/tailscale || true"; fi; read -p "Press Enter..." ;;
            0) return ;;
        esac
    done
}

# ---------------- Toolbox (wrap) ----------------
menu_toolbox() {
    while true; do
        header; print_c "SYSTEM TOOLBOX" "$PINK"; draw_sub
        print_opt 1 "System Monitor"; print_opt 2 "Add 2GB Swap"; print_opt 3 "Network Speedtest"
        print_opt 4 "Auto-Firewall (UFW)"; print_opt 5 "Database Backup (mysqldump)"; print_opt 6 "Install SSL (Certbot)"
        print_opt 7 "Tailscale Manager" "$ORANGE"; print_opt 8 "Cloudflare Manager" "$ORANGE"; print_opt 9 "Enable Root Access"
        print_opt 10 "SSHX (Web Terminal)"; print_opt 11 "Auto Port Opener (Game+Required)"; print_opt 0 "Back"
        draw_bar; read -p "Select: " opt
        case $opt in
            1) free -h; df -h /; read -p "Press Enter..."; ;;
            2) run_with_progress "Creating 2GB swapfile" "fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"; read -p "Press Enter..."; ;;
            3) run_with_progress "Running speedtest-cli" "apt-get update -y && apt-get install -y speedtest-cli && speedtest-cli --simple"; read -p "Press Enter..."; ;;
            4) run_with_progress "Setting up UFW and basic rules" "apt-get update -y && apt-get install -y ufw && ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw allow 8080 && yes | ufw enable"; read -p "Press Enter..."; ;;
            5)
                read -p "Enter MySQL root password (hidden): " -s SQLPASS; echo
                run_with_progress "Running mysqldump for pterodactyl" "mysqldump -u root -p\"$SQLPASS\" pterodactyl > /root/backup_$(date +%F).sql"; read -p "Press Enter..."; ;;
            6) read -p "Enter domain for certbot (example.com): " DOM; run_with_progress "Installing certbot & obtaining certificate" "apt-get update -y && apt-get install -y certbot && certbot certonly --standalone -d \"$DOM\""; read -p "Press Enter..."; ;;
            7) menu_transition; menu_tailscale ;;
            8) menu_transition; menu_cloudflare ;;
            9) run_with_progress "Enabling root access & setting password" "passwd root; sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config; service ssh restart"; read -p "Press Enter..."; ;;
            10) run_with_progress "Installing SSHX web terminal" "curl -sSf https://sshx.io/get | sh"; sshx || true; read -p "Press Enter..."; ;;
            11) menu_transition; menu_auto_port_opener ;;
            0) return ;;
            *) error "Invalid"; sleep 0.4 ;;
        esac
    done
}

# ---------------- Main menu ----------------
main_menu() {
    while true; do
        header; print_c "MAIN MENU" "$GREEN"; draw_sub
        print_opt 1 "Panel Installation Hub (All Panels)" "$YELLOW"
        print_opt 2 "Addons & Blueprint Manager" "$CYAN"
        print_opt 3 "System Toolbox (Server Tools)" "$PINK"
        draw_sub; print_opt 0 "Exit Installer" "$GREY"; draw_bar
        echo -ne "${CYAN}root@kshosting:~# ${NC}"
        read -r choice
        case $choice in
            1) menu_transition; menu_panel_installation_hub ;;
            2) menu_transition; menu_addons_blueprint ;;
            3) menu_transition; menu_toolbox ;;
            0) clear; exit 0 ;;
            *) error "Invalid Option"; sleep 0.4 ;;
        esac
    done
}

# ---------------- Start here ----------------
boot_screen
main_menu

# End
