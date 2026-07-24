#
# spotify.nix — spotify-player (terminal client)
#
# The package, a desktop entry that opens it in kitty, and a theme
# derived from the shared colour palette below.
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

  palette = {
    bg = "#0d0d0d";
    fg = "#dedede";
    red = "#cc2222";
    red-bright = "#e03333";
    muted = "#777777";
    grey = "#aaaaaa";
    white = "#ffffff";
  };
in
{
  options.${namespace}.spotify.enable = lib.mkEnableOption "spotify-player terminal client + theme";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.spotify-player ];

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
      [app_config]
      theme = "default"
    '';

    xdg.configFile."spotify-player/theme.toml".text = ''
      [[themes]]
      name = "default"
      [themes.palette]
      background     = "${palette.bg}"
      foreground     = "${palette.fg}"
      black          = "${palette.bg}"
      red            = "${palette.red}"
      green          = "${palette.red}"
      yellow         = "${palette.fg}"
      blue           = "${palette.grey}"
      magenta        = "${palette.red}"
      cyan           = "${palette.grey}"
      white          = "${palette.fg}"
      bright_black   = "${palette.muted}"
      bright_red     = "${palette.red-bright}"
      bright_green   = "${palette.red-bright}"
      bright_yellow  = "${palette.white}"
      bright_blue    = "#cccccc"
      bright_magenta = "${palette.red-bright}"
      bright_cyan    = "#cccccc"
      bright_white   = "${palette.white}"
    '';
  };
}
