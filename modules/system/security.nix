{ config, pkgs, username, ... }:

{
  ############################################################
  # CPU governor toggle script
  # Toggles between 'performance' and 'powersave'.
  # Called by Waybar via sudo (passwordless rule below).
  ############################################################

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
    users = [ username ];
    commands = [{
      command = "/etc/cpugov-toggle";
      options = [ "NOPASSWD" ];
    }];
  }];
}
