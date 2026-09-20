#!/usr/bin/env bash
set -e
APP_DIR="/opt/ayvatech-home-server"
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo $0"
  exit 1
fi
apt-get update
apt-get upgrade -y
cd "$APP_DIR"
docker compose pull
docker compose up -d
docker image prune -f
echo "Update complete."
