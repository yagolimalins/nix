#
# theme — Tokyo Night Storm GTK + WhiteSur icons + Bibata Ice cursor
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
  palette = lib.${namespace}.palette;
  cursorName = "Bibata-Modern-Ice";
  cursorSize = 24;

  gtkTheme = pkgs.tokyonight-gtk-theme.override {
    tweakVariants = [ "storm" ];
  };

  gtkThemeConfig = {
    name = "Tokyonight-Dark-Storm";
    package = gtkTheme;
  };

  # Storm GTK uses cyan for selection; force accent to match Waybar/Kitty/Fuzzel.
  gtkSelectionCss = ''
    @define-color theme_selected_bg_color ${palette.accent};
    @define-color theme_selected_fg_color ${palette.onAccent};
    @define-color accent_bg_color ${palette.accent};
    @define-color accent_color ${palette.accent};

    .view:selected,
    .view:selected:focus,
    iconview:selected,
    iconview:selected:focus,
    treeview:selected,
    treeview:selected:focus,
    row:selected,
    row:selected:focus {
      background-color: ${palette.accent};
      color: ${palette.onAccent};
    }

    .thunar .sidebar treeview:selected,
    .thunar .sidebar treeview:selected:focus,
    .thunar .sidebar row:selected,
    .thunar .sidebar row:selected:focus {
      background-color: ${palette.accent};
      color: ${palette.onAccent};
    }
  '';
in
{
  options.${namespace}.theme.enable =
    lib.mkEnableOption "Tokyo Night Storm GTK theme + WhiteSur icons + Bibata Ice cursor";

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
      theme = gtkThemeConfig;
      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme;
      };
      cursorTheme = {
        name = cursorName;
        package = pkgs.bibata-cursors;
        size = cursorSize;
      };
      gtk3.extraCss = gtkSelectionCss;
      gtk4 = {
        theme = gtkThemeConfig;
        extraCss = gtkSelectionCss;
      };
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
