#
# systems/common.nix — Modules shared by every NixOS host
#
# Wired into every system via `systems.modules.nixos` in flake.nix, so
# individual hosts under systems/x86_64-linux/*/default.nix only need to
# declare what's actually different about them (hostname, hardware,
# host-specific modules). Add a module here once it's wanted everywhere;
# a host can still layer on extra `${namespace} = lib.${namespace}.enable-modules [...]`
# entries of its own — enabling the same module in both places is harmless.
#
{ lib, namespace, ... }:

{
  ${namespace} = lib.${namespace}.enable-modules [
    "audio"
    "bluetooth"
    "boot"
    "desktop"
    "display"
    "dns"
    "fonts"
    "input-method"
    "input-remapper"
    "locale"
    "logging"
    "networking"
    "nh"
    "nix"
    "postgresql"
    "power"
    "printing"
    "programs"
    "tailscale"
    "users"
    "virtualisation"
  ];
}
