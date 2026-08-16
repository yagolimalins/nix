#
# cli — shell essentials, file tools, HTTP client (gated by mine.packages.cli).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  pkgCfg = config.${namespace}.packages;
  on = pkgCfg.enable && pkgCfg.cli.enable;

  openers = lib.${namespace}.folderOpenCommands pkgs;
  themeCfg = config.${namespace}.theme;
  palette = lib.${namespace}.palette;
  hx = lib.getExe pkgs.helix;
  kitty = lib.getExe pkgs.kitty;
  zathura = lib.getExe pkgs.zathura;
  vlc = lib.getExe pkgs.vlc;
  ristretto = lib.getExe pkgs.ristretto;
  librewolf = lib.getExe pkgs.librewolf;
  zellij = lib.getExe pkgs.zellij;
  jq = lib.getExe pkgs.jq;

  # #rrggbb → broot rgb(r, g, b)
  rgb =
    hex:
    let
      h = lib.removePrefix "#" hex;
      dec = s: toString (lib.fromHexString s);
    in
    "rgb(${dec (builtins.substring 0 2 h)}, ${dec (builtins.substring 2 2 h)}, ${dec (builtins.substring 4 2 h)})";

  brootStormSkin = {
    default = "${rgb palette.text} ${rgb palette.bg}";
    tree = "${rgb palette.muted} none";
    parent = "${rgb palette.muted} none";
    file = "${rgb palette.text} none";
    directory = "${rgb palette.accent} none bold";
    exe = "${rgb palette.ok} none";
    link = "${rgb palette.purple} none";
    selected_line = "none ${rgb palette.border}";
    char_match = "${rgb palette.ok} none bold";
    file_error = "${rgb palette.urgent} none";
    input = "${rgb palette.text} ${rgb palette.surface}";
    flag_label = "${rgb palette.muted} ${rgb palette.surface}";
    flag_value = "${rgb palette.cyan} ${rgb palette.surface}";
    status_normal = "${rgb palette.muted} ${rgb palette.surface}";
    status_error = "${rgb palette.text} ${rgb palette.urgent}";
    status_italic = "${rgb palette.cyan} ${rgb palette.surface}";
    status_bold = "${rgb palette.accent} ${rgb palette.surface} bold";
    git_status_modified = "${rgb palette.warning} none";
    git_status_new = "${rgb palette.ok} none bold";
    git_status_conflicted = "${rgb palette.urgent} none";
    mode_command_mark = "${rgb palette.onAccent} ${rgb palette.accent} bold";
    scrollbar_thumb = "${rgb palette.accent} none";
    scrollbar_track = "${rgb palette.border} none";
  };

  # GUI/IDE launchers must return immediately — otherwise Yazi waits on the child.
  mkYaziBgOpener =
    name: bin:
    pkgs.writeShellScriptBin name ''
      ${bin} "$@" &
      disown
    '';

  yaziOpenZathura = mkYaziBgOpener "yazi-open-zathura" zathura;
  yaziOpenVlc = mkYaziBgOpener "yazi-open-vlc" vlc;
  yaziOpenRistretto = mkYaziBgOpener "yazi-open-ristretto" ristretto;
  yaziOpenLibrewolf = mkYaziBgOpener "yazi-open-librewolf" librewolf;
  yaziOpenXdg = mkYaziBgOpener "yazi-open-xdg" "${lib.getExe' pkgs.xdg-utils "xdg-open"}";
  yaziOpenCursor = mkYaziBgOpener "yazi-open-cursor" (lib.getExe pkgs.code-cursor);
  yaziOpenVscode = pkgs.writeShellScriptBin "yazi-open-vscode" ''
    ${lib.getExe pkgs.vscode} --new-window "$@" &
    disown
  '';
  yaziOpenZed = pkgs.writeShellScriptBin "yazi-open-zed" ''
    ${lib.getExe pkgs.zed-editor} -n "$@" &
    disown
  '';

  # Open a file in the Zellij pane named "editor" (Helix). Falls back to hx.
  # pane_command is often the LSP (nixd); the hx binary is in terminal_command ("hx .").
  # send-keys wants "Esc", not "Escape" (the latter aborts the script).
  brootOpenInHelix = pkgs.writeShellScript "broot-open-in-helix" ''
    set -eu
    file=''${1-}
    if [ -z "$file" ]; then
      exit 1
    fi

    if [ -z "''${ZELLIJ-}" ]; then
      exec ${hx} "$file"
    fi

    panes=$(${zellij} action list-panes -j -a) || exit 1
    pane_id=$(printf '%s' "$panes" | ${jq} -r '
      def is_hx:
        test("(?:^|[\\s/])hx(?:\\s|$)|helix");
      [ .[] | select(.is_plugin == false) ]
      | (
          map(select(.title == "editor"))
          + map(select((.terminal_command // "") | is_hx))
          + map(select((.pane_command // "") | is_hx))
        )
      | .[0].id // empty
    ') || exit 1
    if [ -z "$pane_id" ]; then
      exit 1
    fi

    target="terminal_$pane_id"
    ${zellij} action send-keys --pane-id "$target" Esc
    ${zellij} action write-chars --pane-id "$target" ":open $file"
    ${zellij} action send-keys --pane-id "$target" Enter
    ${zellij} action focus-pane-id "$target"
  '';
in
{
  config = lib.mkIf on {
    # Packages without HM program modules — the rest come from programs.* below.
    home.packages = with pkgs; [
      ripgrep
      fd
      miniserve
      just
      yazi
      xh
      duf
      dust
      yaziOpenZathura
      yaziOpenVlc
      yaziOpenRistretto
      yaziOpenLibrewolf
      yaziOpenXdg
      yaziOpenCursor
      yaziOpenVscode
      yaziOpenZed
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--reverse"
        "--bind=ctrl-/:toggle-preview"
      ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    programs.jq.enable = true;

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };

    programs.tealdeer.enable = true;

    # Modal: j/k/l/ç are verbs (type-to-filter would eat them). Search with / or space.
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        modal = true;
        initial_mode = "command";
        default_flags = "-g";
        icon_theme = "nerdfont";
        show_selection_mark = true;
        auto_open_staging_area = false;
        quit_on_last_cancel = false;
        cols_order = [
          "mark"
          "git"
          "branch"
          "name"
        ];
        verbs = [
          {
            key = "h";
            execution = ":mode_command";
          }
          {
            key = "j";
            execution = ":parent";
          }
          {
            key = "k";
            execution = ":line_down";
          }
          {
            key = "l";
            execution = ":line_up";
          }
          {
            key = "ç";
            apply_to = "directory";
            execution = ":focus";
          }
          {
            key = "enter";
            apply_to = "directory";
            execution = ":focus";
          }
          {
            invocation = "helix";
            key = "enter";
            apply_to = "file";
            external = [
              "${brootOpenInHelix}"
              "{file}"
            ];
            leave_broot = false;
            switch_terminal = false;
          }
        ];
      }
      // lib.optionalAttrs themeCfg.enable {
        skin = brootStormSkin;
        syntax_theme = "OceanDark";
      };
    };

    programs.zsh.shellAliases.zide = "zellij -l ide";

    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      exitShellOnExit = false;
      settings = {
        default_shell = "zsh";
        theme = "tokyo-night-storm";
        copy_command = lib.getExe' pkgs.wl-clipboard "wl-copy";
        copy_clipboard = "system";
        default_mode = "locked";
        mouse_mode = true;
        scroll_buffer_size = 10000;
        show_startup_tips = false;
        session_serialization = true;
        on_force_close = "quit";
        auto_layout = false;
        ui.pane_frames.rounded_corners = true;
      };
      # Helix ABNT2: j/k/l/ç = ← ↓ ↑ → (unbind default h/j/k/l).
      # default_mode is locked: only Ctrl+g plus whatever we bind here.
      # Plugins must SwitchToMode "Locked" or keys NoOp (zellij#3756).
      extraConfig = ''
        keybinds {
            locked {
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
                bind "Alt f" { NextSwapLayout; }
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
                bind "Alt f" { NextSwapLayout; }
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

    # IDE layout: edit | agent | git. Start from the project (`zellij -l ide`).
    # Edit: files | editor / terminal. Alt+f stacks files behind the editor.
    # Alt+1..0 jump tabs 1–10.
    xdg.configFile."zellij/layouts/ide.kdl".text = ''
      layout {
          cwd "."
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
          }
          tab_template name="ui" {
              children
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
          }
          ui name="edit" focus=true {
              pane split_direction="vertical" {
                  pane size=36 {
                      name "files"
                      command "${lib.getExe pkgs.broot}"
                      cwd "."
                      close_on_exit false
                  }
                  pane split_direction="horizontal" {
                      pane {
                          name "editor"
                          command "${hx}"
                          args "."
                          cwd "."
                          close_on_exit false
                          focus true
                      }
                      pane size="18%" {
                          name "terminal"
                          cwd "."
                      }
                  }
              }
          }
          ui name="agent" {
              pane {
                  name "agent"
                  command "${lib.getExe' pkgs.cursor-cli "cursor-agent"}"
                  cwd "."
                  close_on_exit false
              }
          }
          ui name="git" {
              pane {
                  name "git"
                  command "${lib.getExe pkgs.gitui}"
                  cwd "."
                  close_on_exit false
              }
          }
          swap_tiled_layout name="editor" {
              ui exact_panes=3 {
                  pane split_direction="horizontal" {
                      pane stacked=true { children; }
                      pane size="18%"
                  }
              }
              ui exact_panes=4 {
                  pane split_direction="horizontal" {
                      pane stacked=true { children; }
                      pane size="18%"
                  }
              }
          }
      }
    '';

    xdg.configFile."yazi/plugins/smart-enter.yazi/main.lua".text = ''
      --- @since 25.5.31
      --- @sync entry

      local function setup(self, opts) self.open_multi = opts.open_multi end

      local function entry(self)
        local h = cx.active.current.hovered
        ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = not self.open_multi })
      end

      return { entry = entry, setup = setup }
    '';

    xdg.configFile."yazi/keymap.toml" = {
      force = true;
      text = ''
        # ABNT2: j/k/l/ç = ← ↓ ↑ → (unbind default h/j/k/l).
        # Enter: enter directories, open files (Yazi default Enter always runs open).
        [mgr]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "leave", desc = "Back to parent" },
          { on = "k", run = "arrow next", desc = "Next file" },
          { on = "l", run = "arrow prev", desc = "Previous file" },
          { on = "ç", run = "enter", desc = "Enter directory" },
          { on = "<Enter>", run = "plugin smart-enter", desc = "Enter directory or open file" },
        ]

        [tasks]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next task" },
          { on = "l", run = "arrow prev", desc = "Previous task" },
        ]

        [spot]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "swipe prev", desc = "Swipe to previous file" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
          { on = "ç", run = "swipe next", desc = "Swipe to next file" },
        ]

        [pick]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next option" },
          { on = "l", run = "arrow prev", desc = "Previous option" },
        ]

        [input]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "move -1", desc = "Move left" },
          { on = "k", run = "recall 1", desc = "Next input" },
          { on = "l", run = "recall -1", desc = "Previous input" },
          { on = "ç", run = "move 1", desc = "Move right" },
        ]

        [confirm]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
        ]

        [help]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
        ]
      '';
    };

    xdg.configFile."yazi/yazi.toml" = {
      force = true;
      text = ''
        # orphan = true detaches from Yazi's task queue; wrappers & disown so the shell returns too.
        [opener]
        edit = [
          { run = "${kitty} --detach --directory %d1 -- ${hx} %s", desc = "Helix", orphan = true },
        ]
        # Replace Yazi presets — stock xdg-open openers block until the handler exits.
        open = [
          { run = "${lib.getExe yaziOpenXdg} %s1", desc = "Open", orphan = true },
        ]
        reveal = [
          { run = "${lib.getExe yaziOpenXdg} %d1", desc = "Reveal", orphan = true },
        ]
        play = [
          { run = "${lib.getExe yaziOpenVlc} %s1", desc = "Play", orphan = true },
        ]
        folder = [
          { run = "${openers.yazi.terminal}", desc = "Open Terminal Here", orphan = true },
          { run = "${openers.yazi.zellijIde}", desc = "Open Zellij here", orphan = true },
          { run = "${lib.getExe yaziOpenCursor} %s", desc = "Open Cursor Here", orphan = true },
          { run = "${lib.getExe yaziOpenVscode} %s", desc = "Open VSCode Here", orphan = true },
          { run = "${lib.getExe yaziOpenZed} %s", desc = "Open Zed Here", orphan = true },
        ]
        zathura = [
          { run = "${lib.getExe yaziOpenZathura} %s", desc = "Zathura", orphan = true },
        ]
        vlc = [
          { run = "${lib.getExe yaziOpenVlc} %s", desc = "VLC", orphan = true },
        ]
        image = [
          { run = "${lib.getExe yaziOpenRistretto} %s", desc = "Ristretto", orphan = true },
        ]
        browser = [
          { run = "${lib.getExe yaziOpenLibrewolf} %s", desc = "LibreWolf", orphan = true },
        ]

        [open]
        prepend_rules = [
          { url = "*/", use = "folder" },
          { mime = "text/html", use = "browser" },
          { mime = "application/xhtml+xml", use = "browser" },
          { mime = "application/pdf", use = "zathura" },
          { mime = "video/*", use = "vlc" },
          { mime = "audio/*", use = "vlc" },
          { mime = "image/*", use = "image" },
          { mime = "text/*", use = "edit" },
          { url = "*.{rs,toml,nix,md,json,yaml,yml,ts,tsx,js,jsx,css,html,sh}", use = "edit" },
        ]
      '';
    };

  };
}
