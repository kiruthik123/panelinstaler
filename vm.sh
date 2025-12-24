#!/bin/bash
set -euo pipefail

# =============================
# KS GAMING - Pro VM Manager
# Enterprise Virtualization Platform
# =============================

# KS GAMING Brand Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[38;5;208m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display KS GAMING header
display_header() {
    clear
    cat << "EOF"
${BOLD}${RED}
╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║  ██╗  ██╗███████╗      ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗║
║  ██║ ██╔╝██╔════╝     ██╔════╝ ██╔══██╗████╗ ████║██║████╗  ██║██╔════╝║
║  █████╔╝ ███████╗     ██║  ███╗███████║██╔████╔██║██║██╔██╗ ██║██║     ║
║  ██╔═██╗ ╚════██║     ██║   ██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║     ║
║  ██║  ██╗███████║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╗║
║  ╚═╝  ╚═╝╚══════╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝║
║                                                                        ║
║              ${WHITE}ENTERPRISE VIRTUALIZATION PLATFORM${RED}                ║
║              ${WHITE}Powered by QEMU/KVM • KS GAMING Labs${RED}              ║
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝
${NC}
EOF
    echo -e "${BOLD}${CYAN}System Status:${NC}"
    echo -e "${WHITE}• Date: $(date)${NC}"
    echo -e "${WHITE}• Host: $(hostname) | CPU: $(nproc) cores | RAM: $(free -h | awk '/^Mem:/ {print $2}')${NC}"
    echo -e "${WHITE}• Storage: $(df -h ${VM_DIR:-$HOME/vms} | awk 'NR==2 {print $4 " free (" $5 " used)"}')${NC}"
    echo -e "${WHITE}• Active VMs: $(ps aux | grep -c '[q]emu-system') running${NC}"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════════════${NC}\n"
}

# Function to display colored output with KS GAMING styling
print_status() {
    local type=$1
    local message=$2
    
    case $type in
        "INFO") echo -e "${BOLD}${BLUE}[KS INFO]${NC} ${WHITE}$message${NC}" ;;
        "WARN") echo -e "${BOLD}${YELLOW}[KS WARN]${NC} ${WHITE}$message${NC}" ;;
        "ERROR") echo -e "${BOLD}${RED}[KS ERROR]${NC} ${WHITE}$message${NC}" ;;
        "SUCCESS") echo -e "${BOLD}${GREEN}[KS SUCCESS]${NC} ${WHITE}$message${NC}" ;;
        "INPUT") echo -e "${BOLD}${CYAN}[KS INPUT]${NC} ${WHITE}$message${NC}" ;;
        "DEBUG") echo -e "${BOLD}${PURPLE}[KS DEBUG]${NC} ${WHITE}$message${NC}" ;;
        "SECURITY") echo -e "${BOLD}${ORANGE}[KS SECURITY]${NC} ${WHITE}$message${NC}" ;;
        *) echo -e "${BOLD}[$type]${NC} $message" ;;
    esac
}

# Function to display progress bar
progress_bar() {
    local duration=$1
    local message=$2
    echo -ne "${BOLD}${CYAN}[KS PROGRESS]${NC} ${WHITE}$message${NC} ["
    
    for ((i=0; i<duration; i++)); do
        echo -ne "${GREEN}▓${NC}"
        sleep 0.1
    done
    
    echo -e "] ${GREEN}✓${NC}"
}

