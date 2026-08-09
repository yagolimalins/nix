#
# display — System Hyprland stack (greetd, portals, logind)
#
# Pairs with HM mine.hyprland. Not the file-manager "desktop" module.
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
  gtkPortal = lib.${namespace}.mkGtkHyprlandPortal pkgs;
  palette = lib.${namespace}.palette;
  # tuigreet only accepts ANSI names; console.colors remaps VT 0–15 to Storm.
  strip = lib.removePrefix "#";
  tuigreetTheme = lib.concatStringsSep ";" [
    "border=lightblue" # accent
    "title=lightblue"
    "text=white" # text
    "greet=lightcyan" # cyan
    "time=lightcyan"
    "prompt=darkgray" # muted (gray is ANSI 7 / white in ratatui)
    "action=darkgray"
    "button=lightblue"
    "container=black" # bg
    "input=white"
  ];
in
{
  options.${namespace}.display.enable =
    lib.mkEnableOption "Hyprland display stack (greetd, xdg portal, logind)";

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    # Lid handled in Hyprland; logind must ignore it.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "suspend";
    };

    # ANSI 0–15 → Storm (color0 = bg so tuigreet container=black is the Storm background).
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

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --remember-session \
            --greeting "  ${config.networking.hostName}" \
            --asterisks \
            --cmd "start-hyprland &>/dev/null" \
            --theme '${tuigreetTheme}'
        '';
        user = "greeter";
      };
    };

    # Hyprland: screencast; gtk-hyprland: Settings/Inhibit (stock gtk is UseIn=gnome).
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        gtkPortal
      ];
      config.common = {
        default = [
          "hyprland"
          "gtk-hyprland"
        ];
        "org.freedesktop.impl.portal.Settings" = "gtk-hyprland";
        "org.freedesktop.impl.portal.Inhibit" = "gtk-hyprland";
      };
    };
  };
}
