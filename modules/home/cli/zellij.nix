#
# cli/zellij — multiplexer, plus the `terminal` wrapper that launches it.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages "cli";
  term = lib.${namespace}.terminalCommands pkgs;
  kitty = lib.getExe pkgs.kitty;

  # Default terminal: kitty hosting zellij. Supports `$TERMINAL -e cmd`.
  terminalWrapper = pkgs.writeShellScriptBin "terminal" ''
    if [ "$1" = "-e" ] && [ -n "''${2-}" ]; then
      shift
      exec ${kitty} -- "$@"
    else
      exec ${term.launch} "$@"
    fi
  '';
in
{
  config = lib.mkIf on {
    home.packages = [ terminalWrapper ];

    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      exitShellOnExit = false;
      settings = {
        default_shell = "zsh";
        default_layout = "compact";
        theme = "tokyo-night-storm";
        copy_command = lib.getExe' pkgs.wl-clipboard "wl-copy";
        copy_clipboard = "system";
        default_mode = "locked";
        mouse_mode = true;
        scroll_buffer_size = 10000;
        show_startup_tips = false;
        show_release_notes = false;
        mouse_hover_effects = false;
        session_serialization = true;
        on_force_close = "quit";
        auto_layout = true;
        pane_frames = true;
        hide_session_name = true;
        advanced_mouse_actions = true;
      };
      # Helix ABNT2: j/k/l/ç = ← ↓ ↑ → (unbind default h/j/k/l).
      # default_mode is locked: only Ctrl+g plus whatever we bind here.
      # Plugins must SwitchToMode "Locked" or keys NoOp (zellij#3756).
      extraConfig = ''
        keybinds {
            locked {
                bind "Ctrl r" { SwitchToMode "Resize"; }
                bind "Alt j" "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt k" "Alt Down" { MoveFocus "Down"; }
                bind "Alt l" "Alt Up" { MoveFocus "Up"; }
                bind "Alt ç" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
                bind "Alt 6" { GoToTab 6; }
                bind "Alt 7" { GoToTab 7; }
                bind "Alt 8" { GoToTab 8; }
                bind "Alt 9" { GoToTab 9; }
                bind "Alt 0" { GoToTab 10; }
                bind "Alt f" { ToggleFocusFullscreen; }
            }
            shared_except "locked" {
                unbind "Alt h" "Alt j" "Alt k" "Alt l"
                bind "Alt j" "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt k" "Alt Down" { MoveFocus "Down"; }
                bind "Alt l" "Alt Up" { MoveFocus "Up"; }
                bind "Alt ç" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
                bind "Alt 6" { GoToTab 6; }
                bind "Alt 7" { GoToTab 7; }
                bind "Alt 8" { GoToTab 8; }
                bind "Alt 9" { GoToTab 9; }
                bind "Alt 0" { GoToTab 10; }
                bind "Alt f" { ToggleFocusFullscreen; }
            }
            session {
                bind "w" {
                    LaunchOrFocusPlugin "session-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
                bind "c" {
                    LaunchOrFocusPlugin "configuration" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
                bind "p" {
                    LaunchOrFocusPlugin "plugin-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
                bind "a" {
                    LaunchOrFocusPlugin "zellij:about" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
                bind "s" {
                    LaunchOrFocusPlugin "zellij:share" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
                bind "l" {
                    LaunchOrFocusPlugin "zellij:layout-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "Locked"
                }
            }
            pane {
                unbind "h" "j" "k" "l"
                bind "j" { MoveFocus "Left"; }
                bind "k" { MoveFocus "Down"; }
                bind "l" { MoveFocus "Up"; }
                bind "ç" { MoveFocus "Right"; }
            }
            move {
                unbind "h" "j" "k" "l"
                bind "j" { MovePane "Left"; }
                bind "k" { MovePane "Down"; }
                bind "l" { MovePane "Up"; }
                bind "ç" { MovePane "Right"; }
            }
            resize {
                bind "Esc" "Ctrl g" { SwitchToMode "Locked"; }
                unbind "h" "j" "k" "l" "H" "J" "K" "L"
                bind "j" { Resize "Increase Left"; }
                bind "k" { Resize "Increase Down"; }
                bind "l" { Resize "Increase Up"; }
                bind "ç" { Resize "Increase Right"; }
                bind "J" { Resize "Decrease Left"; }
                bind "K" { Resize "Decrease Down"; }
                bind "L" { Resize "Decrease Up"; }
                bind "Ç" { Resize "Decrease Right"; }
            }
            tab {
                unbind "h" "j" "k" "l"
                bind "j" { GoToPreviousTab; }
                bind "ç" { GoToNextTab; }
            }
            scroll {
                unbind "h" "j" "k" "l"
                bind "k" "Down" { ScrollDown; }
                bind "l" "Up" { ScrollUp; }
                bind "ç" "Right" { PageScrollDown; }
                bind "j" "Left" { PageScrollUp; }
            }
            search {
                unbind "h" "j" "k" "l"
                bind "k" "Down" { ScrollDown; }
                bind "l" "Up" { ScrollUp; }
                bind "ç" "Right" { PageScrollDown; }
                bind "j" "Left" { PageScrollUp; }
            }
        }
      '';
    };
  };
}
