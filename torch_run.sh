#!/bin/bash
set -euo pipefail
BASE="${1:-/home/$(whoami)/torch}"
test -f "$BASE/Torch.Server.exe" || { echo "Torch.Server.exe not found in $BASE"; exit 1; }

WINE_BASE="Z:\\$(echo "$BASE" | sed 's#^/##; s#/#\\#g')"
cd "$BASE"
echo "Starting Torch.Server.exe from ${WINE_BASE}"
env WINEDEBUG=-all wine Torch.Server.exe &
