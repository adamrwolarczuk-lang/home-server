#!/usr/bin/env bash
set -Eeuo pipefail
LOG=/var/log/ayvatech-home-server-install.log
exec >>"$LOG" 2>&1
echo "Waiting for the package manager to finish..."
for _ in $(seq 1 180); do
  if ! pgrep -x apt >/dev/null && ! pgrep -x apt-get >/dev/null && ! pgrep -x dpkg >/dev/null; then break; fi
  sleep 2
done
if pgrep -x apt >/dev/null || pgrep -x apt-get >/dev/null || pgrep -x dpkg >/dev/null; then
  echo "Package manager remained busy; AYVAtech setup stopped."
  exit 1
fi
user_name="$(loginctl list-users --no-legend 2>/dev/null | awk '$1 >= 1000 {print $2; exit}')"
if [[ -z "$user_name" ]]; then user_name="$(getent passwd 1000 | cut -d: -f1)"; fi
[[ -n "$user_name" ]] || user_name=root
echo "Starting automatic AYVAtech setup for $user_name"
exec env AYVATECH_CALLING_USER="$user_name" /usr/lib/ayvatech-home-server-installer/install.sh