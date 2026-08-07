# Zathura — Storm UI chrome only; document colors stay original (package group: viewers).
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
  config = lib.mkIf (cfg.enable && on "viewers") {
    programs.zathura = {
      enable = true;
      options = {
        recolor = false;
        "default-bg" = palette.bg;
        "default-fg" = palette.text;
        "statusbar-bg" = palette.surface;
        "statusbar-fg" = palette.text;
        "highlight-color" = palette.accent;
        "highlight-active-color" = palette.cyan;
        "index-bg" = palette.surface;
        "index-fg" = palette.muted;
      };
    };
  };
}
