#
# display.nix — Display stack and login
#
# Hyprland as the compositor, greetd/tuigreet as the TTY greeter, and the
# XDG portal for screen sharing / file pickers. Lid and power-key handling
# is delegated to logind (Hyprland reacts to the lid itself).
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

  gtkPortalForHyprland = pkgs.writeTextDir "share/xdg-desktop-portal/portals/gtk-hyprland.portal" ''
    [portal]
    DBusName=org.freedesktop.impl.portal.desktop.gtk
    Interfaces=org.freedesktop.impl.portal.FileChooser;org.freedesktop.impl.portal.AppChooser;org.freedesktop.impl.portal.Print;org.freedesktop.impl.portal.Notification;org.freedesktop.impl.portal.Inhibit;org.freedesktop.impl.portal.Access;org.freedesktop.impl.portal.Account;org.freedesktop.impl.portal.Email;org.freedesktop.impl.portal.DynamicLauncher;org.freedesktop.impl.portal.Lockdown;org.freedesktop.impl.portal.Settings;org.freedesktop.impl.portal.Wallpaper;
    UseIn=Hyprland
  '';
in
{
  options.${namespace}.display.enable =
    lib.mkEnableOption "Hyprland display stack (greetd, xdg portal, logind)";

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    # logind stays out of the lid event; Hyprland binds it (see hyprland.nix).
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
            --theme "border=#cc2222;text=#dedede;prompt=#7a7a7a;time=#dedede;action=#7a7a7a;button=#171717;container=#171717;input=#dedede"
        '';
        user = "greeter";
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        gtkPortalForHyprland
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
