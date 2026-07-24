#
# printing.nix — CUPS printing
#
{
  config,
  lib,
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
  };
}
