#
# fuzzel — Fast wlroots launcher (drun + Waybar power menu dmenu)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.fuzzel;
  palette = lib.${namespace}.palette;
  hex =
    color: alpha:
    let
      rgb = lib.removePrefix "#" color;
    in
    "${rgb}${alpha}";
in
{
  options.${namespace}.fuzzel.enable = lib.mkEnableOption "Fuzzel application launcher";

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=13";
          dpi-aware = "no";
          terminal = "kitty";
          layer = "overlay";
          width = 32;
          lines = 10;
          horizontal-pad = 10;
          vertical-pad = 8;
          inner-pad = 4;
          line-height = 22;
          icon-theme = "WhiteSur-dark";
          icons-enabled = "yes";
          scaling-filter = "lanczos3";
        };
        colors = {
          background = hex palette.bg "ff";
          text = hex palette.text "ff";
          match = hex palette.accent "ff";
          selection = hex palette.surface "ff";
          selection-text = hex palette.accent "ff";
          selection-match = hex palette.accent "ff";
          border = hex palette.accent "ff";
        };
        border = {
          width = 1;
          radius = 4;
        };
      };
    };

    # Imperative/previous generations leave a real file; let HM replace it.
    xdg.configFile."fuzzel/fuzzel.ini".force = true;
  };
}
