{ config, pkgs, ... }:

let
  # ThinkPad palette — matte black + TrackPoint red
  bg      = "#0d0d0d";
  surface = "#171717";
  surf1   = "#222222";
  surf2   = "#2e2e2e";
  border  = "#333333";
  text    = "#dedede";
  subtext = "#7a7a7a";
  red     = "#cc2222";
  redBrt  = "#e63329";

  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
in

{
  ############################################################
  # Cursor
  ############################################################

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  ############################################################
  # Wallpaper
  ############################################################

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      preload = [ wallpaper ];
      wallpaper = [ ",${wallpaper}" ];
    };
  };

  ############################################################
  # Hyprland
  ############################################################

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$launcher" = "wofi --show drun";

      monitor = ",preferred,auto,1";

      exec-once = [
        "waybar"
        "mako"
        "nm-applet --indicator"
        "blueman-applet"
        "hypridle"
      ];

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "MOZ_ENABLE_WAYLAND,1"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 1;
        "col.active_border" = "rgba(cc2222ff)";
        "col.inactive_border" = "rgba(222222ff)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 4;
        active_opacity = 1.0;
        inactive_opacity = 0.96;

        shadow = {
          enabled = true;
          range = 10;
          render_power = 2;
          color = "rgba(00000099)";
        };

        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "ease,   0.25, 0.1, 0.25, 1.0"
          "linear, 0.0,  0.0, 1.0,  1.0"
        ];
        animation = [
          "windows,    1, 3, ease, slide"
          "windowsOut, 1, 2, ease, popin 90%"
          "windowsMove,1, 3, ease"
          "border,     1, 4, linear"
          "fade,       1, 3, ease"
          "workspaces, 1, 3, ease, slide"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = true;
      };

      input = {
        kb_layout = "br";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      gestures = {
        "gesture" = "3, horizontal, workspace";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
        focus_on_activate = true;
      };

      bind = [
        "$mod, Q, killactive"
        "$mod, Return, exec, $terminal"
        "$mod, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, S, exec, grim - | wl-copy"
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

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Media keys
        "$mod, L, exec, hyprlock"

        # Media keys
        "$mod, bracketleft,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "$mod, bracketright, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "$mod, semicolon,    exec, playerctl play-pause"
        "$mod, period,       exec, playerctl next"
        "$mod, comma,        exec, playerctl previous"

        # Brightness (ThinkPad Fn keys)
        ", XF86MonBrightnessUp,   exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ", XF86KbdBrightnessUp,   exec, brightnessctl -d *::kbd_backlight s 10%+"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d *::kbd_backlight s 10%-"

        # Media keys
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute,     exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioPlay,        exec, playerctl play-pause"
        ", XF86AudioNext,        exec, playerctl next"
        ", XF86AudioPrev,        exec, playerctl previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      layerrule = [
        "blur, wofi"
        "dimaround, wofi"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "noblur, class:.*"
        "float, class:^(wofi)$"
        "float, title:^(Open File)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Confirm)(.*)$"
        "float, title:^(Warning)(.*)$"
        "float, title:^(Error)(.*)$"
        "opacity 0.95 0.90, class:^(kitty)$"
        "center, floating:1"
      ];
    };
  };

  ############################################################
  # Waybar
  ############################################################

  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 36;
      spacing = 0;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "cpu" "temperature" "custom/nightshift" "tray" "custom/cpugov" "custom/logout" "custom/restart" "custom/shutdown" ];

      "hyprland/workspaces" = {
        disable-scroll = false;
        all-outputs = false;
        format = "{id}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%a, %b %d}";
        locale = "en_US.UTF-8";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          format = {
            months   = "<span color='#cc2222'><b>{}</b></span>";
            days     = "<span color='#dedede'>{}</span>";
            weekdays = "<span color='#7a7a7a'><b>{}</b></span>";
            today    = "<span color='#e63329'><b><u>{}</u></b></span>";
          };
        };
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰸈";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        tooltip-format = "{desc} — {volume}%";
        scroll-step = 5;
      };

      network = {
        format-wifi = "󰤨 {signalStrength}%";
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format-wifi = "{essid}  {ipaddr}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}";
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-full = "󰁹";
        format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format = "{time} remaining ({power:.1f}W)";
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 2;
        tooltip = false;
      };

      temperature = {
        thermal-zone = 5;
        format = "{icon} {temperatureC}°C";
        format-icons = [ "󰜗" "󰜗" "󰜗" "󰸁" "󰸁" ];
        critical-threshold = 80;
        interval = 2;
        tooltip = false;
      };

      "custom/nightshift" = {
        exec = ''bash -c 'pgrep hyprsunset > /dev/null && echo "{\"text\":\"󰖔\",\"class\":\"on\"}" || echo "{\"text\":\"󰖙\",\"class\":\"off\"}"' '';
        return-type = "json";
        interval = 3;
        on-click = "bash -c 'pgrep hyprsunset > /dev/null && pkill hyprsunset || hyprsunset -t 3000 &'";
        tooltip = false;
      };

      "custom/cpugov" = {
        exec = ''bash -c 'GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor); case $GOV in performance) echo "{\"text\":\"performance\",\"class\":\"perf\"}";; *) echo "{\"text\":\"powersave\",\"class\":\"save\"}";; esac' '';
        return-type = "json";
        interval = 2;
        on-click = "/run/wrappers/bin/sudo /etc/cpugov-toggle";
        tooltip = false;
      };

      tray = {
        spacing = 8;
        icon-size = 15;
      };

      "custom/logout" = {
        format = "logout";
        on-click = "echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Logout?' --width 140 --height 110 | grep -qx 'Yes' && hyprctl dispatch exit";
        tooltip = false;
      };

      "custom/restart" = {
        format = "reboot";
        on-click = "echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Reboot?' --width 140 --height 110 | grep -qx 'Yes' && systemctl reboot";
        tooltip = false;
      };

      "custom/shutdown" = {
        format = "shutdown";
        on-click = "echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Shutdown?' --width 140 --height 110 | grep -qx 'Yes' && systemctl poweroff";
        tooltip = false;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background-color: #0d0d0d;
        border-bottom: 1px solid #cc2222;
        color: #dedede;
      }

      /* Workspaces */
      #workspaces {
        margin: 0 4px;
      }

      #workspaces button {
        all: unset;
        padding: 0 10px;
        margin: 4px 1px;
        background-color: #171717;
        color: #7a7a7a;
        border-radius: 2px;
        border: 1px solid #222222;
        min-width: 24px;
        transition: all 0.1s ease;
      }

      #workspaces button:hover {
        background-color: #222222;
        color: #dedede;
        border-color: #333333;
      }

      #workspaces button.active {
        background-color: #cc2222;
        color: #dedede;
        border-color: #cc2222;
        font-weight: bold;
      }

      #workspaces button.urgent {
        background-color: #e63329;
        color: #0d0d0d;
        border-color: #e63329;
      }

      /* Window title */
      #window {
        padding: 0 10px;
        color: #7a7a7a;
      }

      /* Shared module style */
      #clock,
      #pulseaudio,
      #network,
      #battery,
      #cpu,
      #temperature,
      #custom-nightshift,
      #custom-cpugov,
      #tray {
        padding: 0 12px;
        margin: 4px 1px;
        background-color: #171717;
        border: 1px solid #222222;
        border-radius: 2px;
        color: #dedede;
      }

      #clock {
        font-weight: bold;
        letter-spacing: 0.5px;
      }

      #pulseaudio        { color: #dedede; }
      #pulseaudio.muted  { color: #7a7a7a; }

      #network              { color: #dedede; }
      #network.disconnected { color: #cc2222; }

      #battery              { color: #dedede; }
      #battery.warning      { color: #e8a045; }
      #battery.critical     { color: #cc2222; }
      #battery.charging     { color: #5a9e5a; }

      #cpu                  { color: #dedede; }

      #temperature          { color: #dedede; }
      #temperature.critical { color: #cc2222; }

      #custom-nightshift.on  { color: #e8a045; }
      #custom-nightshift.off { color: #7a7a7a; }

      #custom-cpugov.perf   { color: #cc2222; }
      #custom-cpugov.save   { color: #5a9e5a; }

      #tray > .needs-attention {
        border-color: #cc2222;
      }

      /* Calendar tooltip */
      tooltip {
        background-color: #0d0d0d;
        border: 1px solid #cc2222;
        border-radius: 4px;
        padding: 8px;
      }

      tooltip label {
        font-size: 16px;
        color: #dedede;
      }

      /* Power buttons */
      #custom-logout,
      #custom-restart,
      #custom-shutdown {
        padding: 0 10px;
        margin: 4px 1px;
        background-color: #171717;
        border: 1px solid #222222;
        border-radius: 2px;
        color: #7a7a7a;
        transition: all 0.1s ease;
      }

      #custom-logout:hover,
      #custom-restart:hover,
      #custom-shutdown:hover {
        background-color: #1a0000;
        color: #e63329;
        border-color: #cc2222;
      }
    '';
  };

  ############################################################
  # Wofi launcher
  ############################################################

  programs.wofi = {
    enable = true;
    settings = {
      width = 400;
      height = 300;
      hide_scroll = true;
    };
    style = ''
      window {
        background-color: #0d0d0d;
        border: 1px solid #cc2222;
        border-radius: 4px;
      }

      #input {
        all: unset;
        border: none;
        border-bottom: 1px solid #cc2222;
        border-radius: 3px 3px 0 0;
        padding: 10px 14px;
        color: #dedede;
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 14px;
        font-weight: bold;
        outline: none;
        caret-color: transparent;
      }

      #outer-box {
        padding: 6px;
      }

      #scroll {
        border: none;
        margin-top: 2px;
      }

      #entry {
        padding: 7px 12px;
        border-radius: 2px;
        color: #dedede;
      }

      #entry:selected {
        background-color: #1a1a1a;
        outline: none;
      }

      #text {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 14px;
        color: #dedede;
      }

      #text:selected {
        color: #cc2222;
        font-weight: bold;
      }

      #img {
        margin-right: 10px;
      }
    '';
  };

  ############################################################
  # Kitty terminal
  ############################################################

  programs.kitty = {
    enable = true;
    font = {
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
  # Mako notifications
  ############################################################

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 14";
      "background-color" = "#0d0d0d";
      "border-color" = "#cc2222";
      "text-color" = "#dedede";
      "border-size" = 1;
      "border-radius" = 3;
      "default-timeout" = 5000;
      padding = "10,14";
      width = 320;
      icons = true;
    };
  };

  ############################################################
  # Bash prompt
  ############################################################

  programs.bash = {
    enable = true;
    initExtra = ''
      PS1='\[\e[1;31m\][\u@\h:\w]\$\[\e[0m\] '
    '';
  };

  ############################################################
  # Hyprlock
  ############################################################

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
      };

      background = [{
        path = wallpaper;
        blur_passes = 0;
        brightness = 0.4;
      }];

      input-field = [{
        size = "300, 40";
        position = "0, -60";
        halign = "center";
        valign = "center";
        outline_thickness = 1;
        outer_color = "rgb(cc2222)";
        inner_color = "rgb(0d0d0d)";
        font_color = "rgb(dedede)";
        fade_on_empty = false;
        placeholder_text = "";
        rounding = 4;
      }];

      label = [{
        text = "$TIME";
        font_family = "JetBrains Mono";
        font_size = 48;
        color = "rgba(dedede, 1.0)";
        position = "0, 80";
        halign = "center";
        valign = "center";
      }];
    };
  };

  ############################################################
  # Hypridle
  ############################################################

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  home.packages = [ pkgs.hyprsunset ];

  ############################################################
  # Hyprsunset — night shift timers
  ############################################################

  systemd.user.services.hyprsunset-night = {
    Unit.Description = "Activate night shift";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'pkill hyprsunset || true; ${pkgs.hyprsunset}/bin/hyprsunset -t 3000 &'";
    };
  };

  systemd.user.timers.hyprsunset-night = {
    Unit.Description = "Activate night shift at 18:00";
    Timer = {
      OnCalendar = "*-*-* 18:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.hyprsunset-day = {
    Unit.Description = "Deactivate night shift";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'pkill hyprsunset || true'";
    };
  };

  systemd.user.timers.hyprsunset-day = {
    Unit.Description = "Deactivate night shift at 06:00";
    Timer = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
