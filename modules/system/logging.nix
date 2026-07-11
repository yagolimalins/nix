#
# logging.nix — systemd journal limits
#
# Caps journal disk usage so logs never fill the root partition.
#
{ ... }:

{
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';
}
