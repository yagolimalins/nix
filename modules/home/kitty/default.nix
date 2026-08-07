#
# kitty — Terminal (Tokyo Night Storm palette)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.kitty;
  palette = lib.${namespace}.palette;
in
{
  options.${namespace}.kitty.enable =
    lib.mkEnableOption "Kitty terminal (FiraCode Nerd Font, Tokyo Night Storm)";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode Nerd Font Mono";
        size = 14;
      };
      settings = {
        foreground = palette.text;
        background = palette.bg;
        selection_foreground = palette.onAccent;
        selection_background = palette.accent;
        cursor = palette.accent;
        cursor_text_color = palette.onAccent;
        url_color = palette.accent;

        color0 = palette.border;
        color8 = palette.muted;
        color1 = palette.urgent;
        color9 = palette.urgent;
        color2 = palette.ok;
        color10 = palette.ok;
        color3 = palette.warning;
        color11 = palette.warning;
        color4 = palette.accent;
        color12 = palette.accent;
        color5 = palette.purple;
        color13 = palette.purple;
        color6 = palette.cyan;
        color14 = palette.cyan;
        color7 = palette.text;
        color15 = palette.text;

        window_padding_width = 12;

        confirm_os_window_close = 0;
        enable_audio_bell = false;
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";
        scrollback_lines = 10000;

        tab_bar_style = "powerline";
        tab_bar_background = palette.bg;
        tab_bar_margin_height = "0 0";
        active_tab_foreground = palette.onAccent;
        active_tab_background = palette.accent;
        active_tab_font_style = "bold";
        inactive_tab_foreground = palette.muted;
        inactive_tab_background = palette.surface;
      };
    };
  };
}
