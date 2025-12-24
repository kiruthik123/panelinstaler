#!/bin/bash

# ==================================================
# KS HOSTING • Professional Installer Menu
# ==================================================

# ---------- THEME ----------
BG_CLEAR="\033[2J\033[H"
PRIMARY='\033[38;5;39m'
SECONDARY='\033[38;5;33m'
SUCCESS='\033[38;5;82m'
WARNING='\033[38;5;214m'
DANGER='\033[38;5;196m'
TEXT='\033[38;5;252m'
RESET='\033[0m'

BASE_BLUEPRINT_URL="https://raw.githubusercontent.com/kiruthik123/panelinstaler/main"

# ---------- UI ----------
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

# ==================================================
# PANEL MANAGER
# ==================================================
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
      0) break ;;
      1|2|3)
        loading
        echo "ℹ️ Panel installer hook ready"
        pause
        ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ==================================================
# BLUEPRINT ADDONS
# ==================================================
blueprint_addons() {
  while true; do
    ks_banner
    echo -e "${SECONDARY}🧩 BLUEPRINT ADDONS${RESET}"
    echo
    echo -e "${PRIMARY}1)${TEXT} 🎨 Euphoria Theme${RESET}"
    echo -e "${PRIMARY}2)${TEXT} 🧱 Sidebar Layout${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🖼️ Server Backgrounds${RESET}"
    echo -e "${PRIMARY}4)${TEXT} 🔧 MC Tools${RESET}"
    echo -e "${PRIMARY}5)${TEXT} 📜 Player Listing${RESET}"
    echo -e "${PRIMARY}6)${TEXT} 🔄 Recolor Panel${RESET}"
    echo -e "${PRIMARY}7)${TEXT} 🧩 Vanilla Tweaks${RESET}"
    echo -e "${PRIMARY}8)${TEXT} 🌐 Subdomains${RESET}"
    echo -e "${PRIMARY}9)${TEXT} 👤 Player Manager${RESET}"
    echo -e "${PRIMARY}10)${TEXT} 🗳️ Votifier Tester${RESET}"
    echo -e "${PRIMARY}11)${TEXT} 🧾 Simple Footers${RESET}"
    echo -e "${PRIMARY}12)${TEXT} 🛠️ DB Edit${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Select addon: " ad

    case $ad in
      1) bp="euphoriatheme.blueprint" ;;
      2) bp="sidebar.blueprint" ;;
      3) bp="serverbackgrounds.blueprint" ;;
      4) bp="mctools.blueprint" ;;
      5) bp="playerlisting.blueprint" ;;
      6) bp="recolor.blueprint" ;;
      7) bp="vanillatweaks.blueprint" ;;
      8) bp="subdomains.blueprint" ;;
      9) bp="minecraftplayermanager.blueprint" ;;
      10) bp="votifierester.blueprint" ;;
      11) bp="simplefooters.blueprint" ;;
      12) bp="dbedit.blueprint" ;;
      0) break ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1; continue ;;
    esac

    echo
    read -p "Apply $bp ? (y/n): " c
    if [[ "$c" == "y" || "$c" == "Y" ]]; then
      loading
      curl -fsSL "$BASE_BLUEPRINT_URL/$bp" | bash
      pause
    fi
  done
}

# ==================================================
# BLUEPRINT MENU
# ==================================================
blueprint() {
  while true; do
    ks_banner
    echo -e "${SECONDARY}📘 BLUEPRINT${RESET}"
    echo -e "${PRIMARY}1)${TEXT} 🚀 Install Blueprint${RESET}"
    echo -e "${PRIMARY}2)${TEXT} 🧩 Blueprint Addons${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Select option: " bp

    case $bp in
      1)
        read -p "Proceed with Blueprint install? (y/n): " y
        if [[ "$y" == "y" || "$y" == "Y" ]]; then
          loading
          bash <(curl -fsSL "$BASE_BLUEPRINT_URL/blueprint-installer.sh")
          pause
        fi
        ;;
      2) blueprint_addons ;;
      0) break ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ==================================================
# SYSTEM TOOL
# ==================================================
system_tool() {
  while true; do
    ks_banner
    echo -e "${SECONDARY}🛠️  SYSTEM TOOL${RESET}"
    echo -e "${PRIMARY}1)${TEXT} 🌐 Install Tailscale${RESET}"
    echo -e "${PRIMARY}2)${TEXT} ☁️  Install Cloudflare Tunnel${RESET}"
    echo -e "${PRIMARY}3)${TEXT} 🔑 Enable Root Access${RESET}"
    echo -e "${PRIMARY}4)${TEXT} 🔐 SSHX (tmate)${RESET}"
    echo -e "${PRIMARY}5)${TEXT} 🔄 Change SSH Port${RESET}"
    echo -e "${PRIMARY}6)${TEXT} 🔒 SSH Password Login${RESET}"
    echo -e "${PRIMARY}7)${TEXT} ♻️ Restart SSH${RESET}"
    echo -e "${PRIMARY}8)${TEXT} ⬆️ System Update${RESET}"
    echo -e "${DANGER}0)${TEXT} Back${RESET}"
    echo
    read -p "➜ Select option: " s

    case $s in
      1) loading; curl -fsSL https://tailscale.com/install.sh | sh; pause ;;
      2)
        loading
        mkdir -p /usr/share/keyrings
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
      4) loading; apt install tmate -y; tmate ;;
      5)
        read -p "Enter new SSH port: " port
        sed -i "s/^#Port .*/Port $port/" /etc/ssh/sshd_config
        systemctl restart ssh
        pause
        ;;
      6)
        read -p "Enable password login? (yes/no): " a
        [[ "$a" == "yes" ]] && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
                            || sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        systemctl restart ssh
        pause
        ;;
      7) systemctl restart ssh; pause ;;
      8) loading; apt update && apt upgrade -y; pause ;;
      0) break ;;
      *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ==================================================
# MAIN MENU
# ==================================================
while true; do
  ks_banner
  echo -e "${PRIMARY}1)${TEXT} 🧩 Panel Manager${RESET}"
  echo -e "${PRIMARY}2)${TEXT} 📘 Blueprint${RESET}"
  echo -e "${PRIMARY}3)${TEXT} 🛠️ System Tool${RESET}"
  echo -e "${DANGER}0)${TEXT} 🚪 Exit${RESET}"
  echo
  read -p "➜ Select option: " main

  case $main in
    1) panel_manager ;;
    2) blueprint ;;
    3) system_tool ;;
    0) echo -e "${SUCCESS}👋 Thank you for using KS HOSTING${RESET}"; exit ;;
    *) echo -e "${DANGER}❌ Invalid option${RESET}"; sleep 1 ;;
  esac
done
