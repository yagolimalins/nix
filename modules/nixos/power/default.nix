#
# power.nix — CPU governor toggle
#
# This machine has no kernel platform profile, so power-profiles-daemon only
# offers placeholder profiles and Noctalia hides its Power Profile widget.
# Defaults to the 'powersave' governor and ships a toggle script (flipped
# between powersave/performance) that the Umbriel Mod+Shift+P bind invokes
# through a passwordless sudo rule, granted to every user Snowfall Lib has
# declared for this host (see homes/). Off on hosts that run TLP, which owns
# the governor.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.power;
  managed = !config.services.tlp.enable;
in
{
  options.${namespace}.power.enable = lib.mkEnableOption "CPU governor toggle (powersave/performance)";

  config = lib.mkIf cfg.enable {
    powerManagement.cpuFreqGovernor = lib.mkIf managed "powersave";

    environment.etc."cpugov-toggle" = lib.mkIf managed {
      mode = "0755";
      text = ''
        #!/bin/sh
        GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        case $GOV in
          performance) NEXT=powersave ;;
          *)           NEXT=performance ;;
        esac
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo "$NEXT" > "$f"
        done
      '';
    };

    security.sudo.extraRules = lib.mkIf managed [
      {
        users = lib.attrNames config.snowfallorg.users;
        commands = [
          {
            command = "/etc/cpugov-toggle";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
