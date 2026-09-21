# AYVAtech Home Server

Turn an Ubuntu, Zorin OS, or compatible Debian-family computer into a ready-to-configure home server. Installing the `.deb` starts the full setup automatically.

## Download Beta 10

**[Download AYVAtech Home Server v3.0.0 Beta 10](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.10/AYVAtech-Home-Server-Installer-3.0.0-beta.10.deb)**

Beta software is for testing on a spare computer. Back up important data first. Beta 10 requires at least 4 GB RAM and 20 GB free system storage; 8 GB RAM is recommended.

## Install on Zorin OS or Ubuntu

```bash
cd ~/Downloads
sudo apt update
sudo apt install ./AYVAtech-Home-Server-Installer-3.0.0-beta.10.deb
```

Use Terminal if Zorin Software reports a PolicyKit or `polkit-agent-helper-1` permission error. Open **AYVAtech Home Server Status** from the application menu to follow all eight stages.

## Installed automatically

Beta 10 installs, starts, and verifies these 13 application services:

- **Portainer** — Docker management — `https://homeserver.local:9443`
- **Uptime Kuma** — availability monitoring — `http://homeserver.local:3001`
- **Jellyfin** — movies, television and music — `http://homeserver.local:8096`
- **FileBrowser Quantum** — maintained browser file manager — `http://homeserver.local:8080`
- **Home Assistant** — smart-home control — `http://homeserver.local:8123`
- **Beszel** — detailed system monitoring — `http://homeserver.local:8090`
- **Backrest + Restic** — scheduled, restorable backups — `http://homeserver.local:9898`
- **Syncthing** — trusted-device folder synchronisation — `http://homeserver.local:8384`
- **Navidrome** — personal music streaming — `http://homeserver.local:4533`
- **Audiobookshelf** — audiobooks and podcasts — `http://homeserver.local:13378`
- **FreshRSS** — private feed reader — `http://homeserver.local:8084`
- **Actual Budget** — household budgeting — `http://homeserver.local:5006`
- **Mealie** — recipes and meal planning — `http://homeserver.local:9925`

The AYVAtech dashboard, Docker, SSH, local network discovery, and always-on settings are installed as core services. Setup is marked complete only after the dashboard responds and all 13 application containers are running.

Each application still needs its first-run owner account or choices. Change any supplied default password immediately. Configure Backrest to use separate backup storage and test a restore before relying on it.

## Added extras

The dashboard explains these applications, but Beta 10 does not silently configure them because they require storage, security, network, account, or legal decisions:

- Nextcloud
- Immich
- Paperless-ngx
- AdGuard Home
- Vaultwarden
- Tailscale
- Samba file shares
- Minecraft Server
- Living Room Mode

Living Room Mode remains available from the application menu and adds Jellyfin Desktop plus VLC DVD playback.

## Dashboard

Open:

```text
http://homeserver.local
```

If local-name discovery is unavailable, use `http://127.0.0.1` on the server or the server IP address from another device.

## Updates

Beta 10 does not silently update every container overnight. Updates remain deliberate. Review them first, then use the supplied update command:

```bash
sudo /usr/lib/ayvatech-home-server-installer/scripts/update.sh
```

## Troubleshooting

```bash
sudo systemctl status ayvatech-bootstrap.service --no-pager
sudo tail -n 150 /var/log/ayvatech-home-server-install.log
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

Retry setup:

```bash
sudo systemctl restart ayvatech-bootstrap.service
```

## Security

Keep the server on a trusted home network while completing first-run setup. Do not expose application ports directly to the internet. Use secure remote access such as Tailscale, keep the system updated, and maintain tested backups.
