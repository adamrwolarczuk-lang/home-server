# AYVAtech Home Server Installer

Turn an old PC into an easy-to-manage Ubuntu home server.

This guided installer sets up the essential server tools, explains what each component is for, and lets you choose the apps you want from a simple graphical screen. No Docker knowledge is required.

## Download

**[Download AYVAtech Home Server Installer v2.1.0](https://github.com/adamrwolarczuk-lang/home-server/releases/download/v2.1.0/AYVAtech-Home-Server-Installer-2.1.0.deb)**

This installer is intended for **Ubuntu Desktop**. Use a freshly installed, supported Ubuntu release and make sure the computer has an internet connection.

## How to install

1. Download the `.deb` file using the button above.
2. Open your **Downloads** folder.
3. Double-click `AYVAtech-Home-Server-Installer-2.1.0.deb`.
4. When Ubuntu App Center opens, select **Install**.
5. Enter your Ubuntu password if requested.
6. Open the applications menu and launch **AYVAtech Home Server Installer**.
7. Read the app descriptions, choose what you want, and select **Install now**.
8. Keep the installer open while it downloads and configures everything.
9. Save the server IP address and web addresses shown on the completion screen.

Installation normally takes around 10–30 minutes, depending on the computer and internet connection.

> If double-clicking the file does not open App Center, right-click it, choose **Open With**, and select **App Center**.

## What the installer configures

- **SSH** — manage the server remotely from another computer.
- **Docker Engine** — run each server application in its own clean container.
- **Docker Compose** — manage all selected applications together.
- **Always-on mode** — prevent sleep and suspend so the server stays available.
- **Status and update tools** — check and update the server with simple commands.

## Available applications

| Application | What it is used for | Address after installation |
|---|---|---|
| Portainer | Friendly Docker control panel | `https://SERVER-IP:9443` |
| Uptime Kuma | Device and website availability monitoring | `http://SERVER-IP:3001` |
| Jellyfin | Personal movie, TV and music streaming | `http://SERVER-IP:8096` |
| File Browser | Browser-based server file management | `http://SERVER-IP:8080` |
| Home Assistant Container | Smart-home control and automation | `http://SERVER-IP:8123` |

The recommended starter selection is Portainer, Uptime Kuma, Jellyfin, and File Browser.

## After installation

Connect from another computer:

```text
ssh YOUR-UBUNTU-USERNAME@SERVER-IP
```

Check server status:

```bash
sudo /opt/ayvatech-home-server/status.sh
```

Update Ubuntu and the server applications:

```bash
sudo /opt/ayvatech-home-server/update.sh
```

## Important safety information

- Do **not** forward these application ports directly to the public internet.
- Reserve the server IP address in your router so its web addresses do not change.
- Keep Ubuntu and the installed applications updated.
- This installs **Home Assistant Container**, not Home Assistant OS, so it does not include the Home Assistant OS add-ons system.

## Troubleshooting

A detailed installation log is saved at:

```text
/var/log/ayvatech-home-server-install.log
```

When asking for help, include your Ubuntu version, the installation stage that failed, and the relevant error from this log.

## Verify the download

SHA-256 for version 2.1.0:

```text
218e880c3735309e13fc8c7016d0369667f7e55ad8d71be78149c3b366138815
```