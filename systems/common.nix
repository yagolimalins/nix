# Shared NixOS module toggles for every host (wired via systems.modules.nixos).
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
    "sqlserver"
    "power"
    "printing"
    "programs"
    "tailscale"
    "users"
    "virtualisation"
  ];
}
