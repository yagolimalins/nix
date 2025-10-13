#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <host>"
  exit 1
fi

HOST=$1
DIR=hosts/$HOST

mkdir -p "$DIR"

sudo nixos-generate-config

sudo cp -f /etc/nixos/hardware-configuration.nix "$DIR/hardware-configuration.nix"
sudo chown -R "yago:users" "hosts"

echo "✅ Hardware configuration for '$HOST' updated in $DIR/hardware-configuration.nix"
