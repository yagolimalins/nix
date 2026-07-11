#
# nightshift.nix — hyprsunset colour temperature
#
# Warms the screen to 3000 K at 18:00 and reverts at 06:00 via systemd
# user timers. Can also be toggled manually from the Waybar button.
#
{ config, pkgs, ... }:

{
  home.packages = [ pkgs.hyprsunset ];

  systemd.user.services.hyprsunset-night = {
    Unit.Description = "Activate night shift";
    Service = {
      Type      = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'pkill hyprsunset || true; ${pkgs.hyprsunset}/bin/hyprsunset -t 3000 &'";
    };
  };

  systemd.user.timers.hyprsunset-night = {
    Unit.Description = "Activate night shift at 18:00";
    Timer = {
      OnCalendar = "*-*-* 18:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.hyprsunset-day = {
    Unit.Description = "Deactivate night shift";
    Service = {
      Type      = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'pkill hyprsunset || true'";
    };
  };

  systemd.user.timers.hyprsunset-day = {
    Unit.Description = "Deactivate night shift at 06:00";
    Timer = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
