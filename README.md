# AYVAtech Home Server Installer v2

Built for the **Tech Tips With Adam** old-PC home-server project.

## What it does

- installs and enables OpenSSH Server
- installs Docker Engine from Docker's official Ubuntu repository
- installs Docker Compose
- disables sleep/suspend
- lets you choose which server apps to install
- prints the Windows SSH command and app URLs when finished

## Included apps

- Portainer
- Uptime Kuma
- Jellyfin
- File Browser
- Home Assistant Container

## Run it

```bash
chmod +x install.sh
sudo ./install.sh
```

From Windows Terminal after setup:

```powershell
ssh YOUR-USERNAME@SERVER-IP
```

## Addresses

- Portainer: `https://SERVER-IP:9443`
- Uptime Kuma: `http://SERVER-IP:3001`
- Jellyfin: `http://SERVER-IP:8096`
- File Browser: `http://SERVER-IP:8080`
- Home Assistant: `http://SERVER-IP:8123`

## Important

The script does not force a static IP. For a beginner setup, reserve the server's IP in the home router.

Do not forward these application ports directly to the public internet.

Home Assistant here is **Home Assistant Container**, not Home Assistant OS, so it does not include the HA OS apps/add-ons system.

## Helper commands

```bash
sudo /opt/ayvatech-home-server/status.sh
sudo /opt/ayvatech-home-server/update.sh
```
