#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${AYVATECH_CALLING_USER:-${SUDO_USER:-$USER}}"
log=/var/log/ayvatech-home-server-install.log
exec > >(tee -a "$log") 2>&1
step(){ echo "[$1/7] $2"; }
. /etc/os-release; [[ "${ID:-}" == ubuntu ]] || { echo "Ubuntu is required."; exit 1; }
step 1 "Updating Ubuntu"; apt-get update
step 2 "Installing remote access, local naming and web services"
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg openssh-server avahi-daemon nginx python3
systemctl enable --now ssh avahi-daemon nginx
hostnamectl set-hostname homeserver
step 3 "Enabling always-on server mode"
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true
step 4 "Installing Docker"
for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do apt-get remove -y "$p" >/dev/null 2>&1 || true; done
install -m0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
arch="$(dpkg --print-architecture)"
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $arch
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker; usermod -aG docker "$USER_NAME" || true
step 5 "Installing the AYVAtech dashboard"
id ayvatech-dashboard >/dev/null 2>&1 || useradd --system --home /nonexistent --shell /usr/sbin/nologin ayvatech-dashboard
usermod -aG docker ayvatech-dashboard
install -d -m0755 /usr/share/ayvatech-dashboard /usr/lib/ayvatech-dashboard
install -m0644 "$SOURCE/dashboard/index.html" "$SOURCE/dashboard/catalog.json" /usr/share/ayvatech-dashboard/
install -m0755 "$SOURCE/dashboard/server.py" /usr/lib/ayvatech-dashboard/server.py
install -m0644 "$SOURCE/config/ayvatech-dashboard.service" /etc/systemd/system/
install -m0644 "$SOURCE/config/ayvatech-dashboard.nginx" /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/ayvatech-dashboard /etc/nginx/sites-enabled/ayvatech-dashboard
rm -f /etc/nginx/sites-enabled/default
step 6 "Starting the local control centre"
systemctl daemon-reload; systemctl enable --now ayvatech-dashboard; nginx -t; systemctl restart nginx
step 7 "Finishing setup"
ip="$(hostname -I | awk '{print $1}')"
echo "AYVAtech Home Server is ready"
echo "Open: http://homeserver.local"
echo "Backup address: http://$ip"
echo "Detailed log: $log"
