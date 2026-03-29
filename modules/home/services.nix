{ config, pkgs, ... }:

let
  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in

{
  ############################################################
  # Waybar — status bar (auto-restarts on crash)
  ############################################################

  systemd.user.services.waybar = {
    Unit.Description = "Waybar status bar";
    Service = {
      ExecStart  = "${pkgs.waybar}/bin/waybar";
      Restart    = "on-failure";
      RestartSec = "1s";
    };
  };

  ############################################################
  # Mako — desktop notifications
  ############################################################

  services.mako = {
    enable   = true;
    settings = {
      font              = "JetBrainsMono Nerd Font 14";
      "background-color" = "#0d0d0d";
      "border-color"    = "#cc2222";
      "text-color"      = "#dedede";
      "border-size"     = 1;
      "border-radius"   = 3;
      "default-timeout" = 5000;
      padding           = "10,14";
      width             = 320;
      icons             = true;
    };
  };

  ############################################################
  # Hyprlock — screen locker
  ############################################################

  programs.hyprlock = {
    enable   = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor         = true;
        grace               = 0;
      };

      background = [{
        path        = wallpaper;
        blur_passes = 0;
        brightness  = 0.4;
      }];

      input-field = [{
        size              = "300, 40";
        position          = "0, -60";
        halign            = "center";
        valign            = "center";
        outline_thickness = 1;
        outer_color       = "rgb(cc2222)";
        inner_color       = "rgb(0d0d0d)";
        font_color        = "rgb(dedede)";
        fade_on_empty     = false;
        placeholder_text  = "";
        rounding          = 4;
      }];

      label = [{
        text        = "$TIME";
        font_family = "JetBrains Mono";
        font_size   = 48;
        color       = "rgba(dedede, 1.0)";
        position    = "0, 80";
        halign      = "center";
        valign      = "center";
      }];
    };
  };

  ############################################################
  # Hypridle — idle management
  ############################################################

  services.hypridle = {
    enable   = true;
    settings = {
      general = {
        lock_cmd        = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };

      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        { timeout = 600; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  ############################################################
  # Hyprsunset — night shift
  # Activated automatically via systemd timers (18:00 on, 06:00 off).
  # Can also be toggled manually from the Waybar button.
  ############################################################

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
