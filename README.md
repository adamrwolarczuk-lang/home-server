# AYVAtech Home Server

Turn an old Ubuntu, Zorin OS, or compatible Debian-family computer into a home server. Installing the `.deb` automatically starts the full server setup; there is no second installer command to remember.

## Download Beta 8

**[Download AYVAtech Home Server v3.0.0 Beta 8](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.8/AYVAtech-Home-Server-Installer-3.0.0-beta.8.deb)**

Beta software is for testing on a spare computer. Back up important data first.

## Install on Zorin OS or Ubuntu

1. Download Beta 8 using the link above.
2. Open Terminal and run:

```bash
cd ~/Downloads
sudo apt update
sudo apt install ./AYVAtech-Home-Server-Installer-3.0.0-beta.8.deb
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
- Adds a searchable 23-application catalogue with plain-English guidance

The automatic setup log is saved at `/var/log/ayvatech-home-server-install.log`.

## Optional Living Room Mode

Beta 8 adds an optional television setup without duplicating Jellyfin with Kodi. After the main setup finishes, open **AYVAtech Living Room Mode Setup** from the application menu.

It asks before installing anything, then installs:

- **Jellyfin Server** for organising and streaming personal media
- **Jellyfin Desktop** for a controller-friendly television interface
- **VLC** for physical DVD playback
- An optional sign-in startup entry for Jellyfin Desktop

First open `http://homeserver.local:8096` to create the Jellyfin owner account and media libraries. Then open Jellyfin Desktop and connect it to the same address. Jellyfin TV mode supports compatible controllers, media remotes, and control through Jellyfin mobile applications.

Some encrypted commercial DVDs may need additional decoding support depending on local law. AYVAtech does not install that component automatically.

## After installation

On the server or another device on the same network, open:

```text
http://homeserver.local
```

If local-name discovery is unavailable on a device, the status screen and install log also show the server's IP address.

Beta 8 installs the server foundation and dashboard automatically. Living Room Mode is now installable from the application menu. The other expanded optional applications are shown and explained in the catalogue but are not all one-click installable yet.

## Application catalogue

- **Core:** Docker, SSH, Always-on mode, AYVAtech Dashboard
- **Management:** Portainer, Uptime Kuma, Beszel
- **Storage and backup:** File Browser, Samba, Syncthing, Nextcloud, Duplicati
- **Media:** Jellyfin, Living Room Mode, Navidrome, Audiobookshelf
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

Check Living Room Mode:

```bash
docker ps --filter name=ayvatech-jellyfin
flatpak info --system org.jellyfin.JellyfinDesktop
```

## Security

Do not expose application ports directly to the internet. Use secure remote access such as Tailscale, keep the system updated, and maintain backups of important data.
