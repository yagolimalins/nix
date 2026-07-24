#
# mail.nix — Proton Mail Bridge
#
# Runs the bridge headless as a user service so local mail clients can
# talk to Proton over IMAP/SMTP. Waits for the keyring to be up first.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.mail;
in
{
  options.${namespace}.mail.enable = lib.mkEnableOption "Proton Mail Bridge user service";

  config = lib.mkIf cfg.enable {
    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge";
        After = [
          "network-online.target"
          "gnome-keyring-daemon.service"
        ];
        Wants = [ "gnome-keyring-daemon.service" ];
      };
      Service = {
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
        Restart = "on-failure";
        RestartSec = "5";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
