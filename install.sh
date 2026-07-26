#!/usr/bin/env bash
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

# Flakes ignore untracked files — stage only inside a git repo.
git_stage() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git add "$@"
    else
        die "Not a git repository. Flakes ignore untracked files — clone or git init before running install.sh."
    fi
}

# Flat (`mine.boot.secureBoot = false`) or nested (`boot = { secureBoot = false; }`).
host_disables_secure_boot() {
    grep -Eq '(\$\{namespace\}|mine)\.boot\.secureBoot[[:space:]]*=[[:space:]]*false' "$1" \
        || grep -Eq '^[[:space:]]*secureBoot[[:space:]]*=[[:space:]]*false[[:space:]]*;' "$1"
}

host_disables_efi() {
    grep -Eq '(\$\{namespace\}|mine)\.boot\.efi[[:space:]]*=[[:space:]]*false' "$1" \
        || grep -Eq '^[[:space:]]*efi[[:space:]]*=[[:space:]]*false[[:space:]]*;' "$1"
}

host_has_grub_device() {
    grep -Eq '(\$\{namespace\}|mine)\.boot\.grubDevice' "$1" \
        || grep -Eq '^[[:space:]]*grubDevice[[:space:]]*=' "$1"
}

# Strip flat mine.boot.* lines and nested mine.boot = { ... }; blocks we manage.
strip_managed_boot_attrs() {
    local file="$1"
    local tmp
    tmp="$(mktemp)"
    awk '
        /\$\{namespace\}\.boot = \{/ || /^[[:space:]]*mine\.boot = \{/ { skip = 1; next }
        skip && /^[[:space:]]*\};[[:space:]]*$/ { skip = 0; next }
        skip { next }
        /\$\{namespace\}\.boot\./ || /^[[:space:]]*mine\.boot\./ { next }
        { print }
    ' "$file" >"$tmp"
    mv "$tmp" "$file"
}

host_tree_disables_secure_boot() {
    local f
    for f in "$HOST_DIR"/*.nix; do
        [[ -f "$f" ]] || continue
        host_disables_secure_boot "$f" && return 0
    done
    return 1
}

host_tree_disables_efi() {
    local f
    for f in "$HOST_DIR"/*.nix; do
        [[ -f "$f" ]] || continue
        host_disables_efi "$f" && return 0
    done
    return 1
}

detect_grub_device() {
    if [[ -b /dev/vda ]]; then
        echo /dev/vda
    elif [[ -b /dev/sda ]]; then
        echo /dev/sda
    elif [[ -b /dev/nvme0n1 ]]; then
        echo /dev/nvme0n1
    else
        lsblk -dno NAME,TYPE 2>/dev/null | awk '$2 == "disk" { print "/dev/" $1; exit }'
    fi
}

# Insert line(s) before the first top-level closing `}`.
insert_before_closing_brace() {
    local file="$1"
    shift
    local tmp line
    tmp="$(mktemp)"
    {
        for line in "$@"; do
            printf '%s\n' "$line"
        done
    } >"${tmp}.lines"
    awk -v lines_file="${tmp}.lines" '
        BEGIN {
            while ((getline line < lines_file) > 0) lines[++n] = line
            close(lines_file)
            inserted = 0
        }
        {
            if (!inserted && $0 ~ /^}/) {
                for (i = 1; i <= n; i++) print lines[i]
                inserted = 1
            }
            print
        }
        END { if (!inserted) exit 1 }
    ' "$file" >"$tmp" || die "Could not update ${file}."
    mv "$tmp" "$file"
    rm -f "${tmp}.lines"
}

ensure_host_disables_secure_boot() {
    local file="$1"
    if host_disables_secure_boot "$file"; then
        success "Host already sets secureBoot = false (${file})."
        return 0
    fi

    # One nested attrset — multiple ${namespace}.boot.* siblings are invalid Nix.
    strip_managed_boot_attrs "$file"
    insert_before_closing_brace "$file" \
        "  \${namespace}.boot = {" \
        "    secureBoot = false;" \
        "  };"

    host_disables_secure_boot "$file" || die "Failed to set secureBoot = false in ${file}."
    git_stage "$file"
    success "Set \${namespace}.boot.secureBoot = false in ${file}."
}

# systemd-boot needs a mounted ESP at /boot; BIOS/VMs without one use GRUB.
# Must be one nested ${namespace}.boot = { ... }; (not sibling dynamic attrs).
ensure_host_bios_boot() {
    local file="$1"
    local grub
    grub="$(detect_grub_device)"
    [[ -n "$grub" ]] || die "Could not detect a disk for GRUB (set mine.boot.grubDevice manually)."

    if host_disables_efi "$file" && host_disables_secure_boot "$file" && host_has_grub_device "$file"; then
        success "Host already configured for BIOS/GRUB (${file})."
        return 0
    fi

    strip_managed_boot_attrs "$file"
    insert_before_closing_brace "$file" \
        "  \${namespace}.boot = {" \
        "    efi = false;" \
        "    secureBoot = false;" \
        "    grubDevice = \"${grub}\";" \
        "  };"

    host_disables_efi "$file" || die "Failed to set boot.efi = false in ${file}."
    git_stage "$file"
    success "BIOS/GRUB boot: efi=false, grubDevice=${grub} (${file})."
}

# Prefer system sbctl; fall back to `nix shell` (not nested nix-shell -p).
sbctl() {
    local bin=""
    if [[ -x /run/current-system/sw/bin/sbctl ]]; then
        bin=/run/current-system/sw/bin/sbctl
    else
        bin="$(type -P sbctl 2>/dev/null || true)"
    fi

    if [[ -n "$bin" ]]; then
        sudo "$bin" "$@"
    else
        nix shell nixpkgs#sbctl -c sh -c 'sudo "$(command -v sbctl)" "$@"' sh "$@"
    fi
}

detect_virt_env() {
    IS_VIRTUAL=0
    HAS_EFI=0
    HAS_BOOT_MOUNT=0
    USE_EFI=0
    VIRT_NAME="none"

    if [[ -d /sys/firmware/efi ]]; then
        HAS_EFI=1
    fi

    if mountpoint -q /boot 2>/dev/null; then
        HAS_BOOT_MOUNT=1
    fi

    # systemd-boot/Lanzaboote need EFI firmware + ESP mounted at /boot.
    if [[ "$HAS_EFI" -eq 1 && "$HAS_BOOT_MOUNT" -eq 1 ]]; then
        USE_EFI=1
    fi

    if command -v systemd-detect-virt >/dev/null 2>&1; then
        VIRT_NAME="$(systemd-detect-virt 2>/dev/null || echo none)"
        if [[ -n "$VIRT_NAME" && "$VIRT_NAME" != "none" ]]; then
            IS_VIRTUAL=1
        fi
    fi

    # Skip firmware enrollment on VMs and when EFI bootloader is not usable.
    SKIP_SB_ENROLL=0
    if [[ "$IS_VIRTUAL" -eq 1 || "$USE_EFI" -eq 0 ]]; then
        SKIP_SB_ENROLL=1
    fi
}

echo ""
echo -e "${BRED}  ❄  NixOS Multi-Host Installer${RESET}"
echo -e "  Configure and apply a NixOS host from this flake."
echo ""

[[ -f flake.nix ]] || die "Run this script from the root of the nix configuration repository."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "Not a git repository. Flakes ignore untracked files — clone or git init first."

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    warn "Prefer running without sudo; this script elevates only where needed."
fi

OWNER_USER="${SUDO_USER:-$USER}"
OWNER_GROUP="$(id -gn "$OWNER_USER")"
OWNER_HOME="$(getent passwd "$OWNER_USER" | cut -d: -f6)"
[[ -n "$OWNER_HOME" && -d "$OWNER_HOME" ]] || die "Cannot resolve home directory for '${OWNER_USER}'."

detect_virt_env
if [[ "$IS_VIRTUAL" -eq 1 ]]; then
    warn "Virtual machine detected (${VIRT_NAME})."
fi
if [[ "$USE_EFI" -eq 0 ]]; then
    warn "No usable EFI ESP at /boot — will use GRUB (mine.boot.efi = false)."
elif [[ "$IS_VIRTUAL" -eq 1 ]]; then
    warn "Secure Boot enrollment will be skipped by default on this VM."
fi

SYSTEMS_DIR="systems/x86_64-linux"
DETECTED="$(hostname -s)"
AVAILABLE="$(ls "$SYSTEMS_DIR/" | tr '\n' ' ')"
info "Available hosts: ${BOLD}${AVAILABLE}${RESET}"
info "Flake attribute = directory name under ${SYSTEMS_DIR}/ (not necessarily the live hostname)."
echo -en "${BOLD}Host name to configure [${DETECTED}]: ${RESET}"
read -r HOST
HOST="${HOST:-$DETECTED}"
[[ "$HOST" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] \
    || die "Invalid host name '${HOST}' (use letters, digits, _ or -)."

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

# Snowfall expects systems/<arch>/<host>/default.nix
if [[ ! -f "$DEFAULT_FILE" ]]; then
    BOOT_LINES="# Optional: \${namespace}.boot.secureBoot = false;"
    if [[ "$USE_EFI" -eq 0 ]]; then
        GRUB_DEV="$(detect_grub_device)"
        [[ -n "$GRUB_DEV" ]] || die "Could not detect a disk for GRUB."
        BOOT_LINES="\${namespace}.boot = {
    efi = false;
    secureBoot = false;
    grubDevice = \"${GRUB_DEV}\";
  };"
    elif [[ "$SKIP_SB_ENROLL" -eq 1 ]]; then
        BOOT_LINES="\${namespace}.boot = {
    secureBoot = false;
  };"
    fi
    cat > "$DEFAULT_FILE" <<EOF
{ lib, namespace, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "$HOST";

  # Optional: \${namespace}.host = lib.\${namespace}.mkDualMonitorHost "HDMI-A-1";
  ${BOOT_LINES}
}
EOF
    git_stage "$DEFAULT_FILE"
    success "Created ${DEFAULT_FILE}."
fi

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
  # Optional: mine.packages.creator.enable = false;
  # Optional: mine.user.wallpaper = ./wall.png;
}
EOF
    sudo chown -R "${OWNER_USER}:${OWNER_GROUP}" "$HOMES_DIR"
    git_stage "$HOME_DEFAULT"
    success "Created ${HOME_DEFAULT}."
fi

git_stage "$HOST_DIR" "$USER_DIR"

step "Step 3 — Enable Flakes"

# Owner home — not root's $HOME when run via sudo.
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

step "Step 4 — Enable Git Hooks"

HOOKS_PATH=".githooks"
if [[ "$(git config --get core.hooksPath 2>/dev/null || true)" == "$HOOKS_PATH" ]]; then
    success "Git hooks already enabled (core.hooksPath=${HOOKS_PATH})."
else
    git config core.hooksPath "$HOOKS_PATH"
    success "Git hooks enabled (core.hooksPath=${HOOKS_PATH})."
fi

# Keys before rebuild: Lanzaboote needs db.pem, or host must set secureBoot = false.
step "Step 5 — Secure Boot Keys (Lanzaboote)"

PKI_BUNDLE="/var/lib/sbctl"
DB_PEM="${PKI_BUNDLE}/keys/db/db.pem"
WANT_SECURE_BOOT=0

if [[ "$USE_EFI" -eq 0 ]]; then
    warn "Configuring BIOS/GRUB boot (no mounted EFI system partition at /boot)."
    ensure_host_bios_boot "$DEFAULT_FILE"
elif [[ -e "$DB_PEM" ]]; then
    success "Secure Boot keys already present (${DB_PEM})."
    if [[ "$SKIP_SB_ENROLL" -eq 1 ]] && ! host_tree_disables_secure_boot; then
        warn "Keys exist, but this looks like a VM — Secure Boot enrollment is usually skipped."
        echo -en "${BOLD}Disable Secure Boot on host '${HOST}'? [Y/n] ${RESET}"
        read -r sb_dis_ans
        sb_dis_ans="${sb_dis_ans:-y}"
        if [[ "${sb_dis_ans,,}" == "y" || "${sb_dis_ans,,}" == "yes" ]]; then
            ensure_host_disables_secure_boot "$DEFAULT_FILE"
        else
            WANT_SECURE_BOOT=1
            warn "Keeping Secure Boot enabled — enrollment may still fail in this environment."
        fi
    else
        WANT_SECURE_BOOT=1
    fi
else
    if [[ "$SKIP_SB_ENROLL" -eq 1 ]]; then
        warn "VM: skipping Secure Boot keys by default."
        echo -en "${BOLD}Create Secure Boot keys anyway? [y/N] ${RESET}"
        read -r sb_ans
        sb_ans="${sb_ans:-n}"
    else
        echo -en "${BOLD}Create Secure Boot keys (Lanzaboote)? [Y/n] ${RESET}"
        read -r sb_ans
        sb_ans="${sb_ans:-y}"
    fi

    if [[ "${sb_ans,,}" == "y" || "${sb_ans,,}" == "yes" ]]; then
        info "Creating Secure Boot keys at ${PKI_BUNDLE}..."
        info "(Required so Lanzaboote can sign boot generations on first switch.)"
        sbctl create-keys
        [[ -e "$DB_PEM" ]] || die "Keys were created but ${DB_PEM} is missing — aborting."
        success "Keys created at ${PKI_BUNDLE}."
        WANT_SECURE_BOOT=1
    else
        warn "Skipped key creation — disabling Secure Boot on host '${HOST}'."
        ensure_host_disables_secure_boot "$DEFAULT_FILE"
    fi
fi

if [[ "$USE_EFI" -eq 1 ]] && [[ ! -e "$DB_PEM" ]] && ! host_tree_disables_secure_boot; then
    die "No keys at ${DB_PEM} and host under ${HOST_DIR} does not set secureBoot = false — refusing rebuild."
fi

if [[ "$USE_EFI" -eq 0 ]] && ! host_tree_disables_efi; then
    die "No ESP at /boot and host under ${HOST_DIR} does not set boot.efi = false — refusing rebuild."
fi

step "Step 6 — Apply System Configuration"

# Root ignores user nix.conf — keep NIX_CONFIG for --flake on minimal installs.
info "Running: sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake .#${HOST}"
info "(Afterwards you can use: nh os switch .#${HOST})"
sudo --preserve-env=NIX_CONFIG nixos-rebuild switch --flake ".#${HOST}"
success "System configuration applied."

# Enrollment after rebuild (signed generations). Bare-metal EFI only.
step "Step 7 — Secure Boot Enrollment"

ENROLL_STATUS="skipped"

if host_tree_disables_secure_boot; then
    warn "Host has secureBoot = false — enrollment omitted."
elif [[ ! -e "$DB_PEM" ]]; then
    warn "No Secure Boot keys at ${DB_PEM} — enrollment omitted."
elif [[ "$HAS_EFI" -eq 0 ]]; then
    warn "No EFI firmware — sbctl enrollment omitted."
elif [[ "$IS_VIRTUAL" -eq 1 ]]; then
    warn "Virtual machine (${VIRT_NAME}) — firmware enrollment omitted."
    warn "For guest Secure Boot, configure OVMF in the hypervisor; or keep mine.boot.secureBoot = false."
elif [[ "$WANT_SECURE_BOOT" -eq 0 ]]; then
    warn "Secure Boot was not requested — enrollment omitted."
else
    info "Verifying signed boot artefacts..."
    if sbctl verify; then
        success "Boot chain verifies as signed."
        ENROLL_STATUS="verified"
    else
        warn "sbctl verify reported issues — check output above before enrolling."
        ENROLL_STATUS="verify-failed"
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
            ENROLL_STATUS="enrolled"
        else
            warn "Skipped enrollment — run ${BOLD}sudo sbctl enroll-keys -m${RESET} after entering Setup Mode."
            ENROLL_STATUS="pending"
        fi
    else
        warn "Firmware is not in Setup Mode yet — enroll after step 1 above."
        ENROLL_STATUS="pending"
    fi
fi

echo ""
success "System install finished for host ${BOLD}${HOST}${RESET}."
case "$ENROLL_STATUS" in
    enrolled)   info "Secure Boot keys enrolled — enable Secure Boot in firmware if needed." ;;
    verified)   info "Boot chain verified; firmware enrollment still pending (see step 7)." ;;
    pending)    info "Secure Boot firmware enrollment still pending (see step 7)." ;;
    verify-failed) warn "sbctl verify had issues — fix ESP/firmware before enrolling." ;;
    skipped)    info "Secure Boot enrollment skipped (VM, non-EFI, or disabled on host)." ;;
esac
echo -e "  Rebuild later: ${BOLD}nh os switch .#${HOST}${RESET}  or  ${BOLD}sudo nixos-rebuild switch --flake .#${HOST}${RESET}"
echo ""
