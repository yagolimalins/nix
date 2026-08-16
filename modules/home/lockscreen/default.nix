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
  accentRgb = lib.${namespace}.hexBare palette.accent;
  bgRgb = lib.${namespace}.hexBare palette.bg;
  textRgb = lib.${namespace}.hexBare palette.text;
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
            position = "0, 0";
            halign = "center";
            valign = "center";
            outline_thickness = 1;
            outer_color = "rgb(${accentRgb})";
            inner_color = "rgb(${bgRgb})";
            font_color = "rgb(${textRgb})";
            fade_on_empty = true;
            placeholder_text = "";
            rounding = 6;
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
