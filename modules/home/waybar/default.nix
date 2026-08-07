#
# waybar — Status bar + Hyprland autostart
#
# CSS is generated from lib.mine.palette (no separate style.css).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.waybar;
  palette = lib.${namespace}.palette;

  style = ''
    * {
      font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", "Noto Sans CJK JP", "Noto Sans CJK SC", "Noto Sans CJK TC", "Noto Sans CJK KR", monospace;
      font-size: 15px;
      min-height: 0;
    }

    window#waybar {
      background-color: ${palette.bg};
      border-bottom: 1px solid ${palette.accent};
      color: ${palette.text};
    }

    #workspaces { margin: 0 6px; }

    #workspaces button {
      all: unset;
      padding: 0 12px;
      margin: 4px 2px;
      background-color: ${palette.surface};
      color: ${palette.muted};
      border-radius: 6px;
      border: 1px solid ${palette.border};
      min-width: 28px;
      transition: all 0.15s ease;
    }

    #workspaces button:hover {
      background-color: ${palette.border};
      color: ${palette.text};
      border-color: ${palette.accent};
    }

    #workspaces button.active {
      background-color: ${palette.accent};
      color: ${palette.onAccent};
      border-color: ${palette.accent};
      font-weight: bold;
    }

    #workspaces button.urgent {
      background-color: ${palette.urgent};
      color: ${palette.onAccent};
      border-color: ${palette.urgent};
    }

    #mpris {
      padding: 0 14px;
      margin: 4px 2px;
      background-color: ${palette.surface};
      border: 1px solid ${palette.border};
      border-radius: 6px;
      color: ${palette.text};
      font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", "Noto Sans CJK SC", "Noto Sans CJK TC", "Noto Sans CJK KR", sans-serif;
    }
    #mpris.paused { color: ${palette.muted}; }

    #clock,
    #pulseaudio,
    #network,
    #custom-vpn,
    #battery,
    #cpu,
    #temperature,
    #custom-nightshift,
    #custom-cpugov,
    #tray {
      padding: 0 12px;
      margin: 4px 2px;
      background-color: ${palette.surface};
      border: 1px solid ${palette.border};
      border-radius: 6px;
      color: ${palette.text};
    }

    #clock {
      font-weight: bold;
      letter-spacing: 1px;
      color: ${palette.text};
      background-color: ${palette.surface};
      border-color: ${palette.accent};
    }

    #pulseaudio       { color: ${palette.text}; }
    #pulseaudio.muted { color: ${palette.muted}; }

    #network              { color: ${palette.text}; }
    #network.disconnected { color: ${palette.urgent}; }

    #battery,
    #battery-bat0,
    #battery-bat1     { color: ${palette.text}; }
    #battery.warning,
    #battery-bat0.warning,
    #battery-bat1.warning  { color: ${palette.warning}; }
    #battery.critical,
    #battery-bat0.critical,
    #battery-bat1.critical { color: ${palette.urgent}; }
    #battery.charging,
    #battery-bat0.charging,
    #battery-bat1.charging { color: ${palette.ok}; }

    #cpu { color: ${palette.text}; }

    #temperature          { color: ${palette.text}; }
    #temperature.critical { color: ${palette.urgent}; }

    #custom-vpn.connected { color: ${palette.ok}; }
    #custom-vpn.off       { color: transparent; padding: 0; margin: 0; min-width: 0; border: none; }

    #custom-nightshift.on  { color: ${palette.warning}; }
    #custom-nightshift.off { color: ${palette.muted}; }

    #custom-cpugov.perf { color: ${palette.accent}; }
    #custom-cpugov.save { color: ${palette.ok}; }

    #tray > .needs-attention { border-color: ${palette.accent}; }

    tooltip {
      background-color: ${palette.bg};
      border: 1px solid ${palette.accent};
      border-radius: 6px;
      padding: 10px;
    }

    tooltip label { font-size: 15px; color: ${palette.text}; }

    #custom-power {
      padding: 0 12px;
      margin: 4px 2px;
      background-color: ${palette.surface};
      border: 1px solid ${palette.border};
      border-radius: 6px;
      color: ${palette.muted};
      transition: all 0.15s ease;
    }

    #custom-power:hover {
      background-color: ${palette.urgent};
      color: ${palette.onAccent};
      border-color: ${palette.urgent};
    }
  '';
