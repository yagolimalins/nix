#
# tailscale.nix — Tailscale VPN
#
# WireGuard-based mesh VPN. The service just brings the daemon up; run
# `sudo tailscale up` once per machine to authenticate and join the tailnet.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.tailscale;
in
{
  options.${namespace}.tailscale.enable = lib.mkEnableOption "Tailscale VPN";

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    networking.firewall.checkReversePath = "loose";
  };
}
