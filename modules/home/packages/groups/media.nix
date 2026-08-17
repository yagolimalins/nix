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

      home.packages = with pkgs; [
        reaper
        qpwgraph
        carla
        alsa-utils
      ];
    })
  ];
}
