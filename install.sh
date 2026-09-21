#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${AYVATECH_CALLING_USER:-${SUDO_USER:-$USER}}"
log=/var/log/ayvatech-home-server-install.log
exec > >(tee -a "$log") 2>&1
rm -f /opt/ayvatech-home-server/.foundation-installed
step(){ echo "[$1/8] $2"; }
fail(){ echo "Compatibility check failed: $*" >&2; exit 1; }

step 1 "Checking this computer and detecting Linux"
[[ -r /etc/os-release ]] || fail "This system does not provide /etc/os-release."
. /etc/os-release
command -v apt-get >/dev/null || fail "An APT-based Ubuntu or Debian system is required."
[[ "$(ps -p 1 -o comm=)" == systemd ]] || fail "systemd is required."
arch="$(dpkg --print-architecture)"
case "$arch" in amd64|arm64) ;; *) fail "CPU architecture $arch is not supported yet. Use amd64 or arm64.";; esac
DOCKER_FAMILY=""
DOCKER_SUITE=""
case "${ID:-}" in
  ubuntu)
    DOCKER_FAMILY=ubuntu; DOCKER_SUITE="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}" ;;
  zorin|linuxmint|pop|elementary)
    DOCKER_FAMILY=ubuntu; DOCKER_SUITE="${UBUNTU_CODENAME:-}" ;;
  debian)
    DOCKER_FAMILY=debian; DOCKER_SUITE="${VERSION_CODENAME:-}" ;;
  *)
    if [[ " ${ID_LIKE:-} " == *" ubuntu "* && -n "${UBUNTU_CODENAME:-}" ]]; then
      DOCKER_FAMILY=ubuntu; DOCKER_SUITE="$UBUNTU_CODENAME"
    elif [[ " ${ID_LIKE:-} " == *" debian "* && -n "${VERSION_CODENAME:-}" ]]; then
      DOCKER_FAMILY=debian; DOCKER_SUITE="$VERSION_CODENAME"
    else
      fail "${PRETTY_NAME:-This Linux distribution} is not currently supported."
    fi ;;
esac
[[ -n "$DOCKER_SUITE" ]] || fail "Could not determine the compatible Ubuntu/Debian base release."
mem_kb="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
[[ "$mem_kb" -ge 1900000 ]] || fail "At least 2 GB RAM is required."
free_kb="$(df -Pk / | awk 'NR==2{print $4}')"
[[ "$free_kb" -ge 10000000 ]] || fail "At least 10 GB free system storage is required."
echo "Detected: ${PRETTY_NAME:-$ID} ($arch)"
echo "Package family: $DOCKER_FAMILY $DOCKER_SUITE"
echo "Memory: $((mem_kb/1024)) MB; free system storage: $((free_kb/1024/1024)) GB"

step 2 "Updating packages and installing server essentials"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg openssh-server avahi-daemon nginx python3
systemctl enable --now ssh avahi-daemon nginx
hostnamectl set-hostname homeserver

step 3 "Enabling always-on server mode"
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true

step 4 "Installing the correct Docker build for $DOCKER_FAMILY $DOCKER_SUITE"
if command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
  echo "A compatible Docker installation already exists; keeping it."
else
  for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do apt-get remove -y "$p" >/dev/null 2>&1 || true; done
  install -m0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/$DOCKER_FAMILY/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DOCKER_FAMILY
Suites: $DOCKER_SUITE
Components: stable
Architectures: $arch
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
systemctl enable --now docker
usermod -aG docker "$USER_NAME" || true

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

step 6 "Installing the starter application bundle"
SERVER_ROOT=/opt/ayvatech-home-server
USER_GROUP="$(id -gn "$USER_NAME")"
install -d -m0755 "$SERVER_ROOT"
install -d -o "$USER_NAME" -g "$USER_GROUP" -m0755 \
  "$SERVER_ROOT/data/jellyfin/config" \
  "$SERVER_ROOT/data/jellyfin/cache" \
  "$SERVER_ROOT/data/jellyfin/media" \
  "$SERVER_ROOT/data/filebrowser/root" \
  "$SERVER_ROOT/data/filebrowser/database" \
  "$SERVER_ROOT/data/filebrowser/config"
install -d -m0755 "$SERVER_ROOT/data/portainer" "$SERVER_ROOT/data/uptime-kuma" "$SERVER_ROOT/data/homeassistant"
install -m0644 "$SOURCE/docker-compose.yml" "$SERVER_ROOT/docker-compose.yml"
cat >"$SERVER_ROOT/.env" <<EOF
PUID=$(id -u "$USER_NAME")
PGID=$(id -g "$USER_NAME")
TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo UTC)
EOF
chmod 0644 "$SERVER_ROOT/.env"
cd "$SERVER_ROOT"
docker compose --profile portainer --profile uptime --profile jellyfin --profile files --profile homeassistant up -d

step 7 "Starting the local control centre"
systemctl daemon-reload
systemctl enable --now ayvatech-dashboard
nginx -t
systemctl restart nginx

step 8 "Verifying the dashboard and installed applications"
for _ in $(seq 1 30); do
  curl -fsS http://127.0.0.1/health >/dev/null 2>&1 && break
  sleep 2
done
curl -fsS http://127.0.0.1/health >/dev/null || fail "The dashboard health check did not respond."
expected=(portainer uptime-kuma jellyfin filebrowser homeassistant)
running="$(docker compose ps --status running --services)"
for service in "${expected[@]}"; do
  grep -qx "$service" <<<"$running" || fail "$service did not start. Check: docker compose logs $service"
done
touch "$SERVER_ROOT/.foundation-installed"
ip="$(hostname -I | awk '{print $1}')"
echo "AYVAtech Home Server is ready on ${PRETTY_NAME:-Linux}"
echo "Installed applications: Portainer, Uptime Kuma, Jellyfin, File Browser, Home Assistant"
echo "Open dashboard: http://homeserver.local"
echo "Backup address: http://$ip"
echo "Detailed log: $log"
