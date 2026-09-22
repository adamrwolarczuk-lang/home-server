# AYVAtech Home Server

Turn an Ubuntu, Zorin OS, or compatible Debian-family computer into a ready-to-configure home server using one visible shell installer. No `.deb` package is used.

## Download Beta 16 — shell installer only

**[Download install-all.sh](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.16/install-all.sh)**

Beta software is for testing on a spare computer. Back up important data first. Beta 16 requires at least 4 GB RAM and 20 GB free system storage; 8 GB RAM is recommended.

Save `install-all.sh` in Downloads, then copy and paste:

```bash
cd ~/Downloads
chmod +x install-all.sh
sudo ./install-all.sh
```

The script does not install or download a Debian package. It downloads the AYVAtech project files directly from GitHub, installs the dashboard and maintenance tools, then installs and checks all 13 applications one by one while showing the complete output in Terminal.

If you prefer to download it from Terminal:

```bash
cd ~/Downloads
curl -fL https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.16/install-all.sh -o install-all.sh
chmod +x install-all.sh
sudo ./install-all.sh
```

Downloading the container images can take considerable time during the first installation. Leave Terminal open so you can see each step, success, or exact failure.

## Installed automatically

Beta 16 installs, starts, and verifies these 13 application services:

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

The AYVAtech dashboard, Docker, SSH, local network discovery, and always-on settings are installed as core services. Each application is downloaded, started, and checked separately. A permanent result list is saved to `/var/lib/ayvatech-home-server/install-status.tsv`. Setup is marked complete only after the dashboard responds and all 13 application containers are running.

Each application still needs its first-run owner account or choices. Change any supplied default password immediately. Configure Backrest to use separate backup storage and test a restore before relying on it.

## Repair or reinstall applications

These commands are safe to run again. They use the same AYVAtech Compose stack and existing data folders, so the applications remain visible in the dashboard and their stored data is not deliberately erased.

Reinstall or repair all 13 applications:

```bash
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh all
```

Or copy only the application you need:

```bash
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh portainer
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh uptime-kuma
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh jellyfin
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh filebrowser
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh homeassistant
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh beszel
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh backrest
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh syncthing
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh navidrome
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh audiobookshelf
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh freshrss
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh actual-budget
sudo /usr/lib/ayvatech-home-server-installer/scripts/install-app.sh mealie
```

Each command downloads the current image, starts that application, waits for it to remain running, and prints its logs if it fails. Refresh `http://homeserver.local` after the command finishes.

## Added extras

The dashboard explains these applications, but Beta 16 does not silently configure them because they require storage, security, network, account, or legal decisions:

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

Beta 16 does not silently update every container overnight. Updates remain deliberate. Review them first, then use the supplied update command:

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