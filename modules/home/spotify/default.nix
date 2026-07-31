#
# spotify.nix — spotify-player (terminal client)
#
# The package, a desktop entry that opens it in kitty, and a theme
# derived from the shared colour palette below.
#
# nixos-26.05 still ships 0.23.0, which drops Spotify refresh tokens
# (https://github.com/aome510/spotify-player/issues/1040). Pin 0.24.1.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.spotify;

  p = lib.${namespace}.palette;

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
  options.${namespace}.spotify.enable = lib.mkEnableOption "spotify-player terminal client + theme";

  config = lib.mkIf cfg.enable {
    home.packages = [ spotify-player ];

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

    xdg.configFile."spotify-player/app.toml".text = ''
      theme = "mine"
      border_type = "Rounded"
    '';

    # Palette + component styles from lib.mine.palette (same as kitty/waybar).
    xdg.configFile."spotify-player/theme.toml".text = ''
      [[themes]]
      name = "mine"

      [themes.palette]
      background     = "${p.bg}"
      foreground     = "${p.text}"
      black          = "${p.bg}"
      red            = "${p.accent}"
      green          = "${p.ok}"
      yellow         = "${p.warning}"
      blue           = "${p.muted}"
      magenta        = "${p.accent}"
      cyan           = "${p.muted}"
      white          = "${p.text}"
      bright_black   = "${p.border}"
      bright_red     = "${p.urgent}"
      bright_green   = "${p.ok}"
      bright_yellow  = "${p.warning}"
      bright_blue    = "${p.text}"
      bright_magenta = "${p.urgent}"
      bright_cyan    = "${p.text}"
      bright_white   = "#ffffff"

      [themes.component_style]
      block_title                  = { fg = "${p.accent}", modifiers = ["Bold"] }
      border                       = { fg = "${p.border}" }
      playback_status              = { fg = "${p.accent}", modifiers = ["Bold"] }
      playback_track               = { fg = "${p.text}", modifiers = ["Bold"] }
      playback_artists             = { fg = "${p.muted}" }
      playback_album               = { fg = "${p.warning}" }
      playback_genres              = { fg = "${p.muted}", modifiers = ["Italic"] }
      playback_metadata            = { fg = "${p.muted}" }
      playback_progress_bar        = { fg = "${p.bg}", bg = "${p.accent}" }
      playback_progress_bar_unfilled = { bg = "${p.surface}" }
      current_playing              = { fg = "${p.accent}", modifiers = ["Bold"] }
      page_desc                    = { fg = "${p.accent}", modifiers = ["Bold"] }
      playlist_desc                = { fg = "${p.muted}", modifiers = ["Dim"] }
      table_header                 = { fg = "${p.muted}" }
      selection                    = { fg = "${p.bg}", bg = "${p.accent}", modifiers = ["Bold"] }
      secondary_row                = { bg = "${p.surface}" }
      like                         = { fg = "${p.urgent}" }
      lyrics_played                = { fg = "${p.muted}", modifiers = ["Dim"] }
      lyrics_playing               = { fg = "${p.accent}", modifiers = ["Bold"] }
    '';
  };
}
