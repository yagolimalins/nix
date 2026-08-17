# btop + fastfetch — palette-derived themes (package group: monitoring).
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
  palette = lib.${namespace}.palette;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;
in
{
  config = lib.mkIf (cfg.enable && on "monitoring") {
    programs.btop = {
      enable = true;
      # Package comes from mine.packages.monitoring.
      package = null;
      settings = {
        color_theme = "mine-storm";
        theme_background = true;
      };
      themes.mine-storm = lib.${namespace}.mkBtopStormTheme palette;
    };

    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          color = {
            "1" = palette.accent;
            "2" = palette.cyan;
            "3" = palette.purple;
          };
          padding.right = 2;
        };
        display = {
          separator = "  ";
          color = {
            keys = palette.accent;
            title = palette.text;
            output = palette.text;
            separator = palette.muted;
          };
        };
        modules = lib.${namespace}.fastfetchDefaultModules;
      };
    };
  };
}