in
{
  options.${namespace}.waybar.enable = lib.mkEnableOption "Waybar status bar";

  config = lib.mkIf cfg.enable {
    # Restart loop: Waybar occasionally exits on monitor changes.
    wayland.windowManager.hyprland.settings.exec-once = [
      "bash -c 'while true; do ${pkgs.waybar}/bin/waybar; sleep 1; done'"
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = false;

      settings = [
        {
          layer = "top";
          position = "top";
          height = 40;
          spacing = 0;

          modules-left = [
            "hyprland/workspaces"
            "mpris"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/nightshift"
            "pulseaudio"
            "network"
            "battery#bat0"
            "battery#bat1"
            "cpu"
            "temperature"
            "custom/vpn"
            "tray"
            "custom/cpugov"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            disable-scroll = false;
            all-outputs = false;
            format = "{id}";
            on-click = "activate";
          };

          mpris = {
            format = "{status_icon} {position} {title} — {artist}";
            format-paused = "{status_icon} {title} — {artist}";
            format-stopped = "";
            status-icons = {
              playing = "󰐊";
              paused = "󰏤";
              stopped = "";
            };
            interval = 1;
            max-length = 50;
            on-click = "playerctl play-pause";
            on-click-right = "playerctl next";
            on-click-middle = "playerctl previous";
          };

          clock = {
            format = "{:%H:%M}";
            locale = "en_US.UTF-8";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              format = {
                months = "<span color='${palette.accent}'><b>{}</b></span>";
                days = "<span color='${palette.text}'>{}</span>";
                weekdays = "<span color='${palette.muted}'><b>{}</b></span>";
                today = "<span color='${palette.urgent}'><b><u>{}</u></b></span>";
              };
            };
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰸈";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "pwvucontrol";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            tooltip-format = "{desc} — {volume}%";
            scroll-step = 5;
            max-volume = 100;
          };

          network = {
            interface = "wlp*";
            format-wifi = "󰤨 {signalStrength}%";
            format-ethernet = "󰈀";
            format-disconnected = "󰤭";
            tooltip-format-wifi = "{essid}  {ipaddr}";
            tooltip-format-ethernet = "{ifname}: {ipaddr}";
          };

          "custom/vpn" = {
            exec = ''bash -c 'VPN=$(nmcli -t -f TYPE,NAME con show --active 2>/dev/null | grep -E "(wireguard:ProtonVPN|^vpn:)" | cut -d: -f2); [ -n "$VPN" ] && echo "{\"text\":\"󰒃\",\"class\":\"connected\",\"tooltip\":\"$VPN\"}" || echo "{\"text\":\"\",\"class\":\"off\"}"' '';
            return-type = "json";
            interval = 5;
            tooltip = true;
          };

          "battery#bat0" = {
            bat = "BAT0";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-full = "󰁹";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip-format = "BAT0: {time} remaining";
          };

          "battery#bat1" = {
            bat = "BAT1";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-full = "󰁹";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip-format = "BAT1: {time} remaining";
          };

          cpu = {
            format = "󰻠 {usage}%";
            interval = 2;
            tooltip = false;
            on-click = "kitty btop";
          };

          temperature = {
            thermal-zone = 5;
            format = "{icon} {temperatureC}°C";
            format-icons = [
              "󰜗"
              "󰜗"
              "󰜗"
              "󰸁"
              "󰸁"
            ];
            critical-threshold = 80;
            interval = 2;
            tooltip = false;
            on-click = "kitty btop";
          };

          # Night shift toggle — starts/stops hyprsunset
          "custom/nightshift" = {
            exec = ''bash -c 'pgrep hyprsunset > /dev/null && echo "{\"text\":\"󰖔\",\"class\":\"on\"}" || echo "{\"text\":\"󰖙\",\"class\":\"off\"}"' '';
            return-type = "json";
            interval = 3;
            on-click = "bash -c 'pgrep hyprsunset > /dev/null && pkill hyprsunset || hyprsunset -t 3000 &'";
            tooltip = false;
          };

          # CPU governor toggle — calls /etc/cpugov-toggle via sudo (NOPASSWD)
          "custom/cpugov" = {
            exec = ''bash -c 'GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor); case $GOV in performance) echo "{\"text\":\"󰓅\",\"class\":\"perf\"}";; *) echo "{\"text\":\"󰾅\",\"class\":\"save\"}";; esac' '';
            return-type = "json";
            interval = 2;
            on-click = "/run/wrappers/bin/sudo /etc/cpugov-toggle";
            tooltip = false;
          };

          # Power menu — fuzzel dmenu
          "custom/power" = {
            format = "󰐥";
            on-click = ''bash -c 'pkill fuzzel; choice=$(echo -e "Logout\nRestart\nShutdown" | fuzzel --dmenu --minimal-lines --width=12 --prompt "Power> "); case "$choice" in Logout) hyprctl dispatch exit;; Restart) systemctl reboot;; Shutdown) systemctl poweroff;; esac' '';
            tooltip = false;
          };

          tray = {
            spacing = 8;
            icon-size = 15;
          };

        }
      ];

      inherit style;
    };
  };
}
