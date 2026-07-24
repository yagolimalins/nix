#
# theme.nix — GTK theme, icons and cursor
#
# WhiteSur (dark) GTK3/4 theme + icons, Bibata cursor at 24px.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
in
{
  options.${namespace}.theme.enable = lib.mkEnableOption "WhiteSur GTK theme + Bibata cursor";

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-gtk-theme.override {
          colorVariants = [ "dark" ];
        };
      };
      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
      gtk4.theme = config.gtk.theme;
    };
  };
}
