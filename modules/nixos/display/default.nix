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
            --theme 'border=lightblue;text=lightcyan;prompt=gray;time=lightcyan;action=gray;button=black;container=black;input=lightcyan'
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
