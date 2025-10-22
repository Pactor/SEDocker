# 🚀 Space Engineers Dedicated Server with Torch Plugin Support

A fully automated **Docker-based Space Engineers dedicated server** with full **Torch plugin** and **mod support**, running under Wine inside Ubuntu.  
Includes auto-port mapping, plugin selection, mod configuration, and world setup.

---

### 🧱 Image Summary
- **Final Image Size:** ~4.38 GB (with a brand-new world created)

---

## 📦 Required Packages (`packages.txt`)
These are the packages installed during the image build.

| Package | Required | Notes |
|----------|-----------|-------|
| software-properties-common | ❌ | Optional |
| curl | ✅ | Required |
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

> 💡 You can slightly reduce the image size by omitting unneeded optional packages.

---

## ⚙️ Winetricks Setup (`setup_wine.sh`)
```bash
winetricks -q corefonts           # Might be required
winetricks -q sound=disabled
winetricks -q --force vcrun2019   # Required
winetricks -q --force dotnet48    # Required
winetricks -q d3dcompiler_47

# 1️⃣ Clone this repository
git clone https://github.com/Pactor/SEDocker.git
cd SEDocker

# 2️⃣ Install and configure Docker for user access
sudo ./setup_docker_user.sh
# → Log out and back in if prompted

# 3️⃣ Build the Docker image
./build.sh
# (no sudo required once Docker is configured)

# 4️⃣ Configure the server ports
# You’ll be asked for Game, Steam, and RCON ports.
# Defaults: 27016 / 8766 / 8080

# 5️⃣ Enter the container
docker attach torch
# or, if not yet running:
docker start -ai torch

# 6️⃣ Inside the container, create your world
./install_world.sh
# → Choose scenario, mods, plugins (search by partial name like “quan” or “sed”)
# → Optionally start the server immediately

# 7️⃣ Start Torch manually later if desired
/home/wine/scripts/torch_run.sh
