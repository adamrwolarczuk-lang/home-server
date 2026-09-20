#!/usr/bin/env bash
set -e
APP_DIR="/opt/ayvatech-home-server"
echo "AYVAtech Home Server Status"
echo "Host: $(hostname)"
echo "IP:   $(hostname -I | awk '{print $1}')"
echo
echo "SSH:    $(systemctl is-active ssh || true)"
echo "Docker: $(systemctl is-active docker || true)"
echo
cd "$APP_DIR"
docker compose ps -a
