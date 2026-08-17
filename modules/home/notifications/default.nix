#
# notifications — Mako + Hyprland autostart
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.notifications;
  palette = lib.${namespace}.palette;
in
{
  options.${namespace}.notifications.enable = lib.mkEnableOption "Mako notification daemon";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [ "mako" ];

    services.mako = {
      enable = true;
      settings = {
        font = "FiraCode Nerd Font Mono 14";
        "background-color" = palette.bg;
        "border-color" = palette.accent;
        "text-color" = palette.text;
        "border-size" = 1;
        "border-radius" = 6;
        "default-timeout" = 5000;
        padding = "10,14";
        width = 320;
        icons = true;
      };
    };
  };
}
