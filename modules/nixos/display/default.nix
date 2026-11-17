#
# display — Umbriel + noctalia-greeter (greetd, portals, logind)
#
# Pairs with HM mine.umbriel + mine.noctalia. Not the file-manager "desktop" module.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.display;
  palette = lib.${namespace}.palette;
  cursor = lib.${namespace}.cursorTheme;
  strip = lib.removePrefix "#";
in
{
  options.${namespace}.display.enable =
    lib.mkEnableOption "Umbriel display stack (noctalia-greeter, portals, logind)";

  config = lib.mkIf cfg.enable {
    programs.umbriel.enable = true;

    # Lid policy left to Umbriel events; logind must not suspend on close.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "suspend";
    };

    # VT palette still Storm for TTY recovery.
    console.colors = map strip [
      palette.bg
      palette.urgent
      palette.ok
      palette.warning
      palette.accent
      palette.purple
      palette.cyan
      palette.text
      palette.muted
      palette.urgent
      palette.ok
      palette.warning
      palette.accent
      palette.purple
      palette.cyan
      palette.text
    ];

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        session.default = "Umbriel";
        appearance = {
          scheme = "Synced";
          theme_mode = "dark";
          font_family = "Inter";
          corner_radius_scale = 0.6;
          hide_logo = true;
          scheme_selector_position = "hidden";
          palette = {
            primary = palette.accent;
            on_primary = palette.onAccent;
            secondary = palette.cyan;
            on_secondary = palette.onAccent;
            tertiary = palette.purple;
            on_tertiary = palette.onAccent;
            error = palette.urgent;
            on_error = palette.onAccent;
            surface = palette.bg;
            on_surface = palette.text;
            surface_variant = palette.surface;
            on_surface_variant = palette.muted;
            outline = palette.border;
            shadow = palette.bg;
            hover = palette.accent;
            on_hover = palette.onAccent;
          };
          wallpaper = {
            fill_color = palette.bg;
            fill_mode = "crop";
          };
        };
        cursor = {
          theme = cursor.name;
          size = cursor.size;
          path = pkgs.bibata-cursors;
        };
        keyboard.layout = "br";
      };
    };

    # Umbriel NixOS module already sets portal defaults; keep gtk for Settings/FileChooser.
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.umbriel = {
        default = [
          "umbriel"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };
}
