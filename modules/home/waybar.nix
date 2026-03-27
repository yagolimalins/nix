{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = [{
      layer    = "top";
      position = "top";
      height   = 36;
      spacing  = 0;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "pulseaudio" "network" "battery"
        "cpu" "temperature"
        "custom/nightshift"
        "tray" "custom/cpugov"
        "custom/logout" "custom/restart" "custom/shutdown"
      ];

      "hyprland/workspaces" = {
        disable-scroll = false;
        all-outputs    = false;
        format         = "{id}";
        on-click       = "activate";
      };

      "hyprland/window" = {
        max-length       = 60;
        separate-outputs = true;
      };

      clock = {
        format     = "{:%H:%M}";
        format-alt = "{:%a, %b %d}";
        locale     = "en_US.UTF-8";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode   = "month";
          format = {
            months   = "<span color='#cc2222'><b>{}</b></span>";
            days     = "<span color='#dedede'>{}</span>";
            weekdays = "<span color='#7a7a7a'><b>{}</b></span>";
            today    = "<span color='#e63329'><b><u>{}</u></b></span>";
          };
        };
      };

      pulseaudio = {
        format        = "{icon} {volume}%";
        format-muted  = "󰸈";
        format-icons  = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click      = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        tooltip-format = "{desc} — {volume}%";
        scroll-step   = 5;
      };

      network = {
        format-wifi       = "󰤨 {signalStrength}%";
        format-ethernet   = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format-wifi     = "{essid}  {ipaddr}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}";
      };

      battery = {
        states          = { warning = 30; critical = 15; };
        format          = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-full     = "󰁹";
        format-icons    = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format  = "{time} remaining";
        bat-compatibility = true;
      };

      cpu = {
        format   = "󰻠 {usage}%";
        interval = 2;
        tooltip  = false;
      };

      temperature = {
        thermal-zone       = 5;
        format             = "{icon} {temperatureC}°C";
        format-icons       = [ "󰜗" "󰜗" "󰜗" "󰸁" "󰸁" ];
        critical-threshold = 80;
        interval           = 2;
        tooltip            = false;
      };

      # Night shift toggle — starts/stops hyprsunset
      "custom/nightshift" = {
        exec        = ''bash -c 'pgrep hyprsunset > /dev/null && echo "{\"text\":\"󰖔\",\"class\":\"on\"}" || echo "{\"text\":\"󰖙\",\"class\":\"off\"}"' '';
        return-type = "json";
        interval    = 3;
        on-click    = "bash -c 'pgrep hyprsunset > /dev/null && pkill hyprsunset || hyprsunset -t 3000 &'";
        tooltip     = false;
      };

      # CPU governor toggle — calls /etc/cpugov-toggle via sudo (NOPASSWD)
      "custom/cpugov" = {
        exec        = ''bash -c 'GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor); case $GOV in performance) echo "{\"text\":\"performance\",\"class\":\"perf\"}";; *) echo "{\"text\":\"powersave\",\"class\":\"save\"}";; esac' '';
        return-type = "json";
        interval    = 2;
        on-click    = "/run/wrappers/bin/sudo /etc/cpugov-toggle";
        tooltip     = false;
      };

      tray = {
        spacing   = 8;
        icon-size = 15;
      };

      "custom/logout" = {
        format   = "logout";
        on-click = "pgrep wofi || echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Logout?' --width 140 --height 110 | grep -qx 'Yes' && hyprctl dispatch exit";
        tooltip  = false;
      };

      "custom/restart" = {
        format   = "restart";
        on-click = "pgrep wofi || echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Restart?' --width 140 --height 110 | grep -qx 'Yes' && systemctl reboot";
        tooltip  = false;
      };

      "custom/shutdown" = {
        format   = "shutdown";
        on-click = "pgrep wofi || echo -e 'Yes\nNo' | wofi --dmenu --prompt 'Shutdown?' --width 140 --height 110 | grep -qx 'Yes' && systemctl poweroff";
        tooltip  = false;
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

      /* ── Workspaces ─────────────────────────────────── */
      #workspaces { margin: 0 4px; }

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

      /* ── Window title ───────────────────────────────── */
      #window { padding: 0 10px; color: #7a7a7a; }

      /* ── Shared module base ─────────────────────────── */
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

      #clock { font-weight: bold; letter-spacing: 0.5px; }

      #pulseaudio       { color: #dedede; }
      #pulseaudio.muted { color: #7a7a7a; }

      #network              { color: #dedede; }
      #network.disconnected { color: #cc2222; }

      #battery          { color: #dedede; }
      #battery.warning  { color: #e8a045; }
      #battery.critical { color: #cc2222; }
      #battery.charging { color: #5a9e5a; }

      #cpu { color: #dedede; }

      #temperature          { color: #dedede; }
      #temperature.critical { color: #cc2222; }

      #custom-nightshift.on  { color: #e8a045; }
      #custom-nightshift.off { color: #7a7a7a; }

      #custom-cpugov.perf { color: #cc2222; }
      #custom-cpugov.save { color: #5a9e5a; }

      #tray > .needs-attention { border-color: #cc2222; }

      /* ── Calendar tooltip ───────────────────────────── */
      tooltip {
        background-color: #0d0d0d;
        border: 1px solid #cc2222;
        border-radius: 4px;
        padding: 8px;
      }

      tooltip label { font-size: 16px; color: #dedede; }

      /* ── Power buttons ──────────────────────────────── */
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
}
