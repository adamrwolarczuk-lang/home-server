# AYVAtech Home Server

Turn an old Ubuntu, Zorin OS, or compatible Debian-family computer into a home server. Installing the `.deb` automatically starts the full server setup; there is no second installer command to remember.

## Download Beta 7

**[Download AYVAtech Home Server v3.0.0 Beta 7](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.7/AYVAtech-Home-Server-Installer-3.0.0-beta.7.deb)**

Beta software is for testing on a spare computer. Back up important data first.

## Install on Zorin OS or Ubuntu

1. Download Beta 7 using the link above.
2. Open Terminal and run:

```bash
cd ~/Downloads
sudo apt update
sudo apt install ./AYVAtech-Home-Server-Installer-3.0.0-beta.7.deb
```

The package immediately queues the full setup in the background after `apt` finishes. Open **AYVAtech Home Server Status** from the application menu to follow progress. When it is ready, the status window can open the dashboard.

If Zorin Software displays a PolicyKit or `polkit-agent-helper-1` permission error, use the Terminal commands above. This avoids the broken graphical Software authentication path.

## What the automatic setup changes

- Checks the Linux distribution, architecture, memory, and free storage
- Sets the computer name to `homeserver`
- Installs Docker Engine and Docker Compose
- Installs and enables SSH remote access
- Enables local `homeserver.local` discovery
- Disables sleep and hibernation so the server stays available
- Installs and starts the AYVAtech dashboard
- Shows live CPU, memory, storage, temperature, uptime, and service status
- Adds a searchable 22-application catalogue with plain-English guidance

The automatic setup log is saved at `/var/log/ayvatech-home-server-install.log`.

## After installation

On the server or another device on the same network, open:

```text
http://homeserver.local
```

If local-name discovery is unavailable on a device, the status screen and install log also show the server's IP address.

Beta 7 installs the server foundation and dashboard. The expanded optional applications are shown and explained in the catalogue, but they are not all one-click installable from the dashboard yet.

## Application catalogue

- **Core:** Docker, SSH, Always-on mode, AYVAtech Dashboard
- **Management:** Portainer, Uptime Kuma, Beszel
- **Storage and backup:** File Browser, Samba, Syncthing, Nextcloud, Duplicati
- **Media:** Jellyfin, Navidrome, Audiobookshelf
- **Photos and documents:** Immich, Paperless-ngx
- **Home and network:** Home Assistant, AdGuard Home
- **Security and remote access:** Tailscale, Vaultwarden
- **Other tools:** FreshRSS, Actual Budget, Mealie, Minecraft Server

## Supported systems

The preflight recognises Ubuntu, Zorin OS, Linux Mint, Pop!_OS, elementary OS, Debian, and compatible Ubuntu/Debian derivatives. It chooses the appropriate Docker repository and stops before setup if the platform, architecture, memory, or free storage is unsuitable.

## Troubleshooting

Check setup progress:

```bash
sudo systemctl status ayvatech-bootstrap.service
sudo tail -n 100 /var/log/ayvatech-home-server-install.log
```

Retry a failed setup:

```bash
sudo systemctl restart ayvatech-bootstrap.service
```

## Security

Do not expose application ports directly to the internet. Use secure remote access such as Tailscale, keep the system updated, and maintain backups of important data.