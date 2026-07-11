#
# networking.nix — NetworkManager
#
# Hostname comes from the flake (per-host), DNS is delegated to
# systemd-resolved (see dns.nix for the resolver/ad-blocker setup).
#
{ config, pkgs, hostName, ... }:

{
  networking = {
    hostName = hostName;
    networkmanager = {
      enable  = true;
      dns     = "systemd-resolved";
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };
}
