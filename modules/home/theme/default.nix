# WhiteSur GTK/icons + Bibata cursor; portal color-scheme for Firefox/etc.
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
      # WhiteSur GTK4 CSS lives in gtk.gresource; HM file:// import of the
      # stub gtk.css cannot see that resource.
      gtk4.theme = lib.mkForce null;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
