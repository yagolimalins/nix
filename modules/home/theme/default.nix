#
# theme — WhiteSur GTK/icons + Bibata cursor (source of truth for XCURSOR_*)
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
  cursorName = "Bibata-Modern-Classic";
  cursorSize = 24;
in
{
  options.${namespace}.theme.enable = lib.mkEnableOption "WhiteSur GTK theme + Bibata cursor";

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = cursorName;
      package = pkgs.bibata-cursors;
      size = cursorSize;
    };

    home.sessionVariables = {
      XCURSOR_THEME = cursorName;
      XCURSOR_SIZE = toString cursorSize;
    };

    wayland.windowManager.hyprland.settings.env = [
      "XCURSOR_THEME,${cursorName}"
      "XCURSOR_SIZE,${toString cursorSize}"
    ];

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
        name = cursorName;
        package = pkgs.bibata-cursors;
        size = cursorSize;
      };
      # WhiteSur GTK4 CSS lives in gtk.gresource; HM file:// import of the
      # stub gtk.css cannot see that resource.
      gtk4.theme = lib.mkForce null;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
