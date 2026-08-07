# GTK/Qt, cursor, and selection CSS — Tokyo Night Storm desktop shell.
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
  cursor = lib.${namespace}.cursorTheme;

  gtkTheme = pkgs.tokyonight-gtk-theme.override {
    tweakVariants = [ "storm" ];
  };

  gtkThemeConfig = {
    name = lib.${namespace}.gtkStormThemeName;
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
  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = cursor.name;
      package = pkgs.bibata-cursors;
      size = cursor.size;
    };

    home.sessionVariables = {
      XCURSOR_THEME = cursor.name;
      XCURSOR_SIZE = toString cursor.size;
    };

    wayland.windowManager.hyprland.settings.env = [
      "XCURSOR_THEME,${cursor.name}"
      "XCURSOR_SIZE,${toString cursor.size}"
    ];

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };

    gtk = {
      enable = true;
      theme = gtkThemeConfig;
      iconTheme = {
        name = lib.${namespace}.numixSquareThemeName;
        package = pkgs.${namespace}.numix-square-storm;
      };
      cursorTheme = {
        name = cursor.name;
        package = pkgs.bibata-cursors;
        size = cursor.size;
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
