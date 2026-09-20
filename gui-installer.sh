#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"; TITLE="AYVAtech Home Server"
zenity --question --title="$TITLE" --width=560 --ok-label="Install home server" --text="<big><b>Turn this PC into an AYVAtech Home Server</b></big>\n\nThis installs Docker, secure remote access, local naming, always-on mode and your private dashboard. Optional apps can be added afterwards.\n\nAllow 10–30 minutes." || exit 0
zenity --info --title="$TITLE — Administrator access" --width=520 --text="The terminal will now ask for your Ubuntu/Zorin password. Type it and press Enter to continue."
sudo -v || { zenity --error --title="$TITLE" --text="Administrator authentication failed."; exit 1; }
tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
(sudo -n env AYVATECH_CALLING_USER="$(id -un)" bash "$ROOT/install.sh" >"$tmp" 2>&1; echo $? >"$tmp.status") &
pid=$!
while kill -0 "$pid" 2>/dev/null; do line="$(tail -n1 "$tmp" 2>/dev/null||true)"; case "$line" in "[1/7]"*) n=10;;"[2/7]"*) n=22;;"[3/7]"*) n=35;;"[4/7]"*) n=48;;"[5/7]"*) n=72;;"[6/7]"*) n=88;;"[7/7]"*) n=96;;*) n=0;;esac; [[ $n -gt 0 ]]&&{ echo "$n";echo "# $line";};sleep .5;done | zenity --progress --title="$TITLE" --auto-close --no-cancel --width=600
wait "$pid"||true
if [[ "$(cat "$tmp.status" 2>/dev/null||echo 1)" == 0 ]];then zenity --info --title="$TITLE — Ready" --width=540 --text="<big><b>Your home server is ready</b></big>\n\nOpen http://homeserver.local in a browser.\n\nThe dashboard shows what is installed, whether it is running and how to use it."; xdg-open http://homeserver.local >/dev/null 2>&1||true;else zenity --error --title="$TITLE" --text="Installation stopped. See /var/log/ayvatech-home-server-install.log";fi
