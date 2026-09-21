#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
[[ -f /opt/ayvatech-home-server/.foundation-installed ]] || { echo "The main AYVAtech server setup must finish first."; exit 1; }
user_name="${AYVATECH_CALLING_USER:-${SUDO_USER:-}}"
[[ -n "$user_name" && "$user_name" != root ]] || { echo "Could not identify the desktop user."; exit 1; }
user_home="$(getent passwd "$user_name" | cut -d: -f6)"
[[ -d "$user_home" ]] || { echo "Could not find the desktop user's home folder."; exit 1; }
user_group="$(id -gn "$user_name")"
server_root=/opt/ayvatech-home-server

command -v docker >/dev/null || { echo "Docker is not installed. Finish the main AYVAtech setup first."; exit 1; }
cd "$server_root"
docker compose up -d jellyfin
echo "Installing VLC, Flatpak and the Jellyfin Desktop television client..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y flatpak vlc
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system --noninteractive -y flathub org.jellyfin.JellyfinDesktop

if [[ "${1:-}" == "--autostart" ]]; then
  install -d -o "$user_name" -g "$user_group" -m0755 "$user_home/.config/autostart"
  cat >"$user_home/.config/autostart/ayvatech-living-room.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=AYVAtech Living Room
Comment=Open Jellyfin in television mode
Exec=flatpak run org.jellyfin.JellyfinDesktop
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
  chown "$user_name:$user_group" "$user_home/.config/autostart/ayvatech-living-room.desktop"
fi

touch "$server_root/.living-room-installed"
echo
echo "Living Room Mode is installed."
echo "First open http://homeserver.local:8096 to create the Jellyfin owner account."
echo "Then open Jellyfin Desktop and connect it to http://homeserver.local:8096"
echo "Use VLC from the application menu for physical DVDs."
