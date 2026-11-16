#
# power.nix — CPU power profiles
#
# power-profiles-daemon backs Noctalia's Power Profile widget (performance /
# balanced / power-saver). Off on hosts that run TLP, which owns the governor.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.power;
in
{
  options.${namespace}.power.enable = lib.mkEnableOption "CPU power profiles (power-profiles-daemon)";

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = lib.mkDefault (!config.services.tlp.enable);

    # The unit ships without an [Install] section, so NixOS only exposes it for
    # D-Bus activation, which never fires here. Pull it in explicitly.
    systemd.services.power-profiles-daemon.wantedBy = lib.mkIf config.services.power-profiles-daemon.enable [
      "multi-user.target"
    ];
  };
}
