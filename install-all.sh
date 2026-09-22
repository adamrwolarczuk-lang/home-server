#!/usr/bin/env bash
set -Eeuo pipefail
VERSION=3.0.0-beta.16
ARCHIVE_URL="https://github.com/adamrwolarczuk-lang/home-server/archive/refs/tags/v${VERSION}.tar.gz"
INSTALL_ROOT=/usr/lib/ayvatech-home-server-installer
APPS=(
  "Portainer — Docker management"
  "Uptime Kuma — service monitoring"
  "Jellyfin — movies, television and music"
  "FileBrowser Quantum — browser file manager"
  "Home Assistant — smart-home control"
  "Beszel — system monitoring"
  "Backrest + Restic — backups"
  "Syncthing — file synchronisation"
  "Navidrome — music streaming"
  "Audiobookshelf — audiobooks and podcasts"
  "FreshRSS — feed reader"
  "Actual Budget — household budgeting"
  "Mealie — recipes and meal planning"
)
if [[ $EUID -ne 0 ]]; then
  echo "Please run: sudo bash $0"
  exit 1
fi
command -v apt-get >/dev/null || { echo "Ubuntu, Zorin OS, or Debian with APT is required."; exit 1; }
[[ "$(ps -p 1 -o comm=)" == systemd ]] || { echo "systemd is required."; exit 1; }
target_user="${SUDO_USER:-}"
if [[ -z "$target_user" || "$target_user" == root ]]; then
  target_user="$(loginctl list-users --no-legend 2>/dev/null | awk '$1 >= 1000 {print $2; exit}' || true)"
fi
[[ -n "$target_user" ]] || target_user="$(getent passwd 1000 | cut -d: -f1 || true)"
[[ -n "$target_user" ]] || target_user=root

echo "AYVAtech Home Server — standalone shell installer"
echo "No .deb package will be used."
echo "The following applications will be installed and connected to the dashboard:"
printf '  - %s\n' "${APPS[@]}"
echo

echo "[SETUP 1/4] Installing download tools"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bash ca-certificates curl tar sudo zenity desktop-file-utils
work_dir="$(mktemp -d /tmp/ayvatech-shell-installer.XXXXXX)"
cleanup(){ rm -rf -- "$work_dir"; }
trap cleanup EXIT

echo "[SETUP 2/4] Downloading AYVAtech installation files"
curl -fL "$ARCHIVE_URL" -o "$work_dir/source.tar.gz"
tar -xzf "$work_dir/source.tar.gz" --strip-components=1 -C "$work_dir"

echo "[SETUP 3/4] Installing the dashboard and maintenance tools"
systemctl disable --now ayvatech-bootstrap.service >/dev/null 2>&1 || true
install -d -m0755 "$INSTALL_ROOT/scripts" "$INSTALL_ROOT/dashboard" "$INSTALL_ROOT/config"
install -m0755 "$work_dir/install.sh" "$work_dir/gui-installer.sh" "$work_dir/bootstrap.sh" "$INSTALL_ROOT/"
install -m0644 "$work_dir/docker-compose.yml" "$INSTALL_ROOT/"
install -m0755 "$work_dir/scripts/"*.sh "$INSTALL_ROOT/scripts/"
install -m0644 "$work_dir/dashboard/index.html" "$work_dir/dashboard/catalog.json" "$INSTALL_ROOT/dashboard/"
install -m0755 "$work_dir/dashboard/server.py" "$INSTALL_ROOT/dashboard/server.py"
install -m0644 "$work_dir/packaging/lib/systemd/system/ayvatech-dashboard.service" "$INSTALL_ROOT/config/ayvatech-dashboard.service"
install -m0644 "$work_dir/packaging/lib/systemd/system/ayvatech-bootstrap.service" /etc/systemd/system/ayvatech-bootstrap.service
install -m0644 "$work_dir/packaging/etc/nginx/sites-available/ayvatech-dashboard" "$INSTALL_ROOT/config/ayvatech-dashboard.nginx"
install -m0755 "$work_dir/packaging/usr/bin/ayvatech-home-server-installer" /usr/bin/
install -m0755 "$work_dir/packaging/usr/bin/ayvatech-living-room-setup" /usr/bin/
install -m0644 "$work_dir/packaging/usr/share/applications/"*.desktop /usr/share/applications/
install -d -m0755 /usr/share/icons/hicolor/scalable/apps
install -m0644 "$work_dir/packaging/usr/share/icons/hicolor/scalable/apps/ayvatech-home-server.svg" /usr/share/icons/hicolor/scalable/apps/
update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
systemctl daemon-reload

echo "[SETUP 4/4] Running the full installation with live progress"
env AYVATECH_CALLING_USER="$target_user" "$INSTALL_ROOT/install.sh"
echo
echo "SUCCESS: AYVAtech Home Server and all 13 applications are installed."
echo "Open http://homeserver.local"