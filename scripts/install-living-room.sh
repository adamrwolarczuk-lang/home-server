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
package_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

command -v docker >/dev/null || { echo "Docker is not installed. Finish the main AYVAtech setup first."; exit 1; }
echo "Installing the Jellyfin server..."
install -d -o "$user_name" -g "$user_group" -m0755 "$server_root/data/jellyfin/config" "$server_root/data/jellyfin/cache" "$server_root/data/jellyfin/media"
install -m0644 "$package_root/docker-compose.yml" "$server_root/docker-compose.yml"
cat >"$server_root/.env" <<EOF
PUID=$(id -u "$user_name")
PGID=$(id -g "$user_name")
TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo UTC)
EOF
chmod 0644 "$server_root/.env"
cd "$server_root"
docker compose --profile jellyfin up -d jellyfin

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