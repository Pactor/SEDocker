#!/bin/bash
set -e

BASE_DIR="/home/wine"
TORCH_DIR="$BASE_DIR/torch"
PLUGINS_DIR="$TORCH_DIR/Plugins"
CFG_FILE="$TORCH_DIR/Torch.cfg"
TMP_HTML="/tmp/torch_plugins.html"

echo "=== Torch Plugin Selector ==="
mkdir -p "$PLUGINS_DIR"

# --- Preconditions ---
if [ ! -f "$CFG_FILE" ]; then
  echo "❌ Torch.cfg not found — run setup first."
  exit 1
fi
sed -i 's/\r$//' "$CFG_FILE"

# --- Fetch plugin list ---
echo "Fetching plugin list from TorchAPI..."
curl -Ls -A "Mozilla/5.0" -H "Referer: https://torchapi.com" \
  "https://torchapi.com/plugins" -o "$TMP_HTML" || {
  echo "❌ Failed to fetch plugin list."
  exit 1
}

# --- Parse GUIDs and names ---
GUIDS=()
NAMES=()
while IFS= read -r line; do
  guid=$(echo "$line" | sed -n 's/.*href="\/plugins\/view\/\([^"]*\)".*/\1/p')
  name=$(echo "$line" | sed -n 's/.*view\/[^>]*>\([^<]*\)<.*/\1/p')
  [ -n "$guid" ] && [ -n "$name" ] && {
    GUIDS+=("$guid")
    NAMES+=("$name")
  }
done < <(grep "/plugins/view/" "$TMP_HTML")

TOTAL=${#GUIDS[@]}
if [ "$TOTAL" -eq 0 ]; then
  echo "❌ Plugin list empty; parsing failed."
  exit 1
fi
echo "Loaded $TOTAL plugins."

# --- Insert GUID helper ---
insert_guid() {
  local guid="$1"

  # Skip if already present
  if grep -q "<guid>$guid</guid>" "$CFG_FILE"; then
    echo "  ↳ Already in Torch.cfg"
    return
  fi

  # Remove any malformed duplicate headers first
  sed -i '/^<?xml/d' "$CFG_FILE"

  # Normalize Plugins tag
  sed -i 's|<Plugins[[:space:]]*/>|<Plugins>\n  </Plugins>|g' "$CFG_FILE"
  sed -i 's|<Plugins>[[:space:]]*</Plugins>|<Plugins>\n  </Plugins>|g' "$CFG_FILE"

  # Ensure Plugins section exists
  if ! grep -q "<Plugins>" "$CFG_FILE"; then
    sed -i "/<\/TorchConfig>/i \  <Plugins>\n  </Plugins>" "$CFG_FILE"
  fi

  # Insert single GUID right before </Plugins>, only once
  awk -v g="$guid" '
    BEGIN { inserted=0 }
    /<\/Plugins>/ {
      if (inserted==0) {
        print "    <guid>" g "</guid>"
        inserted=1
      }
    }
    { print }
  ' "$CFG_FILE" > "${CFG_FILE}.tmp" && mv "${CFG_FILE}.tmp" "$CFG_FILE"

  echo "  ↳ Added $guid to Torch.cfg"
}

# --- Main loop ---
while true; do
  echo
  read -p "Enter keyword to search (blank=all, q=quit): " FILTER
  [ "$FILTER" = "q" ] && exit 0
  FILTER=$(echo "$FILTER" | tr '[:upper:]' '[:lower:]')

  MATCHED=()
  for i in "${!NAMES[@]}"; do
    lname=$(echo "${NAMES[$i]}" | tr '[:upper:]' '[:lower:]')
    [[ -z "$FILTER" || "$lname" == *"$FILTER"* ]] && MATCHED+=("$i")
  done

  if [ ${#MATCHED[@]} -eq 0 ]; then
    echo "❌ No matches for '$FILTER'."
    continue
  fi

  echo
  echo "Available plugins:"
  for idx in "${MATCHED[@]}"; do
    printf "  [%d] %s\n" "$idx" "${NAMES[$idx]}"
  done
  echo

  read -p "Enter plugin numbers to install (comma-separated): " SELECTION
  IFS=',' read -r -a CHOICES <<< "$SELECTION"

  for idx in "${CHOICES[@]}"; do
    idx=$(echo "$idx" | xargs)
    name="${NAMES[$idx]}"
    guid="${GUIDS[$idx]}"
    [ -z "$guid" ] && continue

    echo "→ Downloading: $name ($guid)"
    ZIP_URL="https://torchapi.com/plugin/download/$guid"
    ZIP_PATH="$PLUGINS_DIR/${name// /_}.zip"

    if curl -L -A "Mozilla/5.0" -H "Referer: https://torchapi.com" --fail -s -o "$ZIP_PATH" "$ZIP_URL"; then
      if [ -s "$ZIP_PATH" ]; then
        echo "✔ Saved $ZIP_PATH"
        chown -R wine:wine "$PLUGINS_DIR"
      else
        echo "❌ Empty file, skipping $name"
        rm -f "$ZIP_PATH"
        continue
      fi
    else
      echo "❌ Failed to download $name"
      rm -f "$ZIP_PATH"
      continue
    fi

    echo "Updating Torch.cfg ..."
    insert_guid "$guid"
  done

  echo "✅ Done. You can search again or type 'q' to quit."
done
