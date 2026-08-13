#!/usr/bin/env bash
# Bootstrap a new (or freshly installed) NixOS host from this Snowfall flake.
#
#   ./install.sh
#
# What it does:
#   1. Detect EFI+ESP vs BIOS/VM boot needs
#   2. Generate hardware-configuration.nix (strips Docker/Podman overlays)
#   3. Scaffold systems/<arch>/<host>/ and homes/<arch>/<user>/ if missing
#   4. Enable flakes; create Secure Boot keys when appropriate
#   5. nixos-rebuild switch --flake .#<host>
#
# What it does NOT do:
#   - Rewrite an existing systems/.../default.nix (edit boot options yourself)
#   - Enroll Secure Boot keys into firmware (prints the one-time steps)
set -euo pipefail

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

ask_yn() {
    # $1 prompt  $2 default (y|n)
    local prompt="$1" default="$2" ans
    if [[ "$default" == "y" ]]; then
        echo -en "${BOLD}${prompt} [Y/n] ${RESET}"
    else
        echo -en "${BOLD}${prompt} [y/N] ${RESET}"
    fi
    read -r ans || true
    ans="${ans:-$default}"
    [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

git_stage() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
        || die "Not a git repository. Flakes ignore untracked files — clone or git init first."
    git add "$@"
}

# Derive toggle lines from lib/packages.nix (single source of truth).
package_group_toggle_lines() {
    local repo_root="$1" lines
    if lines="$(
        nix eval --impure --raw --expr "
          let
            pkgs = import <nixpkgs> {};
            packages = import ${repo_root}/lib/packages.nix { lib = pkgs.lib; };
          in builtins.concatStringsSep \"\\n\" (
            map (n: \"    \" + n + \" = true;\") packages.packageGroupNames
          )
        " 2>/dev/null
    )"; then
        printf '%s\n' "$lines"
        return 0
    fi
    warn "Could not read lib/packages.nix — using a built-in package group list."
    cat <<'EOF'
    nix = true;
    monitoring = true;
    wayland = true;
    clipboard = true;
    viewers = true;
    fonts = true;
    editors = true;
    ides = true;
    cli = true;
    c = true;
    python = true;
    ai = true;
    vcs = true;
    js = true;
    jvm = true;
    rust = true;
    dioxus = true;
    tauri = true;
    gtk = true;
    dotnet = true;
    databases = true;
    api = true;
    office = true;
    notes = true;
    learning = true;
    browsers = true;
    proton = true;
    mail = true;
    communication = true;
    media = true;
    creator = true;
    audio = true;
EOF
}

# ── Environment ──────────────────────────────────────────────────────────────

detect_system() {
    case "$(uname -m)" in
        x86_64)       echo x86_64-linux ;;
        aarch64|arm64) echo aarch64-linux ;;
        *) die "Unsupported architecture: $(uname -m)" ;;
    esac
}

detect_grub_device() {
    local d
    for d in /dev/vda /dev/sda /dev/nvme0n1; do
        [[ -b "$d" ]] && { echo "$d"; return; }
    done
    lsblk -dno NAME,TYPE 2>/dev/null | awk '$2 == "disk" { print "/dev/" $1; exit }'
}

# Sets: IS_VM VIRT_NAME HAS_EFI HAS_ESP USE_EFI
detect_boot_env() {
    HAS_EFI=0
    HAS_ESP=0
    USE_EFI=0
    IS_VM=0
    VIRT_NAME=none

    [[ -d /sys/firmware/efi ]] && HAS_EFI=1
    mountpoint -q /boot 2>/dev/null && HAS_ESP=1
    # systemd-boot / Lanzaboote need firmware EFI + ESP mounted at /boot.
    [[ "$HAS_EFI" -eq 1 && "$HAS_ESP" -eq 1 ]] && USE_EFI=1

    if command -v systemd-detect-virt >/dev/null 2>&1; then
        VIRT_NAME="$(systemd-detect-virt 2>/dev/null || echo none)"
        [[ -n "$VIRT_NAME" && "$VIRT_NAME" != "none" ]] && IS_VM=1
    fi
}

