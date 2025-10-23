# 🚀 Space Engineers Dedicated Server with Torch Plugin Support
A fully automated Docker-based **Space Engineers dedicated server** featuring full **Torch plugin** and **mod support**, running under Wine inside Ubuntu. Includes automatic port configuration, plugin selection, mod setup, and world configuration scripts.

---

## 🧱 Image Summary
- Base OS: Ubuntu (headless)
- Server Manager: Torch
- Final Image Size: ~4.4 GB (with a new world created)
- Features: Plugin and mod support, auto-port mapping, configuration tools

---

## 📦 Installed Packages
| Package | Required | Notes |
|----------|-----------|-------|
| software-properties-common | ❌ | Optional helper for repos |
| curl | ✅ | Required for downloads |
| gnupg2 | ✅ | For secure repo setup |
| wget | ✅ | Required |
| net-tools | ✅ | Useful for debugging |
| winbind | ✅ | Recommended |
| cabextract | ✅ | Required by Winetricks |
| unzip | ✅ | Required |
| zip | ✅ | Optional |
| xvfb | ✅ | Required (for headless Wine) |
| sudo | ✅ | Required |
| nano | ❌ | Optional |
| wine64 | ✅ | Required |
| wine32 | ✅ | Recommended |
| winetricks | ✅ | Required |
> 💡 Optional packages can be removed to slightly reduce image size.

---

## ⚙️ Setup
Clone this repository:  
`git clone https://github.com/Pactor/SEDocker.git`  
`cd SEDocker`

Install and configure Docker for user access:  
`sudo ./setup_docker_user.sh`  
(Log out and back in if prompted.)

Build the Docker image:  
`./build.sh`

Configure the server ports (you’ll be asked for Game, Steam, and RCON ports):  
Defaults → 27016 / 8766 / 8080

Enter the container:  
`docker attach torch`  
or, if not yet running:  
`docker start -ai torch`

Inside the container, create your world:  
`./install_world.sh`  
You’ll be prompted to choose a scenario, mods, and plugins (search by partial name such as “quan” or “sed”). After setup, you’ll be asked whether to configure the world now or later.

To adjust gameplay and world settings later:  
`./configure_game.sh`

---

Backups are automatically created before configuration changes. This image supports Torch plugins, Steam Workshop mods, and headless server operation — ideal for dedicated Linux hosts.

