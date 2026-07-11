#
# lockscreen.nix — Screen locking and idle handling
#
# hyprlock draws the lock screen; hypridle locks after 5 min idle and
# also locks right before sleep so the machine always wakes locked.
#
{ config, pkgs, ... }:

let
  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in

{
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

  services.hypridle = {
    enable   = true;
    settings = {
      general = {
        lock_cmd         = "hyprlock";
        before_sleep_cmd = "hyprlock";                # lock before the machine suspends
        after_sleep_cmd  = "hyprctl dispatch dpms on"; # wake the display on resume
      };

      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
      ];
    };
  };
}
