#!/usr/bin/env bash
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[38;5;160m'; BRED='\033[1;38;5;160m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${RED}▶${RESET} $*"; }
success() { echo -e "${GREEN}✔${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
die()     { echo -e "${BRED}✘${RESET} $*" >&2; exit 1; }

step() {
    echo ""
    echo -e "${BRED}────────────────────────────────────────${RESET}"
    echo -e "${BOLD}  $*${RESET}"
    echo -e "${BRED}────────────────────────────────────────${RESET}"
}

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BRED}  ❄  NixOS Multi-Host Installer${RESET}"
echo -e "  Configure and apply a NixOS host from this flake."
echo ""

# ── Sanity check ──────────────────────────────────────────────────────────────
[[ -f flake.nix ]] || die "Run this script from the root of the nix configuration repository."

OWNER_USER="${SUDO_USER:-$USER}"
OWNER_GROUP="$(id -gn "$OWNER_USER")"

# ── Host selection ────────────────────────────────────────────────────────────
SYSTEMS_DIR="systems/x86_64-linux"
DETECTED="$(hostname -s)"
AVAILABLE="$(ls "$SYSTEMS_DIR/" | tr '\n' ' ')"
info "Available hosts: ${BOLD}${AVAILABLE}${RESET}"
echo -en "${BOLD}Host name to configure [${DETECTED}]: ${RESET}"
read -r HOST
HOST="${HOST:-$DETECTED}"

# ── Step 1: Hardware configuration ───────────────────────────────────────────
step "Step 1 — Generate Hardware Configuration"

HOST_DIR="$SYSTEMS_DIR/$HOST"
HW_FILE="$HOST_DIR/hardware-configuration.nix"
DEFAULT_FILE="$HOST_DIR/default.nix"

mkdir -p "$HOST_DIR"

if [[ -f "$HW_FILE" ]]; then
    warn "Hardware configuration already exists for '${HOST}'."
    echo -en "${BOLD}Overwrite it? [y/N] ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]] || die "Aborted."
else
    info "Detecting hardware for '${HOST}'..."
fi

sudo nixos-generate-config
sudo cp -f /etc/nixos/hardware-configuration.nix "$HW_FILE"
sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$SYSTEMS_DIR"
git add "$HW_FILE"
success "Hardware configuration written to ${HW_FILE}."

# Snowfall Lib needs a default.nix per system — scaffold a minimal one
# the first time a host is configured; safe to edit/extend afterwards.
if [[ ! -f "$DEFAULT_FILE" ]]; then
    cat > "$DEFAULT_FILE" <<EOF
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "$HOST";

  # Shared NixOS modules come from systems/common.nix (wired via
  # systems.modules.nixos in flake.nix). Add host-specific imports or
  # extra mine = lib.mine.enable-modules [ ... ] here if needed.
}
EOF
    git add "$DEFAULT_FILE"
    success "Created ${DEFAULT_FILE}."
fi

# ── Step 2: Home Manager user ─────────────────────────────────────────────────
step "Step 2 — Scaffold Home Manager User"

HOMES_DIR="homes/x86_64-linux"
USER_DIR="$HOMES_DIR/$OWNER_USER"
HOME_DEFAULT="$USER_DIR/default.nix"

info "Installing as user: ${BOLD}${OWNER_USER}${RESET}"

if [[ -f "$HOME_DEFAULT" ]]; then
    success "Home already exists at ${HOME_DEFAULT}."
else
    mkdir -p "$USER_DIR"
    cat > "$HOME_DEFAULT" <<EOF
{ ... }:

{
  # Shared home modules and XDG basics come from homes/common.nix
  # (wired via homes.modules in flake.nix). The username is inferred
  # from this directory's name. Add user-specific settings or
  # mine = lib.mine.enable-modules [ ... ] here if needed.
}
EOF
    sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$HOMES_DIR"
    git add "$HOME_DEFAULT"
    success "Created ${HOME_DEFAULT}."
fi

# ── Step 3: Enable flakes ─────────────────────────────────────────────────────
step "Step 3 — Enable Flakes"

CONFIG_FILE="$HOME/.config/nix/nix.conf"
FLAKES_LINE="experimental-features = nix-command flakes"

if grep -Fxq "$FLAKES_LINE" "$CONFIG_FILE" 2>/dev/null; then
    success "Flakes already enabled in ${CONFIG_FILE}."
else
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "$FLAKES_LINE" >> "$CONFIG_FILE"
    success "Flakes enabled in ${CONFIG_FILE}."
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

# ── Step 4: Enable git hooks ──────────────────────────────────────────────────
step "Step 4 — Enable Git Hooks"

# core.hooksPath is per-clone (not committed), so new machines need this once.
# Points git at the tracked .githooks/ pre-commit that runs `nix fmt`.
HOOKS_PATH=".githooks"
if [[ "$(git config --get core.hooksPath 2>/dev/null || true)" == "$HOOKS_PATH" ]]; then
    success "Git hooks already enabled (core.hooksPath=${HOOKS_PATH})."
else
    git config core.hooksPath "$HOOKS_PATH"
    success "Git hooks enabled (core.hooksPath=${HOOKS_PATH})."
fi

# ── Step 5: Apply system configuration ───────────────────────────────────────
step "Step 5 — Apply System Configuration"

info "Running: sudo nixos-rebuild switch --flake .#${HOST}"
sudo nixos-rebuild switch --flake ".#${HOST}"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
success "All done! Welcome to your new NixOS system."
echo ""
