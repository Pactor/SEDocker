#!/bin/bash
set -e

BASE_DIR="/home/wine"
TORCH_DIR="$BASE_DIR/torch"
INSTANCE_DIR="$TORCH_DIR/Instance"
CFG_FILE="$INSTANCE_DIR/SpaceEngineers-Dedicated.cfg"
ENV_FILE="/home/wine/scripts/torch_ports.env"

# --- Load saved ports ---
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "⚠️ Port config not found at $ENV_FILE — using defaults."
  GAME_PORT=27016
  STEAM_PORT=8766
  RCON_PORT=8080
fi

# ensure config dir exists
mkdir -p "$INSTANCE_DIR"

echo "=== Space Engineers Configuration ==="

# Backup existing config
cp "$CFG_FILE" "${CFG_FILE}.bak"

# Helper: update or insert tag
update_tag() {
    local tag="$1"
    local value="$2"
    if grep -q "<$tag>" "$CFG_FILE"; then
        sed -i "s|<$tag>.*</$tag>|<$tag>$value</$tag>|" "$CFG_FILE"
    else
        sed -i "/<\/MyConfigDedicated>/i \  <$tag>$value</$tag>" "$CFG_FILE"
    fi
}

# Helper: prompt with default
ask() {
    local prompt="$1"
    local def="$2"
    read -p "$prompt [$def]: " val
    echo "${val:-$def}"
}

echo
echo "=== Configure Game Settings ==="
echo "Press Enter to keep default values."

GAME_MODE=$(ask "Game mode (Creative/Survival)" "Survival")
INV_MULTI=$(ask "Inventory size multiplier (1-100)" "3")
BLK_INV_MULTI=$(ask "Blocks inventory size multiplier (1-100)" "1")
ASM_SPEED=$(ask "Assembler speed multiplier (1-100)" "3")
ASM_EFF=$(ask "Assembler efficiency multiplier (1-100)" "3")
REF_SPEED=$(ask "Refinery speed multiplier (1-100)" "3")
ONLINE_MODE=$(ask "Online mode (OFFLINE/PUBLIC/FRIENDS/PRIVATE)" "PUBLIC")
MAX_PLAYERS=$(ask "Max players" "4")
WELDER_SPEED=$(ask "Welder speed multiplier (1-100)" "2")
GRINDER_SPEED=$(ask "Grinder speed multiplier (1-100)" "2")

ENABLE_O2=$(ask "Enable oxygen (true/false)" "true")
ENABLE_PRESS=$(ask "Enable oxygen pressurization (true/false)" "true")
ENABLE_DRONES=$(ask "Enable drones (true/false)" "true")
ENABLE_WOLFS=$(ask "Enable wolfs (true/false)" "false")
ENABLE_SPIDERS=$(ask "Enable spiders (true/false)" "false")

EXPERIMENTAL=$(ask "Enable experimental mode (true/false)" "false")
CROSSPLATFORM=$(ask "Enable cross-platform (true/false)" "false")
IP_ADDR=$(ask "Server IP (0.0.0.0 for all)" "0.0.0.0")

REMOTE_API=$(ask "Enable remote API (true/false)" "true")
FOOD_RATE=$(ask "Food consumption rate (0.1–1.0)" "0.5")

# --- Apply updates ---
update_tag "GameMode" "$GAME_MODE"
update_tag "InventorySizeMultiplier" "$INV_MULTI"
update_tag "BlocksInventorySizeMultiplier" "$BLK_INV_MULTI"
update_tag "AssemblerSpeedMultiplier" "$ASM_SPEED"
update_tag "AssemblerEfficiencyMultiplier" "$ASM_EFF"
update_tag "RefinerySpeedMultiplier" "$REF_SPEED"
update_tag "OnlineMode" "$ONLINE_MODE"
update_tag "MaxPlayers" "$MAX_PLAYERS"
update_tag "WelderSpeedMultiplier" "$WELDER_SPEED"
update_tag "GrinderSpeedMultiplier" "$GRINDER_SPEED"
update_tag "EnableOxygen" "$ENABLE_O2"
update_tag "EnableOxygenPressurization" "$ENABLE_PRESS"
update_tag "EnableDrones" "$ENABLE_DRONES"
update_tag "EnableWolfs" "$ENABLE_WOLFS"
update_tag "EnableSpiders" "$ENABLE_SPIDERS"
update_tag "ExperimentalMode" "$EXPERIMENTAL"
update_tag "CrossPlatform" "$CROSSPLATFORM"
update_tag "IP" "$IP_ADDR"
update_tag "SteamPort" "$STEAM_PORT"
update_tag "ServerPort" "$GAME_PORT"
update_tag "RemoteApiEnabled" "$REMOTE_API"
update_tag "RemoteApiPort" "$RCON_PORT"
update_tag "FoodConsumptionRate" "$FOOD_RATE"
update_tag "NetworkType" "steam"
update_tag "ConsoleCompatibility" "false"

echo
echo "✅ Configuration complete!"
echo "Your settings have been written to:"
echo "  $CFG_FILE"
echo "A backup was saved as:"
echo "  ${CFG_FILE}.bak"
