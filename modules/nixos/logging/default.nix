#
# logging.nix — systemd journal limits
#
# Caps journal disk usage so logs never fill the root partition.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.logging;
in
{
  options.${namespace}.logging.enable = lib.mkEnableOption "systemd journal size/retention limits";

  config = lib.mkIf cfg.enable {
    services.journald.extraConfig = ''
      SystemMaxUse=100M
      SystemMaxFileSize=50M
      MaxRetentionSec=7day
    '';
  };
}
