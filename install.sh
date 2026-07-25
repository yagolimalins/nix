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

# Flakes only see tracked/staged files — stage safely when inside a git repo.
git_stage() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git add "$@"
    else
        warn "Not a git repository — skipped staging: $*"
        warn "Flakes ignore untracked files; initialise git or copy files into a clone before rebuild."
    fi
}

# True when the host file actively disables Lanzaboote (uncommented assignment).
host_disables_secure_boot() {
    grep -Eq '^[[:space:]]*(\$\{namespace\}|mine)\.boot\.secureBoot[[:space:]]*=[[:space:]]*false[[:space:]]*;' "$1"
}

# Ensure the host opts out of Secure Boot so rebuild can proceed without keys.
ensure_host_disables_secure_boot() {
    local file="$1"
    if host_disables_secure_boot "$file"; then
        success "Host already sets secureBoot = false (${file})."
        return 0
    fi

    if grep -Eq '^[[:space:]]*#[[:space:]]*\$\{namespace\}\.boot\.secureBoot[[:space:]]*=[[:space:]]*false' "$file"; then
        sed -i -E 's/^([[:space:]]*)#[[:space:]]*(\$\{namespace\}\.boot\.secureBoot[[:space:]]*=[[:space:]]*false;.*)/\1\2/' "$file"
    else
        local tmp
        tmp="$(mktemp)"
        awk '
            BEGIN { inserted = 0 }
            {
                if (!inserted && $0 ~ /^}/) {
                    print "  ${namespace}.boot.secureBoot = false;"
                    inserted = 1
                }
                print
            }
            END { if (!inserted) exit 1 }
        ' "$file" >"$tmp" || die "Could not insert secureBoot = false into ${file}."
        mv "$tmp" "$file"
    fi

    host_disables_secure_boot "$file" || die "Failed to set secureBoot = false in ${file}."
    git_stage "$file"
    success "Set \${namespace}.boot.secureBoot = false in ${file}."
}

# Run sbctl from a nix shell so this works on minimal installs before the
# flake's system profile (which ships pkgs.sbctl) is applied.
sbctl() {
    nix-shell -p sbctl --run "sudo sbctl $*"
}

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BRED}  ❄  NixOS Multi-Host Installer${RESET}"
echo -e "  Configure and apply a NixOS host from this flake."
echo ""

# ── Sanity check ──────────────────────────────────────────────────────────────
[[ -f flake.nix ]] || die "Run this script from the root of the nix configuration repository."

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    warn "Prefer running without sudo; this script elevates only where needed."
fi

OWNER_USER="${SUDO_USER:-$USER}"
OWNER_GROUP="$(id -gn "$OWNER_USER")"
OWNER_HOME="$(getent passwd "$OWNER_USER" | cut -d: -f6)"
[[ -n "$OWNER_HOME" && -d "$OWNER_HOME" ]] || die "Cannot resolve home directory for '${OWNER_USER}'."

# ── Host selection ────────────────────────────────────────────────────────────
SYSTEMS_DIR="systems/x86_64-linux"
DETECTED="$(hostname -s)"
AVAILABLE="$(ls "$SYSTEMS_DIR/" | tr '\n' ' ')"
info "Available hosts: ${BOLD}${AVAILABLE}${RESET}"
info "Flake attribute = directory name under ${SYSTEMS_DIR}/ (not necessarily the live hostname)."
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
git_stage "$HW_FILE"
success "Hardware configuration written to ${HW_FILE}."

# Snowfall Lib needs a default.nix per system — scaffold a minimal one
# the first time a host is configured; safe to edit/extend afterwards.
if [[ ! -f "$DEFAULT_FILE" ]]; then
    cat > "$DEFAULT_FILE" <<EOF
{ lib, namespace, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "$HOST";

  # Shared NixOS modules come from systems/common.nix (wired via
  # systems.modules.nixos in flake.nix). Add host-specific imports or
  # extra mine = lib.mine.enable-modules [ ... ] here if needed.
  #
  # Optional Hyprland layout facts (see modules/nixos/host + lib/):
  # \${namespace}.host = lib.\${namespace}.mkDualMonitorHost "HDMI-A-1";
  #
  # VMs / machines without Secure Boot:
  # \${namespace}.boot.secureBoot = false;
}
EOF
    git_stage "$DEFAULT_FILE"
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
  # from this directory's name.
  #
  # Optional overrides, e.g.:
  # mine.packages.creator.enable = false;
  # mine.user.wallpaper = ./wall.png;
}
EOF
    sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$HOMES_DIR"
    git_stage "$HOME_DEFAULT"
    success "Created ${HOME_DEFAULT}."
fi

# Stage the whole host/home dirs so flakes can see every new file.
git_stage "$HOST_DIR" "$USER_DIR"

# ── Step 3: Enable flakes ─────────────────────────────────────────────────────
step "Step 3 — Enable Flakes"

# Always target the installing user's home (not root's $HOME if run via sudo).
CONFIG_DIR="${OWNER_HOME}/.config/nix"
CONFIG_FILE="${CONFIG_DIR}/nix.conf"
FLAKES_LINE="experimental-features = nix-command flakes"

if grep -Fxq "$FLAKES_LINE" "$CONFIG_FILE" 2>/dev/null; then
    success "Flakes already enabled in ${CONFIG_FILE}."
else
    if mkdir -p "$CONFIG_DIR" 2>/dev/null && [[ -w "$CONFIG_DIR" ]]; then
        echo "$FLAKES_LINE" >> "$CONFIG_FILE"
    else
        sudo mkdir -p "$CONFIG_DIR"
        echo "$FLAKES_LINE" | sudo tee -a "$CONFIG_FILE" >/dev/null
        sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$CONFIG_DIR"
    fi
    success "Flakes enabled in ${CONFIG_FILE}."
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

