#
# umbriel — Compositor (pairs with NixOS mine.display)
#
# Outputs: osConfig.mine.host.outputs. Shell: mine.noctalia (autostart).
# Extra session commands: mine.umbriel.extraAutostart + host.sessionAutostart.
#
{
  config,
  lib,
  pkgs,
  osConfig,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.umbriel;
  hostCfg = osConfig.${namespace}.host;
  palette = lib.${namespace}.palette;

  # Append alpha channel for Umbriel #RRGGBBAA colors.
  withAlpha = color: alpha: "${color}${alpha}";
in
{
  options.${namespace}.umbriel = {
    enable = lib.mkEnableOption "Umbriel compositor config (outputs, keybinds, session bootstrap)";

    extraAutostart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra general.autostart commands contributed by other HM modules.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Keyboard backlight binds only — media/brightness OSD via Noctalia.
    home.packages = [ pkgs.brightnessctl ];

    home.sessionVariables = {
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      MOZ_ENABLE_WAYLAND = "1";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      XDG_CURRENT_DESKTOP = "umbriel";
    };

    programs.umbriel = {
      enable = true;
      settings = {
        general = {
          autostart = [
            "noctalia"
            "fcitx5 -d"
          ]
          ++ cfg.extraAutostart
          ++ hostCfg.sessionAutostart;
          mod_key = "Super";
          show_cheatsheet = false;
        };

        events = {
          lid_close = "umbriel msg output-disable eDP-1";
          lid_open = "umbriel msg output-enable eDP-1";
        };

        output = hostCfg.outputs;

        appearance = {
          blur.radius = 3;
        };

        # Tokyo Night Storm borders / chrome (same palette as mine.theme).
        colors = {
          background = withAlpha palette.bg "ff";
          text_primary = withAlpha palette.text "ff";
          text_muted = withAlpha palette.muted "ff";
          accent_primary = withAlpha palette.accent "ff";
          accent_secondary = withAlpha palette.cyan "ff";
          warning = withAlpha palette.warning "ff";
          error = withAlpha palette.urgent "ff";
          backdrop = withAlpha palette.bg "ff";
          border = {
            focused = withAlpha palette.accent "ff";
            unfocused = withAlpha palette.border "ff";
          };
        };

        input = {
          keyboard = {
            layout = "br";
            numlock_toggle = true;
          };
          focus.follows_mouse = "sloppy";
          touchpad = {
            natural_scroll = true;
            tap = true;
          };
        };

        layout = {
          mode = "dwindle";
          gap = 4;
        };

        # Horizontal workspace_axis (per output) + slide = left/right swipe animation.
        animation.workspaces = {
          style = "slide";
          enabled = true;
        };

        keybinds = {
          # Applications
          "Mod+Return" = {
            action = "spawn kitty";
            repeat = false;
          };
          "Mod+Q" = {
            action = "window-close";
            repeat = false;
          };
          "Mod+Space" = "spawn noctalia msg panel-toggle launcher";
          "Mod+S" = "spawn noctalia msg screenshot-annotate";
          "Mod+Shift+S" = "spawn noctalia msg screenshot";
          "Mod+Slash" = {
            action = "cheatsheet-toggle";
            repeat = false;
          };

          # Session
          "Mod+L" = {
            action = "spawn loginctl lock-session";
            repeat = false;
          };
          "Mod+Escape" = "spawn noctalia msg panel-toggle session";

          # Window state
          "Mod+F" = {
            action = "window-toggle-fullscreen";
            repeat = false;
          };
          "Mod+V" = {
            action = "window-toggle-floating";
            repeat = false;
          };
          "Mod+P" = {
            action = "window-toggle-pinned";
            repeat = false;
          };
          "Mod+J" = "layout-toggle-split";

          # Focus (arrows — Mod+L is lock)
          "Mod+Left" = "window-focus-left";
          "Mod+Right" = "window-focus-right";
          "Mod+Up" = "window-focus-up";
          "Mod+Down" = "window-focus-down";

          # Resize
          "Mod+Shift+Left" = "window-modify-primary-extent -0.05";
          "Mod+Shift+Right" = "window-modify-primary-extent +0.05";
          "Mod+Shift+Up" = "window-modify-secondary-extent -0.05";
          "Mod+Shift+Down" = "window-modify-secondary-extent +0.05";

          # Workspaces 1–9 (external), 0 → internal panel workspace
          "Mod+1" = "workspace-switch 1";
          "Mod+2" = "workspace-switch 2";
          "Mod+3" = "workspace-switch 3";
          "Mod+4" = "workspace-switch 4";
          "Mod+5" = "workspace-switch 5";
          "Mod+6" = "workspace-switch 6";
          "Mod+7" = "workspace-switch 7";
          "Mod+8" = "workspace-switch 8";
          "Mod+9" = "workspace-switch 9";
          "Mod+0" = "workspace-switch 1 --output eDP-1";

          "Mod+Shift+1" = "window-move-to-workspace 1";
          "Mod+Shift+2" = "window-move-to-workspace 2";
          "Mod+Shift+3" = "window-move-to-workspace 3";
          "Mod+Shift+4" = "window-move-to-workspace 4";
          "Mod+Shift+5" = "window-move-to-workspace 5";
          "Mod+Shift+6" = "window-move-to-workspace 6";
          "Mod+Shift+7" = "window-move-to-workspace 7";
          "Mod+Shift+8" = "window-move-to-workspace 8";
          "Mod+Shift+9" = "window-move-to-workspace 9";
          "Mod+Shift+0" = "window-move-to-workspace 1 --output eDP-1";

          # Media / volume / brightness via Noctalia OSD
          "Mod+semicolon" = {
            action = "spawn noctalia msg media toggle";
            allow_when_locked = true;
            repeat = false;
          };
          "Mod+period" = {
            action = "spawn noctalia msg media next";
            allow_when_locked = true;
          };
          "Mod+comma" = {
            action = "spawn noctalia msg media previous";
            allow_when_locked = true;
          };
          "XF86AudioRaiseVolume" = {
            action = "spawn noctalia msg volume-up";
            allow_when_locked = true;
          };
          "XF86AudioLowerVolume" = {
            action = "spawn noctalia msg volume-down";
            allow_when_locked = true;
          };
          "XF86AudioMute" = {
            action = "spawn noctalia msg volume-mute";
            allow_when_locked = true;
            repeat = false;
          };
          "XF86AudioMicMute" = {
            action = "spawn wpctl set-mute @DEFAULT_SOURCE@ toggle";
            allow_when_locked = true;
            repeat = false;
          };
          "XF86AudioPlay" = {
            action = "spawn noctalia msg media toggle";
            allow_when_locked = true;
            repeat = false;
          };
          "XF86AudioNext" = {
            action = "spawn noctalia msg media next";
            allow_when_locked = true;
          };
          "XF86AudioPrev" = {
            action = "spawn noctalia msg media previous";
            allow_when_locked = true;
          };
          "XF86MonBrightnessUp" = {
            action = "spawn noctalia msg brightness-up";
            allow_when_locked = true;
          };
          "XF86MonBrightnessDown" = {
            action = "spawn noctalia msg brightness-down";
            allow_when_locked = true;
          };
          "XF86KbdBrightnessUp" = {
            action = "spawn brightnessctl -d '*::kbd_backlight' s 10%+";
            allow_when_locked = true;
          };
          "XF86KbdBrightnessDown" = {
            action = "spawn brightnessctl -d '*::kbd_backlight' s 10%-";
            allow_when_locked = true;
          };
        };

        window_rule = [
          { blur = true; }
          {
            match.app_id = "^dev.noctalia.Noctalia$";
            default_floating = true;
            default_floating_size_px = {
              width = 1020;
              height = 900;
            };
          }
          {
            match.title = "^Open File$";
            default_floating = true;
          }
          {
            match.title = "^Save As$";
            default_floating = true;
          }
          {
            match.title = "^Confirm$";
            default_floating = true;
          }
          {
            match.title = "^Warning$";
            default_floating = true;
          }
          {
            match.title = "^Error$";
            default_floating = true;
          }
          {
            match.app_id = "^REAPER$";
            match.title = "^REAPER v";
            default_floating = false;
          }
          {
            match.app_id = "^REAPER$";
            match.title = "REAPER Query";
            default_floating = true;
          }
          {
            match.app_id = "^REAPER$";
            match.title = ".*Add FX.*";
            default_floating = true;
          }
          {
            match.app_id = "^lsp-plugins$";
            default_floating = true;
          }
          {
            match.title = ".*LSP.*";
            default_floating = true;
          }
        ];

        layer_rule = [
          {
            match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
            blur = true;
            blur_ignore_alpha = 0.5;
            blur_popups = true;
          }
          {
            match.namespace = "^noctalia-(notification|dock|panel|attached-panel|osd)$";
            blur_optimized = false;
          }
        ];
      };
    };
  };
}
