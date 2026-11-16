#
# nightshift.nix — gammastep colour temperature (opt-in; off in homes/common.nix)
#
# Superseded on the Umbriel/Noctalia desktop by programs.noctalia nightlight
# (bar widget + location schedule). Keep this module for hosts that want
# gammastep timers instead: 3000 K at 18:00, off at 06:00.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.nightshift;
in
{
  options.${namespace}.nightshift.enable =
    lib.mkEnableOption "gammastep colour-temperature schedule";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gammastep ];

    systemd.user.services.gammastep-night = {
      Unit.Description = "Activate night shift";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'pkill gammastep || true; ${pkgs.gammastep}/bin/gammastep -O 3000 &'";
      };
    };

    systemd.user.timers.gammastep-night = {
      Unit.Description = "Activate night shift at 18:00";
      Timer = {
        OnCalendar = "*-*-* 18:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.gammastep-day = {
      Unit.Description = "Deactivate night shift";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'pkill gammastep || true'";
      };
    };

    systemd.user.timers.gammastep-day = {
      Unit.Description = "Deactivate night shift at 06:00";
      Timer = {
        OnCalendar = "*-*-* 06:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
