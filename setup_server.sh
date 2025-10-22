#!/bin/bash
set -euo pipefail

BASE_DIR="/home/wine"
TORCH_ZIP="${BASE_DIR}/torch.zip"
TORCH_DIR="${BASE_DIR}/torch"
STEAMCMD_DIR="${BASE_DIR}/steamcmd"
SERVER_ID="298740"  # Space Engineers Dedicated Server App ID
TORCH_URL="https://build.torchapi.com/job/Torch/job/master/lastSuccessfulBuild/artifact/bin/torch-server.zip"

echo "🔧 Starting Torch + Space Engineers setup..."

# 1️⃣ Ensure directories exist
mkdir -p "$TORCH_DIR" "$STEAMCMD_DIR"
cd "$BASE_DIR"

# 2️⃣ Download latest Torch.zip if missing
if [ ! -f "$TORCH_ZIP" ]; then
  echo "⬇️ Downloading latest Torch build..."
  wget -O "$TORCH_ZIP" "$TORCH_URL"
else
  echo "📦 Torch.zip already exists, skipping download."
fi

# 3️⃣ Extract Torch.zip
echo "📦 Extracting Torch.zip..."
unzip -oq "$TORCH_ZIP" -d "$TORCH_DIR"
chown -R wine:wine "$TORCH_DIR"

# 4️⃣ Install SteamCMD if missing
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
  echo "⬇️ Installing SteamCMD..."
  mkdir -p "$STEAMCMD_DIR"
  cd "$STEAMCMD_DIR"
  wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz
fi

# 5️⃣ Install or update Space Engineers Dedicated Server
echo "🚀 Installing / Updating Space Engineers Dedicated Server via SteamCMD..."
cd "$STEAMCMD_DIR"
xvfb-run --auto-servernum ./steamcmd.sh +@sSteamCmdForcePlatformType windows \
  +force_install_dir "${TORCH_DIR}" \
  +login anonymous \
  +app_update ${SERVER_ID} validate +quit


# 6️⃣ Run Torch.Server.exe once to initialize configuration
echo "🧩 Running Torch.Server.exe to generate Torch.cfg and SpaceEngineers-Dedicated.cfg..."

cd "$TORCH_DIR"
xvfb-run --auto-servernum env WINEDEBUG=-all wine Torch.Server.exe >> Torch.log 2>&1 &
PID=$!

echo "⏳ Waiting for Torch to fully initialize and write config files..."
CFG_READY=0

for i in {1..180}; do
  TORCH_CFG_OK=false
  DEDICATED_CFG_OK=false

  [[ -f "$TORCH_DIR/Torch.cfg" ]] && TORCH_CFG_OK=true
  [[ -f "$TORCH_DIR/Instance/SpaceEngineers-Dedicated.cfg" ]] && DEDICATED_CFG_OK=true

  if $TORCH_CFG_OK && $DEDICATED_CFG_OK; then
    CFG_READY=1
    echo "✅ Torch.cfg and SpaceEngineers-Dedicated.cfg detected."
    break
  fi

  if grep -q "Exception" "$TORCH_DIR/Torch.log" 2>/dev/null; then
    echo "⚠️  Detected error in Torch.log — aborting early."
    break
  fi

  sleep 3
done

# Ensure process cleanup
kill $PID 2>/dev/null || true
sleep 5

if [ "$CFG_READY" -eq 0 ]; then
  echo "❌ Config files not created after waiting 9 minutes."
  echo "Check Torch.log for startup errors."
  exit 1
fi

CFG_PATH="${TORCH_DIR}/Torch.cfg"
if [ -f "$CFG_PATH" ]; then
  echo "🔧 Fixing Torch.cfg for headless mode..."
  sed -i -E \
    -e 's|<NoGui>false</NoGui>|<NoGui>true</NoGui>|g' \
    -e 's|<GetTorchUpdates>true</GetTorchUpdates>|<GetTorchUpdates>false</GetTorchUpdates>|g' \
    -e 's|<LocalPlugins>false</LocalPlugins>|<LocalPlugins>true</LocalPlugins>|g' \
    "$CFG_PATH"
else
  echo "⚠️ Torch.cfg still missing — check Torch.log for details."
fi

echo "✅ Setup complete."
echo "Torch directory: $TORCH_DIR"
echo "Space Engineers server: ${TORCH_DIR}/DedicatedServer64"
