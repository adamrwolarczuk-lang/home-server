#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR=/opt/ayvatech-home-server
declare -A APP_NAMES=(
  [portainer]="Portainer"
  [uptime-kuma]="Uptime Kuma"
  [jellyfin]="Jellyfin"
  [filebrowser]="FileBrowser Quantum"
  [homeassistant]="Home Assistant"
  [beszel]="Beszel"
  [backrest]="Backrest"
  [syncthing]="Syncthing"
  [navidrome]="Navidrome"
  [audiobookshelf]="Audiobookshelf"
  [freshrss]="FreshRSS"
  [actual-budget]="Actual Budget"
  [mealie]="Mealie"
)
APPS=(portainer uptime-kuma jellyfin filebrowser homeassistant beszel backrest syncthing navidrome audiobookshelf freshrss actual-budget mealie)
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo $0 all"
  exit 1
fi
if [[ ! -f "$APP_DIR/docker-compose.yml" ]]; then
  echo "AYVAtech application stack was not found at $APP_DIR. Install the main AYVAtech package first."
  exit 1
fi
target="${1:-}"
if [[ -z "$target" ]]; then
  echo "Usage: sudo $0 all|APP_NAME"
  echo "Available: ${APPS[*]}"
  exit 2
fi
if [[ "$target" == all ]]; then
  selected=("${APPS[@]}")
elif [[ -n "${APP_NAMES[$target]:-}" ]]; then
  selected=("$target")
else
  echo "Unknown application: $target"
  echo "Available: ${APPS[*]}"
  exit 2
fi
systemctl enable --now docker
cd "$APP_DIR"
failed=()
for service in "${selected[@]}"; do
  name="${APP_NAMES[$service]}"
  echo
  echo "Installing $name ($service)..."
  if docker compose pull "$service" && docker compose up -d --no-deps "$service"; then
    running=false
    for _ in $(seq 1 30); do
      if docker compose ps --status running --services | grep -qx "$service"; then running=true; break; fi
      sleep 2
    done
    if [[ "$running" == true ]]; then
      echo "OK: $name is installed, running, and visible in the AYVAtech dashboard."
      continue
    fi
  fi
  echo "FAILED: $name"
  docker compose logs --tail=40 "$service" || true
  failed+=("$name")
done
if ((${#failed[@]} > 0)); then
  echo
  echo "Failed applications: ${failed[*]}"
  exit 1
fi
echo
echo "Completed successfully. Open http://homeserver.local"