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
    xdg.configFile."btop/themes/mine-storm.theme".text = lib.${namespace}.mkBtopStormTheme palette;

    xdg.configFile."btop/btop.conf".text = ''
      color_theme = "mine-storm"
      theme_background = True
    '';

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
