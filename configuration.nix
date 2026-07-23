#
# configuration.nix — Shared NixOS base
#
# Imports every system module. Anything host-specific lives under
# hosts/<name>/; this file is the common denominator for all machines.
#
{ config, pkgs, username, hostName, ... }:

{
  imports = [
    # ── Core ─────────────────────────────────────────────────
    ./modules/system/nix.nix
    ./modules/system/boot.nix
    ./modules/system/logging.nix

    # ── Networking ───────────────────────────────────────────
    ./modules/system/networking.nix
    ./modules/system/dns.nix
    ./modules/system/tailscale.nix

    # ── Localisation ─────────────────────────────────────────
    ./modules/system/locale.nix
    ./modules/system/fonts.nix
    ./modules/system/input-method.nix

    # ── Hardware & peripherals ───────────────────────────────
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/printing.nix
    ./modules/system/power.nix
    ./modules/system/input-remapper.nix

    # ── Desktop ──────────────────────────────────────────────
    ./modules/system/display.nix
    ./modules/system/desktop.nix

    # ── Programs & services ──────────────────────────────────
    ./modules/system/programs.nix
    ./modules/system/virtualisation.nix
    ./modules/system/postgresql.nix

    # ── Users ────────────────────────────────────────────────
    ./modules/system/users.nix
  ];
}
