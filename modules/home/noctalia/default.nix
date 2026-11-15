#
# noctalia — Desktop shell (Quickshell / noctalia-qs)
#
# Autostarted by mine.umbriel. Bar, launcher, notifications, lock, wallpaper.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.noctalia;
  palette = lib.${namespace}.palette;
in
{
  options.${namespace}.noctalia.enable =
    lib.mkEnableOption "Noctalia shell (bar, launcher, notifications, lock, wallpaper)";

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      # Autostart from Umbriel general.autostart — not a systemd user unit.
      systemd.enable = false;
      settings = {
        shell = {
          polkit_agent = true;
          font_family = "Inter";
          corner_radius_scale = 0.6;
          # Bar panels dock near the click; session + wallhaven float centered.
          panel = {
            control_center_placement = "attached";
            wallpaper_placement = "attached";
            clipboard_placement = "attached";
            # Session/power menu floats centered; other panels stay bar-attached.
            session_placement = "floating";
            launcher_placement = "attached";
            control_center_position = "auto";
            wallpaper_position = "auto";
            clipboard_position = "auto";
            session_position = "center";
            launcher_position = "auto";
            open_near_click_control_center = true;
            open_near_click_wallpaper = true;
            open_near_click_clipboard = true;
            open_near_click_session = false;
            open_near_click_launcher = true;
          };
          # Simple launcher: search + apps only (no category chips / Providers view).
          launcher = {
            layout = "simple";
            categories = false;
            show_icons = true;
            compact = true;
          };
          # Default single-row power menu (no grid); hide keybind badges.
          session = {
            grid = false;
            show_shortcuts = false;
          };
        };

        # Closest builtin to Tokyo Night Storm (mine.theme palette).
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Tokyo-Night";
        };

        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          fill_color = palette.bg;
        };

        notification = {
          enable_daemon = true;
          background_opacity = 0.97;
          border = true;
          border_color = "outline_variant";
        };

        osd = {
          position = "top_right";
          background_opacity = 0.97;
        };

        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
          blur_intensity = 0.4;
          tint_intensity = 0.4;
          tint_color = "surface";
        };

        # Idle: lock after 10m, screen off shortly after.
        idle.behavior = {
          lock = {
            timeout = 600;
            action = "lock";
            enabled = true;
          };
          "screen-off" = {
            timeout = 660;
            action = "screen_off";
            enabled = true;
          };
        };

        # Weather tab needs this + location coordinates.
        weather = {
          enabled = true;
          unit = "celsius";
        };
        location.auto_locate = true;

        # Full-width bar: workspaces + media on the left; system cluster on the right.
        bar.default = {
          margin_ends = 0;
          margin_edge = 0;
          reserve_space = true;
          thickness = 32;
          padding = 12;
          widget_spacing = 8;
          radius = 0;
          capsule = true;
          capsule_fill = "surface_container";
          capsule_opacity = 0.9;
          capsule_padding = 8;
          capsule_radius = 8.0;
          # Left: workspaces → now-playing; center clock; right system cluster.
          start = [
            "workspaces"
            "media"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "group:net"
            "group:audio"
            "weather"
            "wallhaven"
            "sysmon"
            "battery"
            "notifications"
            "session"
          ];
          capsule_group = [
            {
              id = "net";
              members = [
                "network"
                "bluetooth"
              ];
            }
            {
              id = "audio";
              members = [
                "volume"
                "brightness"
              ];
            }
          ];
        };

        widget = {
          # Pills without outer capsule — contrast with the right-side clusters.
          workspaces = {
            capsule = false;
            style = "regular";
            label_source = "id";
            labels_only_when_occupied = true;
          };

          clock = {
            format = "{:%H:%M}";
            tooltip_format = "{:%A, %d %B %Y}";
          };

          # Track + artist text; no album art; hide when no player.
          media = {
            album_art_only = false;
            hide_album_art = true;
            hide_when_no_media = true;
            hide_artist = false;
            max_length = 180;
          };

          network.show_label = false;

          bluetooth.hide_when_adapter_off = true;

          volume.show_label = false;

          brightness = {
            show_label = false;
            show_when_unavailable = true;
          };

          # Glyph only — no temperature/condition text or hover peek.
          weather = {
            peek = false;
            show_condition = false;
            show_temperature = false;
            show_tooltip = false;
          };

          # Official Wallhaven browser panel.
          wallhaven = {
            type = "noctalia/wallhaven:wallhaven";
          };

          sysmon = {
            type = "sysmon";
            stat = "cpu_usage";
            visualization = "none";
            show_value = false;
            peek = true;
          };

          # Glyph only; reveal % on hover; hide when full on AC.
          battery = {
            show_label = false;
            peek = true;
            hide_when_full = true;
          };
        };

        # Widget clicks open only that tab (no sidebar of all CC sections).
        # Full Control Center (Home + sidebar) still available via control-center icon / dead-zone.
        control_center = {
          sidebar = "compact";
          sidebar_section = "none";
        };

        plugins.enabled = [ "noctalia/wallhaven" ];

        # Wallhaven browser — floating center (exception to bar-attached panels).
        plugin_settings."noctalia/wallhaven" = {
          browser_placement = "floating";
          browser_position = "center";
          browser_open_near_click = false;
        };
      };
    };
  };
}