run_sbctl() {
    if [[ -x /run/current-system/sw/bin/sbctl ]]; then
        sudo /run/current-system/sw/bin/sbctl "$@"
    elif command -v sbctl >/dev/null 2>&1; then
        sudo sbctl "$@"
    else
        sudo nix shell nixpkgs#sbctl -c sbctl "$@"
    fi
}

# ── Hardware config ──────────────────────────────────────────────────────────

stop_container_runtimes() {
    if systemctl is-active --quiet docker.service 2>/dev/null \
        || systemctl is-active --quiet docker.socket 2>/dev/null; then
        warn "Stopping Docker so hardware scan does not capture overlay mounts..."
        sudo systemctl stop docker.service docker.socket 2>/dev/null || true
    fi
    if systemctl is-active --quiet podman.service 2>/dev/null; then
        warn "Stopping Podman so hardware scan does not capture overlay mounts..."
        sudo systemctl stop podman.service 2>/dev/null || true
    fi
    local mp
    while IFS= read -r mp; do
        [[ -n "$mp" ]] || continue
        sudo umount -l "$mp" 2>/dev/null || true
    done < <(findmnt -nlo TARGET 2>/dev/null | grep -E '^/var/lib/(docker|containers)' || true)
}

# nixos-generate-config snapshots /proc/mounts; live container overlays become
# fileSystems entries and break local-fs.target on reboot.
strip_ephemeral_filesystems() {
    local file="$1" tmp removed
    tmp="$(mktemp)"
    removed="$(mktemp)"
    awk '
        function brace_delta(s,    i, c, d) {
            d = 0
            for (i = 1; i <= length(s); i++) {
                c = substr(s, i, 1)
                if (c == "{") d++
                if (c == "}") d--
            }
            return d
        }
        function fs_path(s,    t) {
            t = s
            sub(/^.*fileSystems\."/, "", t)
            sub(/".*$/, "", t)
            return t
        }
        function is_ephemeral(p, b) {
            return (p ~ /\/var\/lib\/docker/) \
                || (p ~ /\/var\/lib\/containers/) \
                || (b ~ /device = "overlay"/) \
                || (b ~ /fsType = "overlay"/)
        }
        BEGIN { skip = 0; depth = 0; path = ""; buf = "" }
        {
            if (!skip && $0 ~ /^[[:space:]]*fileSystems\."/) {
                path = fs_path($0)
                buf = $0
                depth = brace_delta($0)
                skip = 1
                if (depth <= 0 && $0 ~ /;\s*$/) {
                    if (is_ephemeral(path, buf)) print path > "/dev/stderr"
                    else print buf
                    skip = 0; path = ""; buf = ""
                }
                next
            }
            if (skip) {
                buf = buf ORS $0
                depth += brace_delta($0)
                if (depth <= 0 && $0 ~ /;\s*$/) {
                    if (is_ephemeral(path, buf)) print path > "/dev/stderr"
                    else print buf
                    skip = 0; path = ""; buf = ""; depth = 0
                }
                next
            }
            print
        }
    ' "$file" >"$tmp" 2>"$removed"
    mv "$tmp" "$file"
    if [[ -s "$removed" ]]; then
        warn "Removed ephemeral container mounts from hardware-configuration:"
        while IFS= read -r mp; do
            [[ -n "$mp" ]] || continue
            warn "  - ${mp}"
        done <"$removed"
    fi
    rm -f "$removed"
}

# ── Host / home scaffolds (create only — never rewrite) ──────────────────────

# Print a boot attrset for a *new* host default.nix (one nested mine.boot = { }).
boot_block_for_new_host() {
    local want_sb="$1" # y|n — only meaningful when USE_EFI=1
    local grub

    if [[ "$USE_EFI" -eq 0 ]]; then
        grub="$(detect_grub_device)"
        [[ -n "$grub" ]] || die "Could not detect a disk for GRUB (set mine.boot.grubDevice by hand)."
        cat <<EOF
  # BIOS / no ESP at /boot — GRUB (typical QEMU BIOS VM).
  \${namespace}.boot = {
    efi = false;
    secureBoot = false;
    grubDevice = "${grub}";
  };
EOF
        return
    fi

    if [[ "$want_sb" != "y" ]]; then
        cat <<EOF
  # Unsigned systemd-boot (no Lanzaboote keys).
  \${namespace}.boot = {
    secureBoot = false;
  };
EOF
    fi
    # want_sb=y → omit boot block; module default secureBoot=true + keys created below.
}

host_sets_efi_false() {
    grep -Eq '(^|[[:space:]])(efi)\s*=\s*false\s*;' "$1" \
        || grep -Eq '(\$\{namespace\}|mine)\.boot\.efi\s*=\s*false' "$1"
}

host_sets_secure_boot_false() {
    grep -Eq '(^|[[:space:]])(secureBoot)\s*=\s*false\s*;' "$1" \
        || grep -Eq '(\$\{namespace\}|mine)\.boot\.secureBoot\s*=\s*false' "$1"
}

require_boot_config() {
    local file="$1"
    [[ -f "$file" ]] || die "Missing ${file}"

    if [[ "$USE_EFI" -eq 0 ]]; then
        if ! host_sets_efi_false "$file"; then
            local grub
            grub="$(detect_grub_device)"
            die "No usable EFI ESP at /boot, but ${file} does not set efi = false.
Add this (one nested attrset — not multiple mine.boot.* siblings):

  \${namespace}.boot = {
    efi = false;
    secureBoot = false;
    grubDevice = \"${grub:-/dev/vda}\";
  };
"
        fi
        return
    fi

    # EFI path: either keys exist, or host disables Secure Boot.
    if [[ ! -e "$DB_PEM" ]] && ! host_sets_secure_boot_false "$file"; then
        die "No Secure Boot keys at ${DB_PEM} and ${file} does not set secureBoot = false.
Either create keys (re-run and accept the prompt) or add:

  \${namespace}.boot = {
    secureBoot = false;
  };
"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BRED}  ❄  NixOS Multi-Host Installer${RESET}"
echo -e "  Bootstrap a host from this Snowfall flake."
echo ""

[[ -f flake.nix ]] || die "Run from the repository root (flake.nix missing)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "Not a git repository. Flakes ignore untracked files — clone or git init first."

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    warn "Prefer running as a normal user; the script sudo's only where needed."
fi

OWNER_USER="${SUDO_USER:-$USER}"
OWNER_GROUP="$(id -gn "$OWNER_USER")"
OWNER_HOME="$(getent passwd "$OWNER_USER" | cut -d: -f6)"
[[ -n "$OWNER_HOME" && -d "$OWNER_HOME" ]] || die "Cannot resolve home for '${OWNER_USER}'."

SYSTEM="$(detect_system)"
detect_boot_env

PKI_BUNDLE="/var/lib/sbctl"
DB_PEM="${PKI_BUNDLE}/keys/db/db.pem"

info "System: ${BOLD}${SYSTEM}${RESET}  user: ${BOLD}${OWNER_USER}${RESET}"
if [[ "$IS_VM" -eq 1 ]]; then
    warn "Virtual machine detected (${VIRT_NAME})."
fi
if [[ "$USE_EFI" -eq 1 ]]; then
    info "Boot path: EFI (firmware + /boot mounted)."
else
    warn "Boot path: BIOS/GRUB (no EFI firmware and/or /boot not mounted)."
fi

SYSTEMS_DIR="systems/${SYSTEM}"
HOMES_DIR="homes/${SYSTEM}"
mkdir -p "$SYSTEMS_DIR"

AVAILABLE="$(find "$SYSTEMS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f ' 2>/dev/null || true)"
DETECTED="$(hostname -s 2>/dev/null || echo nixos)"
info "Existing hosts: ${BOLD}${AVAILABLE:-none}${RESET}"
info "Flake attribute = directory name under ${SYSTEMS_DIR}/."
echo -en "${BOLD}Host name [${DETECTED}]: ${RESET}"
read -r HOST
HOST="${HOST:-$DETECTED}"
[[ "$HOST" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] \
    || die "Invalid host name '${HOST}' (letters, digits, _ or -)."

HOST_DIR="${SYSTEMS_DIR}/${HOST}"
HW_FILE="${HOST_DIR}/hardware-configuration.nix"
DEFAULT_FILE="${HOST_DIR}/default.nix"
mkdir -p "$HOST_DIR"

# ── 1. Hardware ──────────────────────────────────────────────────────────────

step "1 — Hardware configuration"

if [[ -f "$HW_FILE" ]]; then
    ask_yn "Overwrite existing ${HW_FILE}?" n || die "Aborted."
fi

stop_container_runtimes
info "Running nixos-generate-config..."
sudo nixos-generate-config
[[ -f /etc/nixos/hardware-configuration.nix ]] \
    || die "nixos-generate-config did not produce /etc/nixos/hardware-configuration.nix"
sudo cp -f /etc/nixos/hardware-configuration.nix "$HW_FILE"
sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$HOST_DIR"
strip_ephemeral_filesystems "$HW_FILE"
sudo cp -f "$HW_FILE" /etc/nixos/hardware-configuration.nix
git_stage "$HW_FILE"
success "Wrote ${HW_FILE}"

# ── 2. Host scaffold ─────────────────────────────────────────────────────────

step "2 — Host scaffold"

WANT_SB=n
if [[ ! -f "$DEFAULT_FILE" ]]; then
    if [[ "$USE_EFI" -eq 1 ]]; then
        if [[ "$IS_VM" -eq 1 ]]; then
            warn "VM with EFI — defaulting to secureBoot = false (systemd-boot)."
            if ask_yn "Create Secure Boot keys / enable Lanzaboote anyway?" n; then
                WANT_SB=y
            fi
        else
            if ask_yn "Enable Secure Boot (Lanzaboote keys)?" y; then
                WANT_SB=y
            fi
        fi
    fi

    {
        cat <<EOF
{ lib, namespace, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "${HOST}";

  # Dual monitor (ultrawide + laptop panel) — add to imports above:
  # (lib.\${namespace}.dualMonitorHostModule "HDMI-A-1")
EOF
        boot_block_for_new_host "$WANT_SB"
        echo "}"
    } >"$DEFAULT_FILE"

    git_stage "$DEFAULT_FILE"
    success "Created ${DEFAULT_FILE}"
else
    success "Keeping existing ${DEFAULT_FILE} (not rewritten)."
    if [[ "$USE_EFI" -eq 1 ]] && [[ ! -e "$DB_PEM" ]] && ! host_sets_secure_boot_false "$DEFAULT_FILE"; then
        if ask_yn "No Secure Boot keys found — create them now?" "$([[ "$IS_VM" -eq 1 ]] && echo n || echo y)"; then
            WANT_SB=y
        fi
    elif [[ -e "$DB_PEM" ]] && ! host_sets_secure_boot_false "$DEFAULT_FILE"; then
        WANT_SB=y
    fi
fi

# ── 3. Home scaffold ─────────────────────────────────────────────────────────

step "3 — Home Manager user"

USER_DIR="${HOMES_DIR}/${OWNER_USER}"
HOME_DEFAULT="${USER_DIR}/default.nix"
PACKAGE_GROUPS="${USER_DIR}/package-groups.nix"
mkdir -p "$USER_DIR"

if [[ ! -f "$PACKAGE_GROUPS" ]]; then
    TOGGLE_LINES="$(package_group_toggle_lines "$(pwd)")"
    cat >"$PACKAGE_GROUPS" <<EOF
# Flip groups on/off here, then \`nh os switch\`.
# Group names come from lib/packages.nix (lib.mine.packageGroups).
{ lib, ... }:

let
  toggles = {
${TOGGLE_LINES}
  };
in
{
  mine.packages = lib.recursiveUpdate {
    enable = true;
  } (lib.mine.packageGroupsFromToggles toggles);
}
EOF
    git_stage "$PACKAGE_GROUPS"
    success "Created ${PACKAGE_GROUPS}"
fi

if [[ -f "$HOME_DEFAULT" ]]; then
    success "Keeping existing ${HOME_DEFAULT}"
else
    cat >"$HOME_DEFAULT" <<EOF
# Username = directory name. Shared modules: homes/common.nix.
{ ... }:

{
  imports = [ ./package-groups.nix ];

  # Optional: mine.user.wallpaper = ./wall.png;
}
EOF
    sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$HOMES_DIR" 2>/dev/null || true
    git_stage "$HOME_DEFAULT"
    success "Created ${HOME_DEFAULT}"
fi

git_stage "$HOST_DIR" "$USER_DIR"

# ── 4. Flakes + hooks ────────────────────────────────────────────────────────

step "4 — Flakes"

CONFIG_DIR="${OWNER_HOME}/.config/nix"
CONFIG_FILE="${CONFIG_DIR}/nix.conf"
FLAKES_LINE="experimental-features = nix-command flakes"

if grep -Fxq "$FLAKES_LINE" "$CONFIG_FILE" 2>/dev/null; then
    success "Flakes already enabled (${CONFIG_FILE})."
else
    if mkdir -p "$CONFIG_DIR" 2>/dev/null && [[ -w "$CONFIG_DIR" ]]; then
        echo "$FLAKES_LINE" >>"$CONFIG_FILE"
    else
        sudo mkdir -p "$CONFIG_DIR"
        echo "$FLAKES_LINE" | sudo tee -a "$CONFIG_FILE" >/dev/null
        sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$CONFIG_DIR"
    fi
    success "Enabled flakes in ${CONFIG_FILE}."
fi
export NIX_CONFIG="experimental-features = nix-command flakes"

if [[ -d .githooks ]]; then
    if [[ "$(git config --get core.hooksPath 2>/dev/null || true)" == ".githooks" ]]; then
        success "Git hooks already enabled."
    else
        git config core.hooksPath .githooks
        success "Enabled git hooks (core.hooksPath=.githooks)."
    fi
fi

# ── 5. Secure Boot keys ──────────────────────────────────────────────────────

step "5 — Secure Boot keys"

if [[ "$USE_EFI" -eq 0 ]]; then
    warn "Non-EFI boot — skipping Lanzaboote keys."
elif [[ -e "$DB_PEM" ]]; then
    success "Keys already present (${DB_PEM})."
elif [[ "$WANT_SB" == "y" ]]; then
    info "Creating keys at ${PKI_BUNDLE}..."
    run_sbctl create-keys
    [[ -e "$DB_PEM" ]] || die "sbctl create-keys ran but ${DB_PEM} is missing."
    success "Keys created."
else
    warn "No keys — host must set secureBoot = false (checked next)."
fi

require_boot_config "$DEFAULT_FILE"

# ── 6. Rebuild ───────────────────────────────────────────────────────────────

step "6 — Apply configuration"

info "sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake .#${HOST}"
sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake ".#${HOST}"
success "Applied .#${HOST}"

# ── 7. Enrollment notes ──────────────────────────────────────────────────────

step "7 — Done"

if [[ "$USE_EFI" -eq 1 && -e "$DB_PEM" ]] && ! host_sets_secure_boot_false "$DEFAULT_FILE"; then
    if [[ "$IS_VM" -eq 1 ]]; then
        warn "VM: firmware enrollment skipped. Keep secureBoot = false unless OVMF Secure Boot is set up."
    else
        info "One-time Secure Boot enrollment (bare metal):"
        echo -e "  1. Firmware → enable ${BOLD}Setup Mode${RESET} (clear Secure Boot keys)"
        echo -e "  2. Boot NixOS, then: ${BOLD}sudo sbctl enroll-keys -m${RESET}"
        echo -e "  3. Firmware → enable Secure Boot, reboot"
        echo -e "  4. Confirm: ${BOLD}bootctl status${RESET} / ${BOLD}sbctl status${RESET}"
        if run_sbctl status 2>/dev/null | grep -Eiq 'Setup Mode.*(Enabled|Yes)|Setup Mode:\s*Enabled'; then
            if ask_yn "Firmware is in Setup Mode — enroll keys now?" y; then
                run_sbctl enroll-keys -m
                success "Keys enrolled. Enable Secure Boot in firmware and reboot."
            fi
        fi
    fi
fi

echo ""
success "Finished for host ${BOLD}${HOST}${RESET}."
echo -e "  Later: ${BOLD}nh os switch -H ${HOST}${RESET}  or  ${BOLD}sudo nixos-rebuild switch --flake .#${HOST}${RESET}"
echo ""
