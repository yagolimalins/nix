# Package group: media, creator, audio (gated by mine.packages.enable).
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
    (lib.mkIf (on "media") {
      home.packages = with pkgs; [
        vlc
        popcorntime
      ];
    })

    (lib.mkIf (on "creator") {
      home.packages = with pkgs; [
        obs-studio
        kdePackages.kdenlive
      ];
    })

    (lib.mkIf (on "audio") {
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
