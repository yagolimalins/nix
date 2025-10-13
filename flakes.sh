#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/nix"
CONFIG_FILE="$CONFIG_DIR/nix.conf"
LINE="experimental-features = nix-command flakes"

mkdir -p "$CONFIG_DIR"

if grep -Fxq "$LINE" "$CONFIG_FILE" 2>/dev/null; then
  echo "✅ Flakes are already enabled in $CONFIG_FILE"
else
  echo "$LINE" >> "$CONFIG_FILE"
  echo "✨ Enabled flakes for user $USER in $CONFIG_FILE"
fi

echo
echo "➡️  Restart your shell or run 'exec \$SHELL' to apply the change."
