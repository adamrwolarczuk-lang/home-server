#!/usr/bin/env bash
set -Eeuo pipefail
TITLE="AYVAtech Home Server Status"
MARKER=/opt/ayvatech-home-server/.foundation-installed
LOG=/var/log/ayvatech-home-server-install.log
if [[ -f "$MARKER" ]] && ! systemctl is-active --quiet ayvatech-bootstrap.service; then
  zenity --question --title="$TITLE" --ok-label="Open dashboard" --cancel-label="Close" --text="<big><b>Your home server is ready</b></big>\n\nOpen the local dashboard at http://homeserver.local" && xdg-open http://homeserver.local >/dev/null 2>&1 || true
  exit 0
fi
if ! systemctl is-active --quiet ayvatech-bootstrap.service; then
  zenity --question --title="$TITLE" --ok-label="Retry setup" --cancel-label="Close" --text="Automatic setup is not running. Retry it now?" || exit 0
  sudo systemctl reset-failed ayvatech-bootstrap.service >/dev/null 2>&1 || true
  if ! sudo systemctl start --no-block ayvatech-bootstrap.service; then
    details="$(tail -n 30 "$LOG" 2>/dev/null || true)"
    zenity --error --title="$TITLE" --width=720 --text="Setup could not be started.\n\n$details"
    exit 1
  fi
fi
for _ in $(seq 1 20); do
  systemctl is-active --quiet ayvatech-bootstrap.service && break
  systemctl is-failed --quiet ayvatech-bootstrap.service && break
  sleep 0.25
done
(
 last=""
 while systemctl is-active --quiet ayvatech-bootstrap.service; do
   line="$(tail -n1 "$LOG" 2>/dev/null || true)"
   if [[ "$line" != "$last" ]]; then
     case "$line" in
       *"[APP "*"%]"*) n="$(sed -n 's/.*\[APP [0-9][0-9]*\/[0-9][0-9]* \([0-9][0-9]*\)%\].*/\1/p' <<<"$line")";;
       *"[1/8]"*) n=8;;*"[2/8]"*) n=20;;*"[3/8]"*) n=36;;*"[4/8]"*) n=48;;*"[5/8]"*) n=58;;*"[6/8]"*) n=59;;*"[7/8]"*) n=88;;*"[8/8]"*) n=96;;*) n=0;;
     esac
     [[ $n -gt 0 ]] && echo "$n"
     echo "# $line"; last="$line"
   fi
   sleep 1
 done
 [[ -f "$MARKER" ]] && echo 100
) | zenity --progress --title="$TITLE" --width=620 --text="Automatic setup is running…" --auto-close --no-cancel
if [[ -f "$MARKER" ]] && ! systemctl is-active --quiet ayvatech-bootstrap.service; then
  zenity --info --title="$TITLE" --width=540 --text="<big><b>Your home server is ready</b></big>\n\nOpening http://homeserver.local"; xdg-open http://homeserver.local >/dev/null 2>&1 || true
else
  summary="$(tail -n 35 "$LOG" 2>/dev/null || true)"
  zenity --error --title="$TITLE" --width=760 --text="Setup stopped before completion. The successful apps remain installed.\n\n$summary\n\nFull log: $LOG"
fi