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
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };
}
