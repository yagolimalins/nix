{ config, pkgs, ... }:

let
  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in

{
  ############################################################
  # Cursor
  ############################################################

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name       = "Bibata-Modern-Classic";
    package    = pkgs.bibata-cursors;
    size       = 24;
  };

  ############################################################
  # Wallpaper
  ############################################################

  home.packages = [ pkgs.swaybg ];

  ############################################################
  # Hyprland window manager
  ############################################################

  wayland.windowManager.hyprland = {
    enable   = true;
    settings = {
      "$mod"      = "SUPER";
      "$terminal" = "kitty";
      "$launcher" = "pgrep wofi || wofi --show drun --hide-actions";

      monitor = ",preferred,auto,1";

      exec-once = [
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY"
        "waybar"
        "swaybg -i ${wallpaper} -m fill"
        "fcitx5 -d"
        "mako"
        "nm-applet --indicator"
        "blueman-applet"
        "hypridle"
        "tumblerd"
      ];

      env = [
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "MOZ_ENABLE_WAYLAND,1"
      ];

      general = {
        gaps_in            = 4;
        gaps_out           = 8;
        border_size        = 1;
        "col.active_border"   = "rgba(cc2222ff)";
        "col.inactive_border" = "rgba(222222ff)";
        layout             = "dwindle";
        resize_on_border   = true;
      };

      decoration = {
        rounding         = 4;
        active_opacity   = 1.0;
        inactive_opacity = 0.96;

        shadow = {
          enabled      = true;
          range        = 10;
          render_power = 2;
          color        = "rgba(00000099)";
        };

        blur = {
          enabled = true;
          size    = 6;
          passes  = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "ease,   0.25, 0.1, 0.25, 1.0"
          "linear, 0.0,  0.0, 1.0,  1.0"
        ];
        animation = [
          "windows,     1, 3, ease, slide"
          "windowsOut,  1, 2, ease, popin 90%"
          "windowsMove, 1, 3, ease"
          "border,      1, 4, linear"
          "fade,        1, 3, ease"
          "workspaces,  1, 3, ease, slide"
        ];
      };

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      input = {
        kb_layout    = "br";
        follow_mouse = 1;
        sensitivity  = 0.75;
        accel_profile = "adaptive";
        touchpad = {
          natural_scroll = true;
          tap-to-click   = true;
        };
      };


      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
        animate_manual_resizes  = true;
        enable_swallow          = true;
        swallow_regex           = "^(kitty)$";
        focus_on_activate       = true;
      };

      debug = {
        disable_logs = false;
      };

      bind = [
        "$mod, Q, killactive"
        "$mod, Return, exec, $terminal"
        "$mod, S, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
        "$mod SHIFT, S, exec, grimblast --notify copysave output ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
        "$mod, Space, exec, $launcher"

        # Window management
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # Focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        # Resize
        "$mod SHIFT, left,  resizeactive, -40 0"
        "$mod SHIFT, right, resizeactive,  40 0"
        "$mod SHIFT, up,    resizeactive,  0 -40"
        "$mod SHIFT, down,  resizeactive,  0  40"

        # Workspaces
        "$mod, 1, workspace, 1"  "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"  "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"  "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"  "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"  "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"  "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"  "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"  "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"  "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"  "$mod SHIFT, 0, movetoworkspace, 10"

        # Session
        "$mod, L, exec, hyprlock"

        # Brightness (ThinkPad Fn keys)
        ", XF86MonBrightnessUp,   exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ", XF86KbdBrightnessUp,   exec, brightnessctl -d *::kbd_backlight s 10%+"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d *::kbd_backlight s 10%-"
      ];

      # Works even on locked screen (l = locked)
      bindl = [
        # Lid switch — disable/enable built-in display
        ", switch:on:Lid Switch,  exec, hyprctl keyword monitor eDP-1,disable"
        ", switch:off:Lid Switch, exec, hyprctl keyword monitor eDP-1,preferred,auto,1"

        "$mod, semicolon,    exec, playerctl play-pause"
        "$mod, period,       exec, playerctl next"
        "$mod, comma,        exec, playerctl previous"
        ", XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioPlay,    exec, playerctl play-pause"
        ", XF86AudioNext,    exec, playerctl next"
        ", XF86AudioPrev,    exec, playerctl previous"
      ];

      # Works on locked screen + repeatable (le = locked + repeat)
      bindle = [
        "$mod, bracketleft,       exec, wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        "$mod, bracketright,      exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      layerrule = [
        "blur on, match:namespace wofi"
      ];

      windowrule = [
        "float on,  match:class wofi"
        "center on, match:class wofi"
        "float on,  match:title Open File"
        "center on, match:title Open File"
        "float on,  match:title Save As"
        "center on, match:title Save As"
        "float on,  match:title Confirm"
        "center on, match:title Confirm"
        "float on,  match:title Warning"
        "center on, match:title Warning"
        "float on,  match:title Error"
        "center on, match:title Error"
        "opacity 0.95 0.90, match:class kitty"

        # Reaper — tile main window, let dialogs float at their own position
        "tile on,   match:class REAPER, match:title REAPER v"
        "no_anim on, match:class REAPER"
      ];
    };
  };
}
