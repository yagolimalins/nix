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
    (lib.mkIf cfg.media.enable {
      home.packages = with pkgs; [
        vlc
        popcorntime
      ];
    })

    (lib.mkIf cfg.creator.enable {
      home.packages = with pkgs; [
        obs-studio
        kdePackages.kdenlive
      ];
    })

    (lib.mkIf cfg.audio.enable {
      xdg.desktopEntries.reaper = {
        name = "REAPER";
        exec = "pw-jack reaper %U";
        icon = "cockos-reaper";
        comment = "Digital Audio Workstation";
        categories = [
          "Audio"
          "AudioVideo"
        ];
      };

      xdg.desktopEntries."cockos-reaper" = {
        name = "REAPER";
        exec = "pw-jack reaper %U";
        noDisplay = true;
      };

      home.packages = with pkgs; [
        reaper
        qpwgraph
        carla
        alsa-utils
      ];
    })
  ];
}
