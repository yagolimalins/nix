{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.databases.enable {
      home.packages = with pkgs; [
        dbeaver-bin
        beekeeper-studio
      ];
    })

    (lib.mkIf cfg.api.enable {
      home.packages = [ pkgs.insomnia ];
    })

    (lib.mkIf cfg.office.enable {
      home.packages = [ pkgs.libreoffice-fresh ];
    })

    (lib.mkIf cfg.notes.enable {
      home.packages = with pkgs; [
        marktext
        glow
      ];
    })

    (lib.mkIf cfg.learning.enable {
      home.packages = [ pkgs.anki ];
    })

    (lib.mkIf cfg.browsers.enable {
      home.packages = [ pkgs.chromium ];
    })

    (lib.mkIf cfg.proton.enable {
      home.packages = with pkgs; [
        proton-vpn
        proton-pass
        protonmail-bridge
      ];
    })

    (lib.mkIf cfg.mail.enable {
      home.packages = [ pkgs.thunderbird ];
    })

    (lib.mkIf cfg.communication.enable {
      home.packages = with pkgs; [
        zoom-us
        discord
        telegram-desktop
      ];
    })
  ];
}