# Function to validate input with enhanced security
validate_input() {
    local type=$1
    local value=$2
    
    case $type in
        "number")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                print_status "ERROR" "Must be a valid number"
                return 1
            fi
            ;;
        "size")
            if ! [[ "$value" =~ ^[0-9]+[GgMm]$ ]]; then
                print_status "ERROR" "Must be a size with unit (e.g., 100G, 512M)"
                return 1
            fi
            ;;
        "port")
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1024 ] || [ "$value" -gt 65535 ]; then
                print_status "ERROR" "Must be a valid port number (1024-65535)"
                return 1
            fi
            ;;
        "name")
            if ! [[ "$value" =~ ^[a-zA-Z0-9_-]{3,30}$ ]]; then
                print_status "ERROR" "VM name must be 3-30 chars (letters, numbers, hyphens, underscores)"
                return 1
            fi
            ;;
        "username")
            if ! [[ "$value" =~ ^[a-z_][a-z0-9_-]{2,28}$ ]]; then
                print_status "ERROR" "Username must start with a letter/underscore, 3-29 chars"
                return 1
            fi
            ;;
        "password")
            if [ ${#value} -lt 8 ]; then
                print_status "SECURITY" "Password should be at least 8 characters for security"
                read -p "$(print_status "INPUT" "Continue with weak password? (y/N): ")" -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    return 1
                fi
            fi
            ;;
        "ip")
            if ! [[ "$value" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                print_status "ERROR" "Must be a valid IP address"
                return 1
            fi
            ;;
    esac
    return 0
}

# Function to check system requirements
check_system_requirements() {
    print_status "INFO" "Checking system requirements..."
    
    # Check if running as root (not recommended for security)
    if [[ $EUID -eq 0 ]]; then
        print_status "SECURITY" "Running as root is not recommended for security"
        read -p "$(print_status "INPUT" "Continue anyway? (y/N): ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check KVM support
    if [[ ! -e /dev/kvm ]]; then
        print_status "ERROR" "KVM not available. Please enable virtualization in BIOS"
        exit 1
    fi
    
    # Check CPU virtualization support
    if ! grep -Eq '(vmx|svm)' /proc/cpuinfo; then
        print_status "ERROR" "CPU virtualization extensions not detected"
        exit 1
    fi
    
    # Check available memory
    local total_mem=$(free -m | awk '/^Mem:/ {print $2}')
    if [[ $total_mem -lt 2048 ]]; then
        print_status "WARN" "Low system memory ($total_mem MB). Minimum 2GB recommended"
    fi
    
    # Check disk space
    local disk_space=$(df -m "$VM_DIR" | awk 'NR==2 {print $4}')
    if [[ $disk_space -lt 5120 ]]; then
        print_status "WARN" "Low disk space ($disk_space MB). Minimum 5GB recommended"
    fi
    
    progress_bar 5 "System check completed"
}

# Function to check dependencies
check_dependencies() {
    print_status "INFO" "Checking dependencies..."
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img" "sshpass" "rsync")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "ERROR" "Missing dependencies: ${missing_deps[*]}"
        print_status "INFO" "Installing required packages..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y qemu-system cloud-image-utils wget sshpass rsync
        elif command -v yum &> /dev/null; then
            sudo yum install -y qemu-kvm cloud-utils wget sshpass rsync
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qemu-kvm cloud-utils wget sshpass rsync
        else
            print_status "ERROR" "Unsupported package manager"
            exit 1
        fi
        
        progress_bar 3 "Dependencies installed"
    else
        progress_bar 2 "All dependencies satisfied"
    fi
}

# Function to initialize KS GAMING environment
init_ks_environment() {
    print_status "INFO" "Initializing KS GAMING environment..."
    
    # Create directories with proper permissions
    local dirs=("$VM_DIR" "$VM_DIR/iso" "$VM_DIR/backups" "$VM_DIR/templates" "$VM_DIR/logs")
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        if [[ $? -ne 0 ]]; then
            print_status "ERROR" "Failed to create directory: $dir"
            exit 1
        fi
    done
    
    # Set secure permissions
    chmod 750 "$VM_DIR"
    chmod 700 "$VM_DIR"/*
    
    # Create default network configuration
    if [[ ! -f "$VM_DIR/network.conf" ]]; then
        cat > "$VM_DIR/network.conf" <<EOF
# KS GAMING Network Configuration
NETWORK_BASE="192.168.100"
DNS_SERVERS="8.8.8.8,8.8.4.4"
DEFAULT_GATEWAY="192.168.100.1"
EOF
    fi
    
    progress_bar 3 "Environment initialized"
}

# Function to cleanup temporary files
cleanup() {
    print_status "DEBUG" "Cleaning up temporary files..."
    rm -f /tmp/ks-vm-*.tmp
    rm -f user-data meta-data network-config
    print_status "INFO" "Cleanup completed"
}

# Function to log actions
log_action() {
    local action=$1
    local vm_name=${2:-"system"}
    local status=$3
    local log_file="$VM_DIR/logs/ks-vm-$(date +%Y%m%d).log"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $vm_name | $action | $status" >> "$log_file"
}

# Function to get all VM configurations
get_vm_list() {
    find "$VM_DIR" -maxdepth 1 -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

# Function to load VM configuration
load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
    
    if [[ -f "$config_file" ]]; then
        # Clear previous variables
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE
        unset CREATED NETWORK_IP VNC_PORT ENABLE_SPICE GPU_PASSTHROUGH BACKUP_SCHEDULE
        
        source "$config_file"
        return 0
    else
        print_status "ERROR" "Configuration for VM '$vm_name' not found"
        return 1
    fi
}

# Function to save VM configuration with encryption
save_vm_config() {
    local config_file="$VM_DIR/$VM_NAME.conf"
    
    # Create backup of existing config
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$config_file.backup.$(date +%s)"
    fi
    
    cat > "$config_file" <<EOF
# KS GAMING VM Configuration
# Generated: $(date)
# DO NOT EDIT MANUALLY

VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
NETWORK_IP="${NETWORK_IP:-}"
VNC_PORT="${VNC_PORT:-5900}"
ENABLE_SPICE="${ENABLE_SPICE:-true}"
GPU_PASSTHROUGH="${GPU_PASSTHROUGH:-false}"
BACKUP_SCHEDULE="${BACKUP_SCHEDULE:-daily}"
EOF
    
    # Set secure permissions
    chmod 600 "$config_file"
    
    print_status "SUCCESS" "Configuration saved to $config_file"
    log_action "save_config" "$VM_NAME" "success"
}

# Function to display KS GAMING OS selection menu
select_os_menu() {
    display_header
    
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                     SELECT OPERATING SYSTEM                           ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Gaming Optimized OS Options
    declare -A OS_OPTIONS=(
        ["KS Gaming Linux (Custom)"]="gaming|custom|https://ks-gaming.example.com/iso/ks-gaming-latest.img|ksgaming|gamer|Gamer123!"
        ["Ubuntu Gaming Edition"]="ubuntu|gamjammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntugame|gamer|Gamer123!"
        ["Fedora Workstation Gaming"]="fedora|ws40|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedoragame|gamer|Gamer123!"
        ["Windows 11 Gaming VM"]="windows|win11|https://windows-gaming.example.com/win11-gaming.img|win11game|Administrator|GamePass123!"
        ["SteamOS (Holoiso)"]="steamos|holo|https://holoiso.example.com/holoiso-latest.img|steamos|steamuser|SteamDeck!"
        ["Arch Linux Gaming"]="arch|gaming|https://archlinux.example.com/arch-gaming.img|archgame|gamer|Gamer123!"
        ["Pop!_OS Gaming"]="popos|gaming|https://popos.example.com/popos-gaming.img|popgame|gamer|Gamer123!"
    )
    
    local i=1
    for os in "${!OS_OPTIONS[@]}"; do
        printf "${BOLD}${WHITE}%2d${NC}) ${GREEN}%-30s${NC}\n" $i "$os"
        ((i++))
    done
    
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║              KS GAMING RECOMMENDS: Ubuntu Gaming Edition                ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    while true; do
        read -p "$(print_status "INPUT" "Enter your choice (1-${#OS_OPTIONS[@]}): ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#OS_OPTIONS[@]} ]; then
            local os_name=$(echo "${!OS_OPTIONS[@]}" | tr ' ' '\n' | sed -n "${choice}p")
            IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOSTNAME DEFAULT_USERNAME DEFAULT_PASSWORD <<< "${OS_OPTIONS[$os_name]}"
            print_status "SUCCESS" "Selected: $os_name"
            return 0
        else
            print_status "ERROR" "Invalid selection. Please try again."
        fi
    done
}

# Function to create new gaming VM
create_gaming_vm() {
    print_status "INFO" "Creating new KS GAMING Virtual Machine"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════════════${NC}\n"
    
    # OS Selection
    select_os_menu
    
    # VM Naming
    while true; do
        read -p "$(print_status "INPUT" "Enter VM name (default: $DEFAULT_HOSTNAME): ")" VM_NAME
        VM_NAME="${VM_NAME:-$DEFAULT_HOSTNAME}"
        if validate_input "name" "$VM_NAME"; then
            if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then
                print_status "ERROR" "VM '$VM_NAME' already exists"
            else
                break
            fi
        fi
    done
    
    # Gaming-specific configuration
    print_status "INFO" "Select Gaming Profile:"
    echo "  1) Performance (High FPS, competitive gaming)"
    echo "  2) Balanced (Good performance for most games)"
    echo "  3) Casual (Light gaming, energy efficient)"
    echo "  4) Streaming (Optimized for game streaming)"
    
    while true; do
        read -p "$(print_status "INPUT" "Select profile (1-4): ")" profile
        case $profile in
            1) # Performance
                MEMORY="8192"
                CPUS="4"
                DISK_SIZE="100G"
                GPU_PASSTHROUGH="true"
                ;;
            2) # Balanced
                MEMORY="4096"
                CPUS="2"
                DISK_SIZE="80G"
                GPU_PASSTHROUGH="false"
                ;;
            3) # Casual
                MEMORY="2048"
                CPUS="2"
                DISK_SIZE="60G"
                GPU_PASSTHROUGH="false"
                ;;
            4) # Streaming
                MEMORY="6144"
                CPUS="4"
                DISK_SIZE="120G"
                GPU_PASSTHROUGH="true"
                ;;
            *)
                print_status "ERROR" "Invalid profile"
                continue
                ;;
        esac
        break
    done
    
    # Network Configuration
    while true; do
        read -p "$(print_status "INPUT" "SSH Port (default: 22022): ")" SSH_PORT
        SSH_PORT="${SSH_PORT:-22022}"
        if validate_input "port" "$SSH_PORT"; then
            if ss -tln 2>/dev/null | grep -q ":$SSH_PORT "; then
                print_status "ERROR" "Port $SSH_PORT is already in use"
            else
                break
            fi
        fi
    done
    
    # VNC for remote gaming
    while true; do
        read -p "$(print_status "INPUT" "Enable VNC for remote gaming? (y/n): ")" enable_vnc
        if [[ "$enable_vnc" =~ ^[Yy]$ ]]; then
            VNC_PORT=$((5900 + $(ls "$VM_DIR"/*.conf 2>/dev/null | wc -l)))
            print_status "INFO" "VNC will be available on port $VNC_PORT"
            break
        elif [[ "$enable_vnc" =~ ^[Nn]$ ]]; then
            VNC_PORT=""
            break
        fi
    done
    
    # GPU Passthrough check
    if [[ "$GPU_PASSTHROUGH" == "true" ]]; then
        print_status "INFO" "Checking GPU passthrough compatibility..."
        if lspci -nn | grep -q "VGA.*NVIDIA"; then
            print_status "SUCCESS" "NVIDIA GPU detected"
        elif lspci -nn | grep -q "VGA.*AMD"; then
            print_status "SUCCESS" "AMD GPU detected"
        else
            print_status "WARN" "No dedicated GPU detected. Passthrough disabled."
            GPU_PASSTHROUGH="false"
        fi
    fi
    
    # User credentials
    while true; do
        read -p "$(print_status "INPUT" "Enter username (default: $DEFAULT_USERNAME): ")" USERNAME
        USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
        if validate_input "username" "$USERNAME"; then
            break
        fi
    done
    
    while true; do
        echo -e "${BOLD}${ORANGE}Password Requirements:${NC}"
        echo -e "${WHITE}• Minimum 8 characters${NC}"
        echo -e "${WHITE}• Recommended: Mix of letters, numbers, special chars${NC}"
        read -s -p "$(print_status "INPUT" "Enter password: ")" PASSWORD
        echo
        if validate_input "password" "$PASSWORD"; then
            read -s -p "$(print_status "INPUT" "Confirm password: ")" PASSWORD2
            echo
            if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
                print_status "ERROR" "Passwords do not match"
            else
                break
            fi
        fi
    done
    
    # Additional ports for gaming services
    print_status "INFO" "Additional gaming ports (comma-separated):"
    echo -e "${WHITE}Common ports: 7777 (Minecraft), 27015 (Steam), 25565 (Minecraft), 9987 (Teamspeak)${NC}"
    read -p "$(print_status "INPUT" "Enter additional ports: ")" PORT_FORWARDS
    
    # Finish configuration
    HOSTNAME="${VM_NAME}"
    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date '+%Y-%m-%d %H:%M:%S')"
    ENABLE_SPICE="true"
    BACKUP_SCHEDULE="daily"
    
    # Generate IP address
    local vm_count=$(ls "$VM_DIR"/*.conf 2>/dev/null | wc -l)
    NETWORK_IP="192.168.100.$((100 + vm_count))"
    
    # Download and setup VM
    setup_gaming_vm_image
    
    # Save configuration
    save_vm_config
    
    print_status "SUCCESS" "Gaming VM '$VM_NAME' created successfully!"
    print_status "INFO" "Configuration Summary:"
    echo -e "${WHITE}• RAM: ${MEMORY}MB | CPUs: ${CPUS} | Disk: ${DISK_SIZE}${NC}"
    echo -e "${WHITE}• SSH: ssh -p ${SSH_PORT} ${USERNAME}@localhost${NC}"
    echo -e "${WHITE}• IP: ${NETWORK_IP} (internal)${NC}"
    [[ -n "$VNC_PORT" ]] && echo -e "${WHITE}• VNC: localhost:${VNC_PORT} (for remote gaming)${NC}"
    echo -e "${WHITE}• Gaming Ports: ${PORT_FORWARDS:-None}${NC}"
    
    log_action "create_vm" "$VM_NAME" "success"
}

# Function to setup gaming VM image
setup_gaming_vm_image() {
    print_status "INFO" "Preparing KS GAMING virtual machine..."
    progress_bar 10 "Initializing gaming environment"
    
    mkdir -p "$VM_DIR"
    
    # Download image with resume capability
    if [[ ! -f "$IMG_FILE" ]]; then
        print_status "INFO" "Downloading gaming image..."
        if ! wget --continue --progress=bar:force "$IMG_URL" -O "$IMG_FILE.tmp"; then
            print_status "ERROR" "Failed to download gaming image"
            exit 1
        fi
        mv "$IMG_FILE.tmp" "$IMG_FILE"
        progress_bar 5 "Image downloaded"
    fi
    
    # Resize disk for gaming
    qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null || {
        qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
        progress_bar 3 "Gaming disk created"
    }
    
    # Gaming-optimized cloud-init
    cat > user-data <<EOF
#cloud-config
# KS GAMING Optimization Config
hostname: $HOSTNAME
ssh_pwauth: true
disable_root: false
growpart:
  mode: auto
  devices: ['/']

users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "$PASSWORD" | tr -d '\n')
    groups: users, admin, audio, video, games, input
    lock_passwd: false
    gecos: KS Gaming User

chpasswd:
  list: |
    root:$PASSWORD
    $USERNAME:$PASSWORD
  expire: false

# Gaming optimizations
runcmd:
  - |
    # Enable performance governor
    echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils
    systemctl enable cpufrequtils
    
    # Increase inotify watches for game mods
    echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
    
    # Disable unnecessary services
    systemctl disable bluetooth 2>/dev/null || true
    systemctl disable avahi-daemon 2>/dev/null || true
    
    # Create gaming directories
    mkdir -p /home/$USERNAME/Games
    mkdir -p /home/$USERNAME/.config/ks-gaming
    
    # Set gaming-friendly kernel parameters
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Install gaming tools
packages:
  - steam
  - lutris
  - gamemode
  - mesa-utils
  - vulkan-tools
  - wine
  - playonlinux
  - piper # Controller configuration

# Gaming performance tweaks
write_files:
  - path: /etc/security/limits.d/99-gaming.conf
    content: |
      * soft nofile 524288
      * hard nofile 524288
      $USERNAME soft nice -10
      $USERNAME hard nice -10
  - path: /home/$USERNAME/.gamemode.ini
    content: |
      [general]
      desiredgov=performance
      renice=15
      [custom]
      start=notify-send "GameMode started"
      end=notify-send "GameMode ended"
EOF

    cat > meta-data <<EOF
instance-id: ks-gaming-$VM_NAME
local-hostname: $HOSTNAME
network-interfaces: |
  auto eth0
  iface eth0 inet static
  address $NETWORK_IP
  netmask 255.255.255.0
  gateway 192.168.100.1
  dns-nameservers 8.8.8.8 8.8.4.4
EOF

    # Create network configuration for gaming
    cat > network-config <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses: [$NETWORK_IP/24]
    gateway4: 192.168.100.1
    nameservers:
      addresses: [8.8.8.8, 8.8.4.4]
    routes:
      - to: 0.0.0.0/0
        via: 192.168.100.1
EOF

    if ! cloud-localds -v --network-config=network-config "$SEED_FILE" user-data meta-data; then
        print_status "ERROR" "Failed to create gaming seed image"
        exit 1
    fi
    
    progress_bar 5 "Gaming configuration applied"
}

# Function to start gaming VM
start_gaming_vm() {
    local vm_name=$1
    
    if load_vm_config "$vm_name"; then
        print_status "INFO" "Starting KS GAMING VM: $vm_name"
        
        # Check if VM is already running
        if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then
            print_status "WARN" "VM is already running"
            return 0
        fi
        
        # Performance optimizations
        print_status "INFO" "Applying gaming optimizations..."
        
        # Set CPU governor to performance
        if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
            echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
        fi
        
        # Drop caches for better performance
        sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
        
        # Base QEMU command with gaming optimizations
        local qemu_cmd=(
            qemu-system-x86_64
            -name "KS_Gaming_$VM_NAME"
            -enable-kvm
            -cpu host,kvm=on,+invtsc
            -machine q35,accel=kvm
            -m "$MEMORY"
            -smp "$CPUS,sockets=1,cores=$CPUS,threads=1"
            -device virtio-balloon-pci
            -drive "file=$IMG_FILE,format=qcow2,if=virtio,cache=writeback,discard=unmap"
            -drive "file=$SEED_FILE,format=raw,if=virtio,readonly=on"
            -boot order=c
            -nic "user,model=virtio-net-pci,hostfwd=tcp::$SSH_PORT-:22"
        )
        
        # Add VNC for remote gaming
        if [[ -n "$VNC_PORT" ]]; then
            qemu_cmd+=(-vnc "0.0.0.0:$((VNC_PORT - 5900)),password=on")
            print_status "INFO" "VNC available at localhost:$VNC_PORT (password: $PASSWORD)"
        fi
        
        # Add SPICE for better graphics
        if [[ "$ENABLE_SPICE" == "true" ]]; then
            local spice_port=$((VNC_PORT + 100))
            qemu_cmd+=(
                -spice "port=$spice_port,addr=127.0.0.1,disable-ticketing=on"
                -device virtio-serial-pci
                -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0
                -chardev spicevmc,id=spicechannel0,name=vdagent
            )
        fi
        
        # Add port forwards for gaming
        if [[ -n "$PORT_FORWARDS" ]]; then
            IFS=',' read -ra forwards <<< "$PORT_FORWARDS"
            for forward in "${forwards[@]}"; do
                if [[ "$forward" =~ ^([0-9]+):([0-9]+)$ ]]; then
                    local host_port="${BASH_REMATCH[1]}"
                    local guest_port="${BASH_REMATCH[2]}"
                    qemu_cmd+=(-nic "user,model=virtio-net-pci,hostfwd=tcp::$host_port-:$guest_port")
                elif [[ "$forward" =~ ^[0-9]+$ ]]; then
                    qemu_cmd+=(-nic "user,model=virtio-net-pci,hostfwd=tcp::$forward-:$forward")
                fi
            done
        fi
        
        # GPU Passthrough
        if [[ "$GPU_PASSTHROUGH" == "true" ]]; then
            print_status "INFO" "Setting up GPU passthrough..."
            # Find GPU devices
            local gpu_device=$(lspci -nn | grep -E "VGA.*(NVIDIA|AMD)" | head -1 | cut -d' ' -f1)
            if [[ -n "$gpu_device" ]]; then
                qemu_cmd+=(
                    -device vfio-pci,host=$gpu_device
                    -vga none
                    -nographic
                )
                print_status "SUCCESS" "GPU passthrough enabled for device $gpu_device"
            else
                print_status "WARN" "No GPU found for passthrough, using virtual GPU"
                qemu_cmd+=(-vga virtio)
            fi
        else
            qemu_cmd+=(-vga virtio)
        fi
        
        # Performance enhancements
        qemu_cmd+=(
            -device virtio-scsi-pci,id=scsi
            -object rng-random,filename=/dev/urandom,id=rng0
            -device virtio-rng-pci,rng=rng0
            -rtc base=localtime,clock=host
            -device ich9-intel-hda
            -device hda-duplex
            -usb
            -device usb-tablet
            -device usb-kbd
        )
        
        # GUI or console mode
        if [[ "$GUI_MODE" == true ]]; then
            qemu_cmd+=(-display gtk,gl=on,show-cursor=on)
        else
            qemu_cmd+=(-nographic -serial mon:stdio)
        fi
        
        # Start VM in background
        print_status "INFO" "Starting VM with gaming optimizations..."
        "${qemu_cmd[@]}" &
        local qemu_pid=$!
        
        # Wait for VM to boot
        sleep 10
        
        print_status "SUCCESS" "KS GAMING VM '$vm_name' started successfully!"
        print_status "INFO" "Connection Information:"
        echo -e "${WHITE}• SSH: ssh -p $SSH_PORT $USERNAME@localhost${NC}"
        echo -e "${WHITE}• Password: $PASSWORD${NC}"
        [[ -n "$VNC_PORT" ]] && echo -e "${WHITE}• VNC: localhost:$VNC_PORT${NC}"
        echo -e "${WHITE}• Internal IP: $NETWORK_IP${NC}"
        echo -e "${WHITE}• Process ID: $qemu_pid${NC}"
        
        log_action "start_vm" "$vm_name" "success"
    fi
}

# Function to stop gaming VM
stop_gaming_vm() {
    local vm_name=$1
    
    if load_vm_config "$vm_name"; then
        print_status "INFO" "Stopping KS GAMING VM: $vm_name"
        
        # Find QEMU process
        local qemu_pid=$(pgrep -f "qemu-system.*$IMG_FILE")
        
        if [[ -n "$qemu_pid" ]]; then
            # Graceful shutdown
            print_status "INFO" "Sending ACPI shutdown signal..."
            kill -SIGTERM "$qemu_pid"
            
            # Wait for shutdown
            local timeout=30
            while [[ $timeout -gt 0 ]] && ps -p "$qemu_pid" > /dev/null; do
                echo -ne "${WHITE}Waiting for graceful shutdown... ${timeout}s${NC}\r"
                sleep 1
                ((timeout--))
            done
            echo
            
            # Force kill if still running
            if ps -p "$qemu_pid" > /dev/null; then
                print_status "WARN" "Forcing VM termination..."
                kill -9 "$qemu_pid"
            fi
            
            # Restore CPU governor
            echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
            
            print_status "SUCCESS" "VM '$vm_name' stopped"
            log_action "stop_vm" "$vm_name" "success"
        else
            print_status "INFO" "VM '$vm_name' is not running"
        fi
    fi
}

# Function to backup VM
backup_vm() {
    local vm_name=$1
    
    if load_vm_config "$vm_name"; then
        print_status "INFO" "Creating backup of VM: $vm_name"
        
        local backup_dir="$VM_DIR/backups"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$backup_dir/${vm_name}_backup_$timestamp.tar.gz"
        
        mkdir -p "$backup_dir"
        
        # Stop VM if running
        if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then
            print_status "WARN" "VM is running. Stopping for consistent backup..."
            stop_gaming_vm "$vm_name"
            sleep 5
        fi
        
        # Create backup
        print_status "INFO" "Compressing VM files..."
        tar -czf "$backup_file" \
            "$IMG_FILE" \
            "$SEED_FILE" \
            "$VM_DIR/$vm_name.conf" \
            2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            print_status "SUCCESS" "Backup created: $backup_file"
            echo -e "${WHITE}Size: $(du -h "$backup_file" | cut -f1)${NC}"
            log_action "backup" "$vm_name" "success"
        else
            print_status "ERROR" "Backup failed"
            log_action "backup" "$vm_name" "failed"
        fi
    fi
}

# Function to restore VM
restore_vm() {
    print_status "INFO" "Restoring VM from backup"
    
    local backup_dir="$VM_DIR/backups"
    local backups=($(ls -t "$backup_dir"/*.tar.gz 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        print_status "ERROR" "No backups found"
        return 1
    fi
    
    echo -e "${BOLD}${CYAN}Available Backups:${NC}"
    for i in "${!backups[@]}"; do
        local file=$(basename "${backups[$i]}")
        local size=$(du -h "${backups[$i]}" | cut -f1)
        printf "${WHITE}%2d) %-40s (%s)${NC}\n" $((i+1)) "$file" "$size"
    done
    
    while true; do
        read -p "$(print_status "INPUT" "Select backup to restore (1-${#backups[@]}): ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#backups[@]} ]; then
            local backup_file="${backups[$((choice-1))]}"
            
            # Extract VM name from backup filename
            local vm_name=$(basename "$backup_file" | cut -d'_' -f1)
            
            print_status "WARN" "This will overwrite existing VM '$vm_name' if it exists!"
            read -p "$(print_status "INPUT" "Continue? (y/N): ")" -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 0
            fi
            
            # Extract backup
            print_status "INFO" "Restoring from backup..."
            tar -xzf "$backup_file" -C "$VM_DIR" --overwrite
            
            if [[ $? -eq 0 ]]; then
                print_status "SUCCESS" "VM '$vm_name' restored successfully"
                log_action "restore" "$vm_name" "success"
            else
                print_status "ERROR" "Restoration failed"
                log_action "restore" "$vm_name" "failed"
            fi
            break
        else
            print_status "ERROR" "Invalid selection"
        fi
    done
}

# Function to show VM performance dashboard
show_performance_dashboard() {
    local vm_name=$1
    
    if load_vm_config "$vm_name"; then
        print_status "INFO" "KS GAMING Performance Dashboard: $vm_name"
        echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
        
        # Get QEMU process info
        local qemu_pid=$(pgrep -f "qemu-system.*$IMG_FILE")
        
        if [[ -n "$qemu_pid" ]]; then
            # Process stats
            echo -e "${BOLD}${GREEN}■ RUNNING${NC}"
            echo -e "${WHITE}Process ID: $qemu_pid${NC}"
            
            # CPU Usage
            local cpu_usage=$(ps -p "$qemu_pid" -o %cpu --no-headers | tr -d ' ')
            echo -e "${WHITE}CPU Usage: ${cpu_usage:-0}%${NC}"
            
            # Memory Usage
            local mem_usage=$(ps -p "$qemu_pid" -o %mem --no-headers | tr -d ' ')
            echo -e "${WHITE}Memory Usage: ${mem_usage:-0}%${NC}"
            
            # Disk Usage
            local disk_usage=$(du -h "$IMG_FILE" 2>/dev/null | cut -f1)
            echo -e "${WHITE}Disk Usage: ${disk_usage:-N/A}${NC}"
            
            # Network connections
            echo -e "\n${BOLD}${CYAN}Network Ports:${NC}"
            echo -e "${WHITE}• SSH: localhost:$SSH_PORT${NC}"
            [[ -n "$VNC_PORT" ]] && echo -e "${WHITE}• VNC: localhost:$VNC_PORT${NC}"
            if [[ -n "$PORT_FORWARDS" ]]; then
                echo -e "${WHITE}• Gaming Ports: $PORT_FORWARDS${NC}"
            fi
        else
            echo -e "${BOLD}${RED}■ STOPPED${NC}"
            echo -e "${WHITE}Configuration:${NC}"
            echo -e "${WHITE}• RAM: ${MEMORY}MB | CPUs: ${CPUS} | Disk: ${DISK_SIZE}${NC}"
            echo -e "${WHITE}• GPU Passthrough: $GPU_PASSTHROUGH${NC}"
            echo -e "${WHITE}• VNC: ${VNC_PORT:-Disabled}${NC}"
        fi
        
        echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    fi
}

# Function to optimize system for gaming
optimize_system() {
    print_status "INFO" "Running KS GAMING System Optimizer"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════════════${NC}\n"
    
    # Check current system state
    print_status "INFO" "1. Checking current system state..."
    
    # CPU Governor
    local current_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    print_status "INFO" "   Current CPU governor: $current_gov"
    
    # Memory
    local total_mem=$(free -m | awk '/^Mem:/ {print $2}')
    local used_mem=$(free -m | awk '/^Mem:/ {print $3}')
    print_status "INFO" "   Memory: ${used_mem}MB / ${total_mem}MB used"
    
    # Swappiness
    local swappiness=$(cat /proc/sys/vm/swappiness)
    print_status "INFO" "   Swappiness: $swappiness"
    
    echo -e "\n${BOLD}${CYAN}2. Applying optimizations:${NC}"
    
    # Set CPU governor to performance
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
        print_status "SUCCESS" "   CPU governor set to performance"
    fi
    
    # Optimize swappiness for gaming
    echo 10 | sudo tee /proc/sys/vm/swappiness >/dev/null
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf >/dev/null
    print_status "SUCCESS" "   Swappiness optimized"
    
    # Increase inotify watches for game mods
    echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf >/dev/null
    print_status "SUCCESS" "   Inotify watches increased"
    
    # Disable transparent hugepages for some games
    echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null 2>&1
    print_status "SUCCESS" "   Transparent hugepages disabled"
    
    # Apply sysctl settings
    sudo sysctl -p >/dev/null
    
    echo -e "\n${BOLD}${GREEN}✓ System optimization complete!${NC}"
    echo -e "${WHITE}Restart VMs for changes to take full effect.${NC}"
    
    log_action "optimize_system" "system" "success"
}

# Main menu function
main_menu() {
    while true; do
        display_header
        
        local vms=($(get_vm_list))
        local vm_count=${#vms[@]}
        
        if [ $vm_count -gt 0 ]; then
            print_status "INFO" "Managed VMs ($vm_count):"
            for i in "${!vms[@]}"; do
                local vm_name="${vms[$i]}"
                local status="${RED}■ STOPPED${NC}"
                
                if pgrep -f "qemu-system.*$vm_name" >/dev/null; then
                    status="${GREEN}■ RUNNING${NC}"
                fi
                
                printf "  ${WHITE}%2d${NC}) ${CYAN}%-25s${NC} %s\n" $((i+1)) "$vm_name" "$status"
            done
            echo
        fi
        
        echo -e "${BOLD}${ORANGE}KS GAMING VM MANAGER${NC}"
        echo -e "${WHITE}  1) Create New Gaming VM${NC}"
        
        if [ $vm_count -gt 0 ]; then
            echo -e "${WHITE}  2) Start Gaming VM${NC}"
            echo -e "${WHITE}  3) Stop Gaming VM${NC}"
            echo -e "${WHITE}  4) Performance Dashboard${NC}"
            echo -e "${WHITE}  5) Backup VM${NC}"
            echo -e "${WHITE}  6) Restore VM${NC}"
            echo -e "${WHITE}  7) Delete VM${NC}"
        fi
        
        echo -e "${WHITE}  8) System Optimizer${NC}"
        echo -e "${WHITE}  9) View Logs${NC}"
        echo -e "${WHITE}  0) Exit${NC}"
        echo
        
        read -p "$(print_status "INPUT" "Select option: ")" choice
        
        case $choice in
            1)
                create_gaming_vm
                ;;
            2)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to start: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        start_gaming_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            3)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to stop: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        stop_gaming_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            4)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number for dashboard: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        show_performance_dashboard "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            5)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to backup: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        backup_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            6)
                restore_vm
                ;;
            7)
                if [ $vm_count -gt 0 ]; then
                    read -p "$(print_status "INPUT" "Enter VM number to delete: ")" vm_num
                    if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then
                        delete_vm "${vms[$((vm_num-1))]}"
                    else
                        print_status "ERROR" "Invalid selection"
                    fi
                fi
                ;;
            8)
                optimize_system
                ;;
            9)
                view_logs
                ;;
            0)
                print_status "INFO" "Thank you for using KS GAMING VM Manager!"
                exit 0
                ;;
            *)
                print_status "ERROR" "Invalid option"
                ;;
        esac
        
        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    done
}

# Function to view logs
view_logs() {
    print_status "INFO" "KS GAMING Activity Logs"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════════════${NC}\n"
    
    local log_file="$VM_DIR/logs/ks-vm-$(date +%Y%m%d).log"
    
    if [[ -f "$log_file" ]]; then
        echo -e "${BOLD}${CYAN}Today's Logs:${NC}"
        echo -e "${WHITE}$(cat "$log_file")${NC}"
    else
        print_status "INFO" "No logs found for today"
    fi
    
    echo -e "\n${BOLD}${CYAN}Recent Log Files:${NC}"
    ls -la "$VM_DIR/logs/" 2>/dev/null | head -10
    
    read -p "$(print_status "INPUT" "Press Enter to continue...")"
}

# Function to delete VM (unchanged from original but with KS branding)
delete_vm() {
    local vm_name=$1
    
    print_status "WARN" "WARNING: This will permanently delete VM '$vm_name' and all its data!"
    read -p "$(print_status "INPUT" "Type 'DELETE' to confirm: ")" -r
    echo
    if [[ "$REPLY" == "DELETE" ]]; then
        if load_vm_config "$vm_name"; then
            rm -f "$IMG_FILE" "$SEED_FILE" "$VM_DIR/$vm_name.conf"
            print_status "SUCCESS" "VM '$vm_name' has been deleted"
            log_action "delete_vm" "$vm_name" "success"
        fi
    else
        print_status "INFO" "Deletion cancelled"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Initialize
print_status "INFO" "Initializing KS GAMING VM Manager..."
check_system_requirements
check_dependencies

# Set VM directory
VM_DIR="${VM_DIR:-$HOME/ks-gaming-vms}"
init_ks_environment

# Start main menu
main_menu
