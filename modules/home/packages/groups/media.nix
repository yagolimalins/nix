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
  on = lib.${namespace}.packageGroupOn cfg;
  profileLib = "${config.home.profileDirectory}/lib";
  home = config.home.homeDirectory;

  pluginPathVars = {
    LV2_PATH = "${profileLib}/lv2:${home}/.lv2:/usr/lib/lv2:/usr/local/lib/lv2";
    VST_PATH = "${profileLib}/vst:${home}/.vst:/usr/lib/vst:/usr/local/lib/vst";
    LXVST_PATH = "${profileLib}/vst:${home}/.lxvst:/usr/lib/lxvst:/usr/local/lib/lxvst";
    VST3_PATH = "${profileLib}/vst3:${home}/.vst3:/usr/lib/vst3:/usr/local/lib/vst3";
    CLAP_PATH = "${profileLib}/clap:${home}/.clap:/usr/lib/clap:/usr/local/lib/clap";
    LADSPA_PATH = "${profileLib}/ladspa:${home}/.ladspa:/usr/lib/ladspa:/usr/local/lib/ladspa";
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf (on "media") {
      home.packages = with pkgs; [
        vlc
        popcorntime
        pkgs.${namespace}.spotifast
      ];

      # Same entry the package ships, but with the Spotify icon instead of spotifast's own.
      xdg.desktopEntries.spotifast = {
        name = "Spotifast";
        genericName = "Music Player";
        comment = "A native Spotify client";
        exec = "spotifast %u";
        icon = "spotify";
        terminal = false;
        startupNotify = true;
        categories = [
          "AudioVideo"
          "Audio"
          "Player"
          "Music"
        ];
        mimeType = [ "x-scheme-handler/spotify" ];
        settings = {
          StartupWMClass = "spotifast";
          Keywords = "spotify;music;player;streaming;spotifast;";
        };
      };
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

      # Carla links jack2; pw-jack puts PipeWire's libjack first (same as REAPER).
      xdg.desktopEntries.carla = {
        name = "Carla";
        exec = "pw-jack carla %U";
        icon = "carla";
        comment = "Audio plugin host";
        categories = [
          "AudioVideo"
          "Audio"
        ];
        mimeType = [ "application/x-carla-project" ];
      };

      home.packages = with pkgs; [
        reaper
        qpwgraph
        carla
        lsp-plugins
        alsa-utils
      ];

      home.sessionVariables = pluginPathVars;

      wayland.windowManager.hyprland.settings.env = lib.mapAttrsToList (
        name: value: "${name},${value}"
      ) pluginPathVars;

      # Carla and REAPER scan ~/.lv2 ~/.vst ~/.vst3, not the Nix profile.
      home.file = {
        ".lv2/lsp-plugins.lv2".source = "${pkgs.lsp-plugins}/lib/lv2/lsp-plugins.lv2";
        ".vst/lsp-plugins.vst".source = "${pkgs.lsp-plugins}/lib/vst/lsp-plugins.vst";
        ".vst3/lsp-plugins.vst3".source = "${pkgs.lsp-plugins}/lib/vst3/lsp-plugins.vst3";
        ".clap/lsp-plugins.clap".source = "${pkgs.lsp-plugins}/lib/clap/lsp-plugins.clap";
        ".ladspa/lsp-plugins-ladspa.so".source = "${pkgs.lsp-plugins}/lib/ladspa/lsp-plugins-ladspa.so";
      };
    })
  ];
}
