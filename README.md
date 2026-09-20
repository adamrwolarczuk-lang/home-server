# AYVAtech Home Server

> **Current development release:** [v3.0.0 Beta 6](https://github.com/adamrwolarczuk-lang/home-server/releases/tag/v3.0.0-beta.6)  
> **Earlier stable release:** [v2.1.0](https://github.com/adamrwolarczuk-lang/home-server/releases/tag/v2.1.0)


Turn an old Ubuntu, Zorin OS or compatible Debian-family computer into a home server with a guided installer and a live local dashboard at `http://homeserver.local`.

## Download Beta 6

**[Download AYVAtech Home Server v3.0.0 Beta 6](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v3.0.0-beta.6/AYVAtech-Home-Server-Installer-3.0.0-beta.6.deb)**

Beta software is for testing on a spare computer. Keep important data backed up.

After package installation, open the Zorin/Ubuntu application menu and search for **AYVAtech Home Server Installer**. You can also start it from Terminal with `ayvatech-home-server-installer`.

## What Beta 6 installs

- Distribution and hardware compatibility checks
- Docker Engine and Docker Compose
- SSH remote access
- Always-on server settings
- `homeserver.local` local network naming
- Live AYVAtech dashboard
- CPU, memory, storage, temperature, uptime and service status
- A searchable, categorized 22-application catalogue
- Plain-English guidance for every application

Beta 6 installs the server foundation and dashboard. The application catalogue is visible and documented, but the expanded optional applications are not all installable from the dashboard yet. That app-management workflow is the next v3 phase.

## Application catalogue

### Core

- **Docker** — runs server applications in isolated containers.
- **SSH** — manages the server remotely from another computer.
- **Always-on mode** — prevents sleep and suspend.
- **AYVAtech Dashboard** — the everyday home screen at `homeserver.local`.

### Management

- **Portainer** — advanced visual Docker management.
- **Uptime Kuma** — device and website availability monitoring.
- **Beszel** — lightweight CPU, memory, disk, temperature and container monitoring.

### Storage and backup

- **File Browser** — browser-based file management.
- **Samba** — Windows network shares available through `\\homeserver`.
- **Syncthing** — direct folder synchronisation between trusted devices.
- **Nextcloud** — private files, calendars, contacts and sharing.
- **Duplicati** — scheduled encrypted backups.

### Media

- **Jellyfin** — personal movie, television and music streaming.
- **Navidrome** — personal music streaming.
- **Audiobookshelf** — audiobooks, podcasts and listening progress.

### Photos and documents

- **Immich** — automatic phone photo and video backup.
- **Paperless-ngx** — searchable scanned-document archive.

### Home and network

- **Home Assistant** — local smart-home control and automation.
- **AdGuard Home** — network-wide advertising and tracker filtering.

### Security and remote access

- **Tailscale** — encrypted remote access without forwarding application ports.
- **Vaultwarden** — Bitwarden-compatible family password vault.

### Other useful tools

- **FreshRSS** — private RSS news reader.
- **Actual Budget** — private envelope-style household budgeting.
- **Mealie** — recipes, meal planning and shopping lists.
- **Minecraft Server** — a private game world for friends and family.

## Install on Zorin when Software authentication fails

If Zorin Software reports incorrect permissions for `polkit-agent-helper-1`, install Beta 6 from Terminal instead:

```bash
cd ~/Downloads
sudo apt install ./AYVAtech-Home-Server-Installer-3.0.0-beta.6.deb
```

Beta 6 uses terminal `sudo` authentication after package installation and does not depend on PolicyKit for the AYVAtech setup.

## Supported systems

The preflight detects Ubuntu, Zorin OS, Linux Mint, Pop!_OS, elementary OS, Debian and compatible Ubuntu/Debian derivatives. It determines the correct Docker repository and stops before making changes when the platform, architecture, RAM or free storage is unsuitable.

## After installation

Open:

```text
http://homeserver.local
```

The dashboard shows what is installed, whether it is running, how to open it and how to start using it.

## Security

Do not forward application ports directly to the internet. Use a secure remote-access tool such as Tailscale, keep the system updated and maintain backups of important application data.
