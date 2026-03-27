{ config, pkgs, ... }:

{
  ############################################################
  # Kitty terminal
  ############################################################

  programs.kitty = {
    enable = true;
    font   = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
    settings = {
      foreground           = "#dedede";
      background           = "#0d0d0d";
      selection_foreground = "#0d0d0d";
      selection_background = "#cc2222";
      cursor               = "#cc2222";
      cursor_text_color    = "#0d0d0d";
      url_color            = "#cc2222";

      # Terminal color palette (tango-dark base)
      color0  = "#2e2e2e"; color8  = "#555753"; # Black
      color1  = "#cc0000"; color9  = "#ef2929"; # Red
      color2  = "#4e9a06"; color10 = "#8ae234"; # Green
      color3  = "#c4a000"; color11 = "#fce94f"; # Yellow
      color4  = "#3465a4"; color12 = "#729fcf"; # Blue
      color5  = "#75507b"; color13 = "#ad7fa8"; # Magenta
      color6  = "#06989a"; color14 = "#34e2e2"; # Cyan
      color7  = "#d3d7cf"; color15 = "#eeeeec"; # White

      window_padding_width = 12;

      confirm_os_window_close = 0;
      enable_audio_bell       = false;
      cursor_shape            = "beam";
      cursor_blink_interval   = "0.5";
      scrollback_lines        = 10000;

      tab_bar_style           = "separator";
      tab_separator           = "  │  ";
      tab_bar_background      = "#0a0a0a";
      active_tab_foreground   = "#cc2222";
      active_tab_background   = "#0d0d0d";
      active_tab_font_style   = "bold";
      inactive_tab_foreground = "#444444";
      inactive_tab_background = "#0d0d0d";
    };
  };

  ############################################################
  # Bash prompt
  ############################################################

  programs.bash = {
    enable    = true;
    initExtra = ''
      PS1='\[\e[1;31m\][\u@\h:\w]\$\[\e[0m\] '
    '';
  };
}
