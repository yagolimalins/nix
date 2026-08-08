#
# helix — Tokyo Night Storm + ABNT2 navigation (JKLÇ)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.helix;
  themeCfg = config.${namespace}.theme;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;

  # Shift hjkl one key right on ABNT2: j/k/l/ç = ← ↓ ↑ →
  abnt2Dirs = {
    left,
    down,
    up,
    right,
  }: {
    h = "no_op";
    j = left;
    k = down;
    l = up;
    "ç" = right;
  };

  # Hide arrow keys; view mode also drops default Ctrl-hjkl scroll aliases
  abnt2LegacyArrows = {
    left = "no_op";
    right = "no_op";
    up = "no_op";
    down = "no_op";
  };

  abnt2LegacyView =
    abnt2LegacyArrows
    // {
      "C-h" = "no_op";
      "C-j" = "no_op";
      "C-k" = "no_op";
      "C-l" = "no_op";
    };

  abnt2LegacyWindow =
    abnt2LegacyArrows
    // {
      "C-h" = "no_op";
      H = "no_op";
      J = "no_op";
      K = "no_op";
      L = "no_op";
    };

  abnt2Vertical = {
    down,
    up,
  }: {
    h = "no_op";
    j = "no_op"; # default scroll_down, superseded by k
    k = down;
    l = up;
  } // abnt2LegacyView;

  # Ctrl + same key as jump: swap instead (reliable on ABNT2 vs Shift)
  abnt2Swap = {
    left,
    down,
    up,
    right,
  }: {
    H = "no_op";
    J = "no_op";
    K = "no_op";
    L = "no_op";
    "C-j" = left;
    "C-k" = down;
    "C-l" = up;
    "C-ç" = right;
  };

  # Alt = jump, Ctrl = swap — from normal mode (no Ctrl-w prefix)
  abnt2WindowJump = {
    left,
    down,
    up,
    right,
  }: {
    "A-j" = left;
    "A-k" = down;
    "A-l" = up;
    "A-ç" = right;
  };

  abnt2WindowSwap =
    abnt2Swap {
      left = "swap_view_left";
      down = "swap_view_down";
      up = "swap_view_up";
      right = "swap_view_right";
    };

  windowMode =
    abnt2Dirs {
      left = "jump_view_left";
      down = "jump_view_down";
      up = "jump_view_up";
      right = "jump_view_right";
    }
    // abnt2Swap {
      left = "swap_view_left";
      down = "swap_view_down";
      up = "swap_view_up";
      right = "swap_view_right";
    }
    // abnt2LegacyWindow;

  viewMode = abnt2Vertical {
    down = "scroll_down";
    up = "scroll_up";
  };

  abnt2Movement = {
    normal =
      abnt2Dirs {
        left = "move_char_left";
        down = "move_line_down";
        up = "move_line_up";
        right = "move_char_right";
      }
      // abnt2WindowJump {
        left = "jump_view_left";
        down = "jump_view_down";
        up = "jump_view_up";
        right = "jump_view_right";
      }
      // abnt2WindowSwap
      // {
        g = abnt2Dirs {
          left = "goto_line_start";
          down = "move_line_down";
          up = "move_line_up";
          right = "goto_line_end";
        };
        z = viewMode;
        Z = viewMode;
        "C-w" = windowMode;
        space = {
          w = windowMode;
        };
      };
    select = abnt2Dirs {
      left = "extend_char_left";
      down = "extend_line_down";
      up = "extend_line_up";
      right = "extend_char_right";
    };
  };
in
{
  options.${namespace}.helix.enable =
    lib.mkEnableOption "Helix (ABNT2 keymap + Tokyo Night Storm when mine.theme is on)";

  config = lib.mkIf (cfg.enable && on "editors") {
    programs.helix = {
      enable = true;
      defaultEditor = false;
      settings =
        {
          keys = abnt2Movement;
        }
        // lib.optionalAttrs themeCfg.enable {
          theme = "tokyonight_storm";
        };
    };
  };
}