# ── Step 4: Enable git hooks ──────────────────────────────────────────────────
step "Step 4 — Enable Git Hooks"

# core.hooksPath is per-clone (not committed), so new machines need this once.
# Points git at the tracked .githooks/ pre-commit that runs `nix fmt`.
HOOKS_PATH=".githooks"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "Not a git repository — skipped git hooks setup."
elif [[ "$(git config --get core.hooksPath 2>/dev/null || true)" == "$HOOKS_PATH" ]]; then
    success "Git hooks already enabled (core.hooksPath=${HOOKS_PATH})."
else
    git config core.hooksPath "$HOOKS_PATH"
    success "Git hooks enabled (core.hooksPath=${HOOKS_PATH})."
fi

# ── Step 5: Secure Boot keys (Lanzaboote) ─────────────────────────────────────
# mine.boot.secureBoot defaults to true; Lanzaboote refuses to install a
# generation until /var/lib/sbctl has keys (db.pem). Create them before rebuild
# unless the operator opts out (VMs / no Secure Boot) — then disable on the host.
step "Step 5 — Secure Boot Keys (Lanzaboote)"

PKI_BUNDLE="/var/lib/sbctl"
DB_PEM="${PKI_BUNDLE}/keys/db/db.pem"

if [[ -e "$DB_PEM" ]]; then
    success "Secure Boot keys already present (${DB_PEM})."
else
    echo -en "${BOLD}Create Secure Boot keys (Lanzaboote)? [Y/n] ${RESET}"
    read -r sb_ans
    sb_ans="${sb_ans:-y}"
    if [[ "${sb_ans,,}" == "y" || "${sb_ans,,}" == "yes" ]]; then
        info "Creating Secure Boot keys at ${PKI_BUNDLE}..."
        info "(Required so Lanzaboote can sign boot generations on first switch.)"
        sbctl create-keys
        [[ -e "$DB_PEM" ]] || die "Keys were created but ${DB_PEM} is missing — aborting."
        success "Keys created at ${PKI_BUNDLE}."
    else
        warn "Skipped key creation — disabling Secure Boot on host '${HOST}'."
        ensure_host_disables_secure_boot "$DEFAULT_FILE"
    fi
fi

# Gate rebuild: keys present XOR host disables Secure Boot.
if [[ ! -e "$DB_PEM" ]] && ! host_disables_secure_boot "$DEFAULT_FILE"; then
    die "No keys at ${DB_PEM} and ${DEFAULT_FILE} does not set secureBoot = false — refusing rebuild."
fi

# ── Step 6: Apply system configuration ───────────────────────────────────────
step "Step 6 — Apply System Configuration"

# Root ignores the user's nix.conf; keep NIX_CONFIG so --flake works on
# minimal installs before this flake's nix module is applied.
info "Running: sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake .#${HOST}"
info "(Afterwards you can use: nh os switch .#${HOST})"
sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake ".#${HOST}"

# ── Step 7: Secure Boot enrollment (firmware) ────────────────────────────────
# Independent of the create-keys prompt: only needs a key bundle on disk.
step "Step 7 — Secure Boot Enrollment"

if [[ ! -e "$DB_PEM" ]]; then
    warn "No Secure Boot keys at ${DB_PEM} — enrollment steps omitted."
else
    info "Verifying signed boot artefacts..."
    if sbctl verify; then
        success "Boot chain verifies as signed."
    else
        warn "sbctl verify reported issues — check output above before enrolling."
    fi

    echo ""
    info "Firmware enrollment is still required once per machine:"
    echo -e "  1. Reboot into firmware setup → enable ${BOLD}Setup Mode${RESET}"
    echo -e "     (clear/factory-reset existing Secure Boot keys)"
    echo -e "  2. Boot NixOS again, then run:"
    echo -e "       ${BOLD}sudo sbctl enroll-keys -m${RESET}"
    echo -e "     (${BOLD}-m${RESET} keeps Microsoft keys — needed for some GPUs/BitLocker media)"
    echo -e "  3. Firmware → enable ${BOLD}Secure Boot${RESET}, disable Setup Mode, reboot"
    echo -e "  4. Confirm with: ${BOLD}bootctl status${RESET} / ${BOLD}sbctl status${RESET}"
    echo ""

    # Offer enroll now if the firmware is already in Setup Mode.
    STATUS_OUT="$(sbctl status 2>/dev/null || true)"
    if echo "$STATUS_OUT" | grep -Eiq 'Setup Mode.*(Enabled|Yes)|Setup Mode:\s*Enabled'; then
        warn "Firmware appears to be in Setup Mode right now."
        echo -en "${BOLD}Enroll keys into UEFI now? [Y/n] ${RESET}"
        read -r enroll_ans
        enroll_ans="${enroll_ans:-y}"
        if [[ "${enroll_ans,,}" == "y" || "${enroll_ans,,}" == "yes" ]]; then
            info "Running: sudo sbctl enroll-keys -m"
            sbctl enroll-keys -m
            success "Keys enrolled. Enable Secure Boot in firmware and reboot."
        else
            warn "Skipped enrollment — run ${BOLD}sudo sbctl enroll-keys -m${RESET} after entering Setup Mode."
        fi
    else
        warn "Firmware is not in Setup Mode yet — enroll after step 1 above."
    fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
success "All done! Welcome to your new NixOS system."
echo -e "  Rebuild later: ${BOLD}nh os switch .#${HOST}${RESET}  or  ${BOLD}sudo nixos-rebuild switch --flake .#${HOST}${RESET}"
echo ""
