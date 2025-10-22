#!/bin/bash
set -e

USERDIR="/home/wine"
TORCHDIR="$USERDIR/torch"
SAVEDIR="$TORCHDIR/Instance/Saves"

clear
echo "────────────────────────────────────────────"
echo "   🚀 Torch Server Environment Loaded"
echo "────────────────────────────────────────────"
echo "Working directory: $USERDIR"
echo "Torch directory:   $TORCHDIR"
echo

if [ ! -d "$SAVEDIR" ] || [ -z "$(ls -A "$SAVEDIR" 2>/dev/null)" ]; then
    echo "⚠️  No worlds detected in:"
    echo "   $SAVEDIR"
    echo
    echo "You can always changes settings"
    echo "   the scripts directory contains the tools you need"
    echo "   install_world.sh will run them all "
    echo "   select_senario.sh  "
    echo "   configure_game.sh "
    echo "   setup_mods.sh "
    echo "   select_plugins.sh"
    echo "   torch_run.sh"
    echo " "
    echo
else
    echo "✅ Torch Instance found at $SAVEDIR"
    echo "You can start Torch now using:"
    echo "/home/$(whoami)/scripts/torch_run.sh"
    echo "You can always changes settings"
    echo "   the scripts directory contains the tools you need"
    echo "   install_world.sh will run them all "
    echo "   select_senario.sh  "
    echo "   configure_game.sh "
    echo "   setup_mods.sh "
    echo "   select_plugins.sh"
    echo "   torch_run.sh"
    echo " "

fi

echo "────────────────────────────────────────────"
