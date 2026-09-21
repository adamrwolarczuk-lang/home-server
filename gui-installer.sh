#!/usr/bin/env bash
set -Eeuo pipefail
TITLE="AYVAtech Home Server Status"
MARKER=/opt/ayvatech-home-server/.foundation-installed
LOG=/var/log/ayvatech-home-server-install.log
if [[ -f "$MARKER" ]]; then
  zenity --question --title="$TITLE" --ok-label="Open dashboard" --cancel-label="Close" --text="<big><b>Your home server is ready</b></big>\n\nOpen the local dashboard at http://homeserver.local" && xdg-open http://homeserver.local >/dev/null 2>&1 || true
  exit 0
fi
if ! systemctl is-active --quiet ayvatech-bootstrap.service; then
  zenity --question --title="$TITLE" --ok-label="Retry setup" --cancel-label="Close" --text="Automatic setup is not running. Retry it now?" || exit 0
  sudo systemctl restart ayvatech-bootstrap.service
fi
(
 last=""
 while systemctl is-active --quiet ayvatech-bootstrap.service; do
   line="$(tail -n1 "$LOG" 2>/dev/null || true)"
   if [[ "$line" != "$last" ]]; then
     case "$line" in *"[1/8]"*) n=8;;*"[2/8]"*) n=20;;*"[3/8]"*) n=36;;*"[4/8]"*) n=48;;*"[5/8]"*) n=58;;*"[6/8]"*) n=72;;*"[7/8]"*) n=86;;*"[8/8]"*) n=96;;*) n=0;;esac
     [[ $n -gt 0 ]] && echo "$n"
     echo "# $line"; last="$line"
   fi
   sleep 1
 done
 [[ -f "$MARKER" ]] && echo 100
) | zenity --progress --title="$TITLE" --width=620 --text="Automatic setup is running…" --auto-close --no-cancel
if [[ -f "$MARKER" ]]; then
  zenity --info --title="$TITLE" --width=540 --text="<big><b>Your home server is ready</b></big>\n\nOpening http://homeserver.local"; xdg-open http://homeserver.local >/dev/null 2>&1 || true
else
  zenity --error --title="$TITLE" --width=580 --text="Setup stopped before completion.\n\nLog: $LOG"
fi