#!/bin/bash

# ==================================================
# KS HOSTING • Professional Installer Menu
# ==================================================

# ---------- THEME ----------
BG_CLEAR="\033[2J\033[H"
PRIMARY='\033[38;5;39m'     # Cyan Blue
SECONDARY='\033[38;5;33m'   # Deep Blue
SUCCESS='\033[38;5;82m'     # Green
WARNING='\033[38;5;214m'    # Orange
DANGER='\033[38;5;196m'     # Red
TEXT='\033[38;5;252m'       # Light Gray
RESET='\033[0m'

# ---------- UI FUNCTIONS ----------
ks_banner() {
  echo -e "$BG_CLEAR"
  echo -e "${PRIMARY}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${PRIMARY}║${TEXT}              ☁️  KS HOSTING              ${PRIMARY}║${RESET}"
  echo -e "${PRIMARY}║${SECONDARY}     Secure • Fast • Cloud Platform      ${PRIMARY}║${RESET}"
  echo -e "${PRIMARY}║${TEXT}                BY KS GAMING              ${PRIMARY}║${RESET}"
  echo -e "${PRIMARY}╚══════════════════════════════════════════╝${RESET}"
  echo
}

pause() {
  echo
  read -p "↩️  Press Enter to continue..."
}

loading() {
  echo -ne "${PRIMARY}⏳ Processing"
  for i in {1..3}; do
    echo -ne "."
    sleep 0.4
  done
  echo -e "${RESET}"
}

# ---------- PANEL MANAGER ----------
panel_manager() {
  while true; do
    ks_banner
    echo -e "${SECONDARY}🧩 PANEL MANAGER${RESET}"
    echo -e "${PRIMARY}1)${TEXT} Pterodactyl Panel${RESET}"
    echo -e "${PRIMARY}2)${TEXT} Skyport Panel${RESET}"
    echo -e "${PRIMARY}3)${TEXT} Airlink Panel${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Select option: " p

    case $p in
      1) loading; echo "▶ Pterodactyl Panel selected"; pause ;;
      2) loading; echo "▶ Skyport Panel selected"; pause ;;
      3) loading; echo "▶ Airlink Panel selected"; pause ;;
      0) break ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ---------- BLUEPRINT ----------
blueprint() {
  ks_banner
  echo -e "${SECONDARY}📘 BLUEPRINT${RESET}"
  echo -e "${TEXT}"
  echo "• Predefined setup templates"
  echo "• Automated workflows (future)"
  echo "• Standardized deployments"
  echo -e "${RESET}"
  pause
}

# ---------- SYSTEM TOOL ----------
system_tool() {
  while true; do
    ks_banner
    echo -e "${SECONDARY}🛠️  SYSTEM TOOL${RESET}"
    echo -e "${PRIMARY}1)${TEXT} 🌐 Install Tailscale${RESET}"
    echo -e "${PRIMARY}2)${TEXT} ☁️  Install Cloudflare Tunnel${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🔑 Enable Root Access${RESET}"
    echo -e "${PRIMARY}4)${TEXT} 🔐 SSHX (tmate)${RESET}"
    echo -e "${PRIMARY}5)${TEXT} 🔄 Change SSH Port${RESET}"
    echo -e "${PRIMARY}6)${TEXT} 🔒 Enable / Disable SSH Password Login${RESET}"
    echo -e "${PRIMARY}7)${TEXT} ♻️  Restart SSH Service${RESET}"
    echo -e "${PRIMARY}8)${TEXT} ⬆️  System Update${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Select option: " s

    case $s in
      1)
        loading
        curl -fsSL https://tailscale.com/install.sh | sh
        pause
        ;;
      2)
        loading
        mkdir -p --mode=0755 /usr/share/keyrings
        curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg \
          | tee /usr/share/keyrings/cloudflare.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/cloudflare.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
          | tee /etc/apt/sources.list.d/cloudflared.list
        apt update && apt install cloudflared -y
        pause
        ;;
      3)
        loading
        passwd root
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        systemctl restart ssh
        pause
        ;;
      4)
        loading
        apt install tmate -y
        tmate
        ;;
      5)
        read -p "🔢 Enter new SSH port: " port
        sed -i "s/^#Port .*/Port $port/" /etc/ssh/sshd_config
        systemctl restart ssh
        echo "✅ SSH port changed to $port"
        pause
        ;;
      6)
        read -p "Enable password login? (yes/no): " ans
        if [ "$ans" = "yes" ]; then
          sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        else
          sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        fi
        systemctl restart ssh
        pause
        ;;
      7)
        systemctl restart ssh
        echo "✅ SSH restarted"
        pause
        ;;
      8)
        loading
        apt update && apt upgrade -y
        pause
        ;;
      0) break ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ---------- MAIN MENU ----------
while true; do
  ks_banner
  echo -e "${PRIMARY}1)${TEXT} 🧩 Panel Manager${RESET}"
  echo -e "${PRIMARY}2)${TEXT} 📘 Blueprint${RESET}"
  echo -e "${PRIMARY}3)${TEXT} 🛠️  System Tool${RESET}"
  echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
  echo
  read -p "➜ Select option: " main

  case $main in
    1) panel_manager ;;
    2) blueprint ;;
    3) system_tool ;;
    0)
      echo -e "${SUCCESS}👋 Thank you for using KS HOSTING${RESET}"
      exit
      ;;
    *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
  esac
done
