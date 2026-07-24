#
# networking.nix — NetworkManager
#
# Hostname is set per-system in systems/x86_64-linux/<host>/default.nix;
# DNS is delegated to systemd-resolved (see dns.nix for the
# resolver/ad-blocker setup).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.networking;
in
{
  options.${namespace}.networking.enable = lib.mkEnableOption "NetworkManager (systemd-resolved DNS)";

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };
}
