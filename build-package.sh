#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD="$ROOT/build/package"; DIST="$ROOT/dist"
rm -rf -- "$ROOT/build"; mkdir -p "$BUILD/usr/lib/ayvatech-home-server-installer/scripts" "$BUILD/usr/lib/ayvatech-home-server-installer/dashboard" "$BUILD/usr/lib/ayvatech-home-server-installer/config" "$DIST"
cp -a "$ROOT/packaging/." "$BUILD/"
install -m0755 "$ROOT/install.sh" "$ROOT/gui-installer.sh" "$BUILD/usr/lib/ayvatech-home-server-installer/"
install -m0644 "$ROOT/docker-compose.yml" "$BUILD/usr/lib/ayvatech-home-server-installer/"
install -m0755 "$ROOT/scripts/"*.sh "$BUILD/usr/lib/ayvatech-home-server-installer/scripts/"
install -m0644 "$ROOT/dashboard/index.html" "$ROOT/dashboard/catalog.json" "$BUILD/usr/lib/ayvatech-home-server-installer/dashboard/"
install -m0755 "$ROOT/dashboard/server.py" "$BUILD/usr/lib/ayvatech-home-server-installer/dashboard/server.py"
install -m0644 "$ROOT/packaging/lib/systemd/system/ayvatech-dashboard.service" "$BUILD/usr/lib/ayvatech-home-server-installer/config/ayvatech-dashboard.service"
install -m0644 "$ROOT/packaging/etc/nginx/sites-available/ayvatech-dashboard" "$BUILD/usr/lib/ayvatech-home-server-installer/config/ayvatech-dashboard.nginx"
find "$BUILD" -type d -exec chmod 0755 {} +
chmod 0755 "$BUILD/usr/bin/ayvatech-home-server-installer"
chmod 0644 "$BUILD/usr/share/applications/ayvatech-home-server-installer.desktop" "$BUILD/etc/nginx/sites-available/ayvatech-dashboard" "$BUILD/lib/systemd/system/ayvatech-dashboard.service"
dpkg-deb --root-owner-group --build "$BUILD" "$DIST/AYVAtech-Home-Server-Installer-3.0.0-beta.4.deb"
echo "Built: $DIST/AYVAtech-Home-Server-Installer-3.0.0-beta.4.deb"