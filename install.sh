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
[[ "$mem_kb" -ge 3800000 ]] || fail "Beta 12 requires at least 4 GB RAM for the automatic application stack."
free_kb="$(df -Pk / | awk 'NR==2{print $4}')"
[[ "$free_kb" -ge 20000000 ]] || fail "Beta 12 requires at least 20 GB free system storage."
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

step 6 "Installing and checking each application"
SERVER_ROOT=/opt/ayvatech-home-server
STATUS_FILE=/var/lib/ayvatech-home-server/install-status.tsv
USER_GROUP="$(id -gn "$USER_NAME")"
install -d -m0755 "$SERVER_ROOT"
install -d -m0755 "$(dirname "$STATUS_FILE")"
: >"$STATUS_FILE"
install -d -o "$USER_NAME" -g "$USER_GROUP" -m0755 \
  "$SERVER_ROOT/data/jellyfin/config" "$SERVER_ROOT/data/jellyfin/cache" "$SERVER_ROOT/data/jellyfin/media" \
  "$SERVER_ROOT/data/filebrowser/files" "$SERVER_ROOT/data/filebrowser/data" \
  "$SERVER_ROOT/data/syncthing" \
  "$SERVER_ROOT/data/navidrome/data" "$SERVER_ROOT/data/navidrome/music" \
  "$SERVER_ROOT/data/audiobookshelf/config" "$SERVER_ROOT/data/audiobookshelf/metadata" \
  "$SERVER_ROOT/data/audiobookshelf/audiobooks" "$SERVER_ROOT/data/audiobookshelf/podcasts"
install -d -m0755 \
  "$SERVER_ROOT/data/portainer" "$SERVER_ROOT/data/uptime-kuma" "$SERVER_ROOT/data/homeassistant" \
  "$SERVER_ROOT/data/beszel" "$SERVER_ROOT/data/beszel-socket" \
  "$SERVER_ROOT/data/backrest/data" "$SERVER_ROOT/data/backrest/config" "$SERVER_ROOT/data/backrest/cache" \
  "$SERVER_ROOT/data/backrest/tmp" "$SERVER_ROOT/data/backrest/rclone" "$SERVER_ROOT/backups" \
  "$SERVER_ROOT/data/freshrss/data" "$SERVER_ROOT/data/freshrss/extensions" \
  "$SERVER_ROOT/data/actual-budget" "$SERVER_ROOT/data/mealie"
install -m0644 "$SOURCE/docker-compose.yml" "$SERVER_ROOT/docker-compose.yml"
cat >"$SERVER_ROOT/.env" <<EOF
PUID=$(id -u "$USER_NAME")
PGID=$(id -g "$USER_NAME")
TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo UTC)
EOF
chmod 0644 "$SERVER_ROOT/.env"
cd "$SERVER_ROOT"
apps=(
  "portainer|Portainer"
  "uptime-kuma|Uptime Kuma"
  "jellyfin|Jellyfin"
  "filebrowser|FileBrowser Quantum"
  "homeassistant|Home Assistant"
  "beszel|Beszel"
  "backrest|Backrest"
  "syncthing|Syncthing"
  "navidrome|Navidrome"
  "audiobookshelf|Audiobookshelf"
  "freshrss|FreshRSS"
  "actual-budget|Actual Budget"
  "mealie|Mealie"
)
failed_apps=()
app_total="${#apps[@]}"
for i in "${!apps[@]}"; do
  IFS='|' read -r service display_name <<<"${apps[$i]}"
  app_number=$((i + 1))
  progress=$((58 + (app_number * 27 / app_total)))
  echo "[APP $app_number/$app_total $progress%] Installing $display_name"
  if ! docker compose pull "$service"; then
    echo "[APP $app_number/$app_total $progress%] FAILED $display_name - image download failed"
    printf '%s\t%s\t%s\n' "$service" "$display_name" "FAILED: image download" >>"$STATUS_FILE"
    failed_apps+=("$display_name")
    continue
  fi
  if ! docker compose up -d --no-deps "$service"; then
    echo "[APP $app_number/$app_total $progress%] FAILED $display_name - container creation failed"
    printf '%s\t%s\t%s\n' "$service" "$display_name" "FAILED: container creation" >>"$STATUS_FILE"
    failed_apps+=("$display_name")
    continue
  fi
  app_running=false
  for _ in $(seq 1 30); do
    if docker compose ps --status running --services | grep -qx "$service"; then app_running=true; break; fi
    sleep 2
  done
  if [[ "$app_running" == true ]]; then
    echo "[APP $app_number/$app_total $progress%] OK $display_name is running"
    printf '%s\t%s\t%s\n' "$service" "$display_name" "INSTALLED" >>"$STATUS_FILE"
  else
    echo "[APP $app_number/$app_total $progress%] FAILED $display_name - container did not stay running"
    docker compose logs --tail=30 "$service" || true
    printf '%s\t%s\t%s\n' "$service" "$display_name" "FAILED: not running" >>"$STATUS_FILE"
    failed_apps+=("$display_name")
  fi
done

step 7 "Starting the local control centre"
systemctl daemon-reload
systemctl enable --now ayvatech-dashboard
nginx -t
systemctl restart nginx

step 8 "Preparing the installation summary"
for _ in $(seq 1 30); do
  curl -fsS http://127.0.0.1/health >/dev/null 2>&1 && break
  sleep 2
done
curl -fsS http://127.0.0.1/health >/dev/null || fail "The dashboard health check did not respond."
if ((${#failed_apps[@]} > 0)); then
  echo "INSTALLATION FINISHED WITH ERRORS"
  echo "Installed successfully: $((app_total - ${#failed_apps[@]}))/$app_total"
  echo "Failed applications: ${failed_apps[*]}"
  echo "The successful applications remain installed and running. Retry setup after checking the messages above."
  exit 1
fi
touch "$SERVER_ROOT/.foundation-installed"
ip="$(hostname -I | awk '{print $1}')"
echo "AYVAtech Home Server is ready on ${PRETTY_NAME:-Linux}"
echo "INSTALLATION SUCCESSFUL: all $app_total applications are running"
echo "Open dashboard: http://homeserver.local"
echo "Backup address: http://$ip"
echo "Detailed log: $log"
