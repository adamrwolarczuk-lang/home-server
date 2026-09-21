#!/usr/bin/env bash
set -Eeuo pipefail
VERSION=3.0.0-beta.14
PACKAGE="AYVAtech-Home-Server-Installer-${VERSION}.deb"
URL="https://github.com/adamrwolarczuk-lang/home-server/releases/download/v${VERSION}/${PACKAGE}"
LOG=/var/log/ayvatech-home-server-install.log
MARKER=/opt/ayvatech-home-server/.foundation-installed
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
echo "AYVAtech Home Server — complete installer"
echo "The following applications will be installed and connected to the dashboard:"
printf '  - %s\n' "${APPS[@]}"
echo
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
package_path="$(mktemp --suffix=.deb /tmp/ayvatech-home-server.XXXXXX)"
cleanup(){ rm -f -- "$package_path"; [[ -n "${tail_pid:-}" ]] && kill "$tail_pid" >/dev/null 2>&1 || true; }
trap cleanup EXIT
curl -fL "$URL" -o "$package_path"
apt-get install -y "$package_path"
systemctl reset-failed ayvatech-bootstrap.service >/dev/null 2>&1 || true
systemctl restart --no-block ayvatech-bootstrap.service
for _ in $(seq 1 40); do
  systemctl is-active --quiet ayvatech-bootstrap.service && break
  systemctl is-failed --quiet ayvatech-bootstrap.service && break
  sleep 0.25
done
echo
echo "Live installation progress:"
touch "$LOG"
tail -n 0 -F "$LOG" &
tail_pid=$!
while systemctl is-active --quiet ayvatech-bootstrap.service; do sleep 1; done
kill "$tail_pid" >/dev/null 2>&1 || true
wait "$tail_pid" 2>/dev/null || true
tail_pid=""
if [[ -f "$MARKER" ]] && ! systemctl is-failed --quiet ayvatech-bootstrap.service; then
  echo
echo "SUCCESS: AYVAtech Home Server and all 13 applications are installed."
  echo "Open http://homeserver.local"
else
  echo
  echo "The installation did not complete. The exact final messages are:"
  tail -n 50 "$LOG" || true
  echo "You can retry all applications with:"
  echo "sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh all"
  exit 1
fi