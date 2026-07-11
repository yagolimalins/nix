#
# power.nix — CPU power policy
#
# Defaults to the 'powersave' governor and ships a small setuid-free
# toggle script (flipped between powersave/performance) that the Waybar
# button invokes through a passwordless sudo rule.
#
{ config, pkgs, username, ... }:

{
  powerManagement.cpuFreqGovernor = "powersave";

  environment.etc."cpugov-toggle" = {
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

  security.sudo.extraRules = [{
    users    = [ username ];
    commands = [{
      command = "/etc/cpugov-toggle";
      options = [ "NOPASSWD" ];
    }];
  }];
}
