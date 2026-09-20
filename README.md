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

## App Center says “incorrect permissions”

If Ubuntu displays **Authentication Required** followed by an error saying that `polkit-agent-helper-1` needs to be setuid root, Ubuntu's administrator-authentication service has incorrect permissions. This is an Ubuntu PolicyKit problem rather than an AYVAtech installer failure.

Close App Center, open Terminal with **Ctrl + Alt + T**, and run:

```bash
sudo apt update
sudo apt install --reinstall polkitd pkexec policykit-1
sudo systemctl restart polkit
```

Check the repaired helper:

```bash
stat -c '%U %G %a %n' /usr/lib/polkit-1/polkit-agent-helper-1
```

It should report `root root 4755`. If it does not, run:

```bash
sudo chown root:root /usr/lib/polkit-1/polkit-agent-helper-1
sudo chmod 4755 /usr/lib/polkit-1/polkit-agent-helper-1
sudo reboot
```

After restarting, double-click the AYVAtech `.deb` file again.