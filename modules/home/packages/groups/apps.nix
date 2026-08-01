# Package group: databases … communication (gated by mine.packages.enable).
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  on = group: cfg.enable && cfg.${group}.enable;
in
{
  config = lib.mkMerge [
    (lib.mkIf (on "databases") {
      home.packages = with pkgs; [
        dbeaver-bin
        beekeeper-studio
      ];
    })

    (lib.mkIf (on "api") {
      home.packages = [ pkgs.insomnia ];
    })

    (lib.mkIf (on "office") {
      home.packages = [ pkgs.libreoffice-fresh ];
    })

    (lib.mkIf (on "notes") {
      home.packages = with pkgs; [
        marktext
        glow
      ];
    })

    (lib.mkIf (on "learning") {
      home.packages = [ pkgs.anki ];
    })

    (lib.mkIf (on "browsers") {
      home.packages = [ pkgs.chromium ];
    })

    (lib.mkIf (on "proton") {
      home.packages = with pkgs; [
        proton-vpn
        proton-pass
        protonmail-bridge
      ];

      xdg.dataFile."icons/hicolor/48x48/apps/proton-pass.png".source =
        "${pkgs.proton-pass}/share/proton-pass/assets/logo.png";

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
    })

    (lib.mkIf (on "mail") {
      home.packages = [ pkgs.thunderbird ];
    })

    (lib.mkIf (on "communication") {
      home.packages = with pkgs; [
        zoom-us
        discord
        telegram-desktop
      ];
    })
  ];
}
