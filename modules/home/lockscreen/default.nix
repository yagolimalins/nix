#
# lockscreen — hyprlock + hypridle (idle/sleep) + Hyprland autostart
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.lockscreen;
  palette = lib.${namespace}.palette;
  accentRgb = builtins.substring 1 6 palette.accent;
  bgRgb = builtins.substring 1 6 palette.bg;
  textRgb = builtins.substring 1 6 palette.text;
in
{
  options.${namespace}.lockscreen.enable = lib.mkEnableOption "hyprlock + hypridle screen locking";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [ "hypridle" ];

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          grace = 0;
        };

        background = [
          {
            path = config.${namespace}.user.wallpaper;
            blur_passes = 0;
            brightness = 0.4;
          }
        ];

        input-field = [
          {
            size = "300, 40";
            position = "0, -60";
            halign = "center";
            valign = "center";
            outline_thickness = 1;
            outer_color = "rgb(${accentRgb})";
            inner_color = "rgb(${bgRgb})";
            font_color = "rgb(${textRgb})";
            fade_on_empty = false;
            placeholder_text = "";
            rounding = 4;
          }
        ];

        label = [
          {
            text = "$TIME";
            font_family = "JetBrains Mono";
            font_size = 48;
            color = "rgba(${textRgb}, 1.0)";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprlock";
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }
        ];
      };
    };
  };
}
