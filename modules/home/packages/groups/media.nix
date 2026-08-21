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
  p = lib.${namespace}.palette;
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

  # nixos-26.05 ships 0.23.0, which drops Spotify refresh tokens
  # (https://github.com/aome510/spotify-player/issues/1040). Pin 0.24.1.
  spotify-player = pkgs.spotify-player.overrideAttrs (
    old:
    let
      version = "0.24.1";
      src = pkgs.fetchFromGitHub {
        owner = "aome510";
        repo = "spotify-player";
        tag = "v${version}";
        hash = "sha256-+GADmRl4XMwV8TfYZjEeyKDDfda3bDPzeerhYryX6vA=";
      };
      cargoHash = "sha256-CSZ5sZ+d7Jhi43ipaWXKupYPFgWCbCx4RMTQN8emu9o=";
    in
    {
      inherit version src cargoHash;
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        name = "${old.pname}-${version}";
        hash = cargoHash;
      };
    }
  );
in
{
  config = lib.mkMerge [
    (lib.mkIf (on "media") {
      home.packages = with pkgs; [
        vlc
        popcorntime
      ];

      programs.spotify-player = {
        enable = true;
        package = spotify-player;
        settings = {
          theme = "mine";
          border_type = "Rounded";
        };
        themes = [
          {
            name = "mine";
            palette = {
              background = p.bg;
              foreground = p.text;
              black = p.border;
              red = p.urgent;
              green = p.ok;
              yellow = p.warning;
              blue = p.accent;
              magenta = p.purple;
              cyan = p.cyan;
              white = p.text;
              bright_black = p.muted;
              bright_red = p.urgent;
              bright_green = p.ok;
              bright_yellow = p.warning;
              bright_blue = p.accent;
              bright_magenta = p.purple;
              bright_cyan = p.cyan;
              bright_white = p.text;
            };
            component_style = {
              block_title = {
                fg = p.accent;
                modifiers = [ "Bold" ];
              };
              border = {
                fg = p.border;
              };
              playback_status = {
                fg = p.accent;
                modifiers = [ "Bold" ];
              };
              playback_track = {
                fg = p.text;
                modifiers = [ "Bold" ];
              };
              playback_artists = {
                fg = p.muted;
              };
              playback_album = {
                fg = p.warning;
              };
              playback_genres = {
                fg = p.muted;
                modifiers = [ "Italic" ];
              };
              playback_metadata = {
                fg = p.muted;
              };
              playback_progress_bar = {
                fg = p.bg;
                bg = p.accent;
              };
              playback_progress_bar_unfilled = {
                bg = p.surface;
              };
              current_playing = {
                fg = p.accent;
                modifiers = [ "Bold" ];
              };
              page_desc = {
                fg = p.accent;
                modifiers = [ "Bold" ];
              };
              playlist_desc = {
                fg = p.muted;
                modifiers = [ "Dim" ];
              };
              table_header = {
                fg = p.muted;
              };
              selection = {
                fg = p.onAccent;
                bg = p.accent;
                modifiers = [ "Bold" ];
              };
              secondary_row = {
                bg = p.surface;
              };
              like = {
                fg = p.urgent;
              };
              lyrics_played = {
                fg = p.muted;
                modifiers = [ "Dim" ];
              };
              lyrics_playing = {
                fg = p.accent;
                modifiers = [ "Bold" ];
              };
            };
          }
        ];
      };

      xdg.desktopEntries.spotify-player = {
        name = "Spotify";
        exec = "kitty spotify_player";
        icon = "spotify";
        comment = "Terminal Spotify client";
        categories = [
          "Audio"
          "Music"
          "Player"
        ];
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
