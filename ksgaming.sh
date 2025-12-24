#!/bin/bash
# ============================================================
# KS HOSTING • PTERODACTYL INSTALLER
# Panel + Wings + Cloudflare + Tailscale + Auto Wings Config
# ============================================================

set -e

# ---------------- COLORS ----------------
BLUE="\e[34m"; GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"
BOLD="\e[1m"; RESET="\e[0m"

# ---------------- UI ----------------
banner() {
clear
echo -e "${BLUE}${BOLD}"
echo "================================================="
echo "        KS HOSTING • PTERODACTYL INSTALLER        "
echo "================================================="
echo -e "${RESET}"
}

ok(){ echo -e "${GREEN}✔ $1${RESET}"; }
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; }
err(){ echo -e "${RED}✖ $1${RESET}"; }

pause(){ read -rp "Press ENTER to continue..."; }

# ============================================================
# ASK PANEL DETAILS
# ============================================================
ask_panel_details() {
read -rp "Panel Domain (panel.example.com): " PANEL_DOMAIN
read -rp "Admin Email (Gmail): " ADMIN_EMAIL
read -rp "Admin Username [admin]: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}
read -rsp "Admin Password: " ADMIN_PASS
echo
ADMIN_PASS=${ADMIN_PASS:-Admin@123}
}

# ============================================================
# INSTALL PANEL (OFFICIAL FLOW)
# ============================================================
install_panel() {
banner
echo "Installing Pterodactyl Panel"
ask_panel_details

# Disable Apache
systemctl stop apache2 >/dev/null 2>&1 || true
systemctl disable apache2 >/dev/null 2>&1 || true
systemctl mask apache2 >/dev/null 2>&1 || true

apt update -y
apt install -y curl wget unzip tar git redis-server gnupg software-properties-common \
               mariadb-server nginx certbot python3-certbot-nginx

# PHP 8.1
add-apt-repository ppa:ondrej/php -y || true
apt update -y
apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring \
               php8.1-xml php8.1-bcmath php8.1-curl php8.1-zip php8.1-intl

# Database (auth_socket compatible)
mysql -u root -e "CREATE DATABASE IF NOT EXISTS panel;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'ptero'@'127.0.0.1' IDENTIFIED BY 'PteroDBPass!';"
mysql -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1'; FLUSH PRIVILEGES;"

# Composer
if ! command -v composer >/dev/null; then
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

# Download Panel
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzf panel.tar.gz
rm panel.tar.gz
chmod -R 755 storage/* bootstrap/cache

cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force

php artisan p:environment:setup \
  --author="$ADMIN_EMAIL" \
  --url="https://$PANEL_DOMAIN" \
  --timezone="Asia/Kolkata" \
  --cache="redis" \
  --session="redis" \
  --queue="redis"

php artisan p:environment:database \
  --db-host="127.0.0.1" \
  --db-port="3306" \
  --db-database="panel" \
  --db-username="ptero" \
  --db-password="PteroDBPass!"

php artisan migrate --seed --force

php artisan p:user:make \
  --email="$ADMIN_EMAIL" \
  --username="$ADMIN_USER" \
  --name-first="Admin" \
  --name-last="User" \
  --password="$ADMIN_PASS" \
  --admin=1

# Nginx
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name $PANEL_DOMAIN;
    root /var/www/pterodactyl/public;
    index index.php;

    location / { try_files \$uri \$uri/ /index.php?\$query_string; }

    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

certbot --nginx -d "$PANEL_DOMAIN" -m "$ADMIN_EMAIL" --agree-tos --non-interactive || true

ok "Panel Installed → https://$PANEL_DOMAIN"
pause
}

# ============================================================
# INSTALL WINGS
# ============================================================
install_wings() {
banner
echo "Installing Wings Daemon"

curl -fsSL https://get.docker.com | sh
mkdir -p /etc/pterodactyl /var/lib/pterodactyl

curl -Lo /usr/local/bin/wings \
https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings
After=docker.service

[Service]
ExecStart=/usr/local/bin/wings
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now wings

ok "Wings Installed"
pause
}

# ============================================================
# AUTO CONFIGURE WINGS
# ============================================================
configure_wings() {
banner
echo "Auto Configure Wings (Port 443)"

read -rp "UUID: " W_UUID
read -rp "Token ID: " W_TOKEN_ID
read -rsp "Token: " W_TOKEN
echo
read -rp "Panel URL (https://panel.example.com): " W_REMOTE

cat > /etc/pterodactyl/config.yml <<EOF
debug: false
uuid: $W_UUID
token_id: $W_TOKEN_ID
token: $W_TOKEN

api:
  host: 0.0.0.0
  port: 443

remote: "$W_REMOTE"
EOF

systemctl restart wings
ok "Wings Configured (Port 443)"
pause
}

# ============================================================
# CLOUDFLARE TUNNEL
# ============================================================
install_cloudflare() {
banner
echo "Installing Cloudflare Tunnel"

mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg \
 | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" \
 | tee /etc/apt/sources.list.d/cloudflared.list

apt update -y
apt install -y cloudflared

ok "Cloudflare Tunnel Installed"
pause
}

# ============================================================
# TAILSCALE
# ============================================================
install_tailscale() {
banner
echo "Installing Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
ok "Tailscale Installed"
pause
}

# ============================================================
# MAIN MENU
# ============================================================
while true; do
banner
echo "1) Install Panel"
echo "2) Install Wings"
echo "3) Auto Configure Wings (UUID / Token / Port 443)"
echo "4) Install Cloudflare Tunnel"
echo "5) Install Tailscale"
echo "0) Exit"
echo "--------------------------------------------"
read -rp "Select option: " opt

case "$opt" in
  1) install_panel ;;
  2) install_wings ;;
  3) configure_wings ;;
  4) install_cloudflare ;;
  5) install_tailscale ;;
  0) exit 0 ;;
  *) warn "Invalid option"; pause ;;
esac
done
