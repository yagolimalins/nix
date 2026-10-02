#
# printing.nix — CUPS printing
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.printing;
in
{
  options.${namespace}.printing.enable = lib.mkEnableOption "CUPS printing";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
    programs.system-config-printer.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
