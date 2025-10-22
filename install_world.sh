#!/bin/bash
set -euo pipefail

BASE_DIR="/home/wine"
TORCH_DIR="${BASE_DIR}/torch"
INSTANCE_DIR="${TORCH_DIR}/Instance"
CFG_FILE="${TORCH_DIR}/Torch.cfg"
DEDICATED_CFG="${INSTANCE_DIR}/SpaceEngineers-Dedicated.cfg"
TORCH_EXE="${TORCH_DIR}/Torch.Server.exe"
TORCH_LOG="${TORCH_DIR}/Torch.log"
ENV_FILE="/home/wine/scripts/torch_ports.env"

echo
echo "=============================================="
echo "  🌍 Torch World Installer & Verifier"
echo "=============================================="

# --- Fix env file permissions (ignore if sudo not allowed) ---
if [ -f "$ENV_FILE" ]; then
  echo "Fixing env file permissions..."
  (chown wine:wine "$ENV_FILE" 2>/dev/null || chown wine:wine "$ENV_FILE" 2>/dev/null || true)
  source "$ENV_FILE"
else
  echo "❌ Missing $ENV_FILE. Run setup_ports.sh and init_docker.sh on host first."
  exit 1
fi

# --- Check Torch base setup ---
if [ ! -f "$CFG_FILE" ] || [ ! -d "$TORCH_DIR/DedicatedServer64" ]; then
  echo "⚠️ Torch or server files missing — running setup_server.sh..."
  bash /home/wine/scripts/setup_server.sh
fi

# --- If Torch exists but Dedicated.cfg missing, initialize Torch once ---
if [ -f "$CFG_FILE" ] && [ ! -f "$DEDICATED_CFG" ]; then
  echo "⚙️ SpaceEngineers-Dedicated.cfg not found — starting Torch.Server.exe to generate it..."
  cd "$TORCH_DIR"
  xvfb-run --auto-servernum env WINEDEBUG=-all wine "$TORCH_EXE" >> "$TORCH_LOG" 2>&1 &
  PID=$!

  echo "⏳ Waiting for Torch to finish initialization..."
  for i in {1..120}; do
    if grep -q "Torch: Starting server" "$TORCH_LOG" 2>/dev/null; then
      echo "✅ Dedicated config created successfully."
      break
    fi
    sleep 3
  done

  kill $PID 2>/dev/null || true
  sleep 5
fi

# --- Verify everything is ready ---
if [ ! -f "$CFG_FILE" ] || [ ! -f "$DEDICATED_CFG" ]; then
  echo "❌ Required configuration files are still missing."
  echo "Check Torch.log for details: $TORCH_LOG"
  exit 1
fi

echo
echo "✅ Torch and SE server verified."
echo "Torch.cfg : $CFG_FILE"
echo "Dedicated : $DEDICATED_CFG"
echo

# === Continue with your normal world setup ===
read -p "Create a new game world? (y/n): " CREATE_WORLD
if [[ "$CREATE_WORLD" =~ ^[Yy]$ ]]; then
  bash /home/wine/scripts/select_scenario.sh
  bash /home/wine/scripts/configure_game.sh
fi

read -p "Add mods now? (y/n): " ADD_MODS
if [[ "$ADD_MODS" =~ ^[Yy]$ ]]; then
  bash /home/wine/scripts/setup_mods.sh
fi

read -p "Add plugins now? (y/n): " ADD_PLUGINS
if [[ "$ADD_PLUGINS" =~ ^[Yy]$ ]]; then
  bash /home/wine/scripts/select_plugins.sh
fi

read -p "Start Torch server now? (y/n): " START_NOW
if [[ "$START_NOW" =~ ^[Yy]$ ]]; then
  bash /home/wine/scripts/torch_run.sh
else
  echo
  echo "⚙️ Setup complete. Start later with:"
  echo "   bash /home/wine/scripts/torch_run.sh"
fi
