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

      # Same Storm colors as mine.theme / Umbriel chrome.
      customPalettes.mine-storm = lib.${namespace}.mkNoctaliaStormPalette palette;

      settings = {
        shell = {
          polkit_agent = true;
          font_family = "Inter";
          corner_radius_scale = 0.6;
          # Bar panels dock near the click; launcher/session float centered.
          panel = {
            control_center_placement = "attached";
            wallpaper_placement = "attached";
            clipboard_placement = "attached";
            session_placement = "floating";
            launcher_placement = "floating";
            control_center_position = "auto";
            wallpaper_position = "auto";
            clipboard_position = "auto";
            session_position = "center";
            launcher_position = "center";
            open_near_click_control_center = true;
            open_near_click_wallpaper = true;
            open_near_click_clipboard = true;
            open_near_click_session = false;
            open_near_click_launcher = false;
          };
          # Simple launcher: search + apps only (no category chips). The panels
          # provider stays on, so the Wallhaven browser opens via /pan.
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

        theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "mine-storm";
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
          dnd = true;
          fingerprint = true;
          grace_period_seconds = 0;
          allow_empty_password = false;
          # Desktop freeze when screencopy works; else falls back to wallpaper.
          blurred_desktop = true;
          blur_intensity = 0.55;
          tint_intensity = 0.4;
          tint_color = "surface";
          transition = [ "fade" ];
          transition_duration = 800;
          edge_smoothness = 0.4;
          # Empty = lock UI on every output (ultrawide + laptop).
          monitors = [ ];
        };

        # Minimal login boxes: centered password field, Enter to unlock.
        lockscreen_widgets = {
          enabled = true;
          widget_order = [
            "lockscreen-login-box@DP-3"
            "lockscreen-login-box@HDMI-A-1"
            "lockscreen-login-box@eDP-1"
          ];
          widget = {
            # compact layout; 0 = Noctalia default size (~400px width cap).
            "lockscreen-login-box@DP-3" = {
              type = "login_box";
              output = "DP-3";
              cx = 1280.0;
              cy = 540.0; # geometric center of 2560x1080
              box_width = 0.0;
              box_height = 0.0;
              placement_width = 2560.0;
              placement_height = 1080.0;
              rotation = 0.0;
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                layout = "compact";
                show_keyboard_layout = true;
                show_caps_lock = false;
                show_password_reveal = false;
                show_login_button = false;
                show_unlock_hint = false;
                show_media = false;
                show_media_controls = false;
                show_weather = false;
                show_session_buttons = false;
              };
            };
            # Laptop ultrawide is HDMI-A-1; an unmatched output gets a regular box.
            "lockscreen-login-box@HDMI-A-1" = {
              type = "login_box";
              output = "HDMI-A-1";
              cx = 1280.0;
              cy = 540.0; # geometric center of 2560x1080
              box_width = 0.0;
              box_height = 0.0;
              placement_width = 2560.0;
              placement_height = 1080.0;
              rotation = 0.0;
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                layout = "compact";
                show_keyboard_layout = true;
                show_caps_lock = false;
                show_password_reveal = false;
                show_login_button = false;
                show_unlock_hint = false;
                show_media = false;
                show_media_controls = false;
                show_weather = false;
                show_session_buttons = false;
              };
            };
            "lockscreen-login-box@eDP-1" = {
              type = "login_box";
              output = "eDP-1";
              cx = 960.0;
              cy = 540.0; # geometric center of 1920x1080
              box_width = 0.0;
              box_height = 0.0;
              placement_width = 1920.0;
              placement_height = 1080.0;
              rotation = 0.0;
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                layout = "compact";
                show_keyboard_layout = true;
                show_caps_lock = false;
                show_password_reveal = false;
                show_login_button = false;
                show_unlock_hint = false;
                show_media = false;
                show_media_controls = false;
                show_weather = false;
                show_session_buttons = false;
              };
            };
          };
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

        # Night light schedule needs coordinates (also used by weather if re-enabled).
        location.auto_locate = true;

        # Replaces mine.nightshift (gammastep). Bar widget toggles on/force.
        nightlight = {
          enabled = true;
          force = false;
          temperature_day = 6500;
          temperature_night = 3000;
        };

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
          # Brightness cluster: volume → brightness → nightlight → caffeine.
          start = [
            "workspaces"
            "media"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "group:net"
            "group:audio"
            "group:metrics"
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
                "nightlight"
                "caffeine"
              ];
            }
            {
              id = "metrics";
              members = [
                "sysmon"
                "battery"
              ];
            }
          ];
        };

        widget = {
          # Pills without outer capsule — contrast with the right-side clusters.
          # Dynamic inventory: hide empties; labels only when occupied/active.
          workspaces = {
            capsule = false;
            style = "regular";
            label_source = "id";
            labels_only_when_occupied = true;
            hide_when_empty = false;
            show_tooltip = false;
            # Same size for active/inactive — only color marks focus.
            active_pill_size = 1.0;
            inactive_pill_size = 1.0;
            focused_color = "primary";
            occupied_color = "secondary";
            empty_color = "outline_variant";
            change_color_on_hover = true;
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
