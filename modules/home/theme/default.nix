#
# theme — Tokyo Night Storm GTK + Qt + native app themes
#
{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
  pkgCfg = config.${namespace}.packages;
  on = group: pkgCfg.enable && pkgCfg.${group}.enable;
  palette = lib.${namespace}.palette;
  cursorName = "Bibata-Modern-Ice";
  cursorSize = 24;

  gtkTheme = pkgs.tokyonight-gtk-theme.override {
    tweakVariants = [ "storm" ];
  };

  gtkThemeConfig = {
    name = "Tokyonight-Dark-Storm";
    package = gtkTheme;
  };

  # Storm GTK uses cyan for selection; force accent to match Waybar/Kitty/Fuzzel.
  gtkSelectionCss = ''
    @define-color theme_selected_bg_color ${palette.accent};
    @define-color theme_selected_fg_color ${palette.onAccent};
    @define-color accent_bg_color ${palette.accent};
    @define-color accent_color ${palette.accent};

    .view:selected,
    .view:selected:focus,
    iconview:selected,
    iconview:selected:focus,
    treeview:selected,
    treeview:selected:focus,
    row:selected,
    row:selected:focus {
      background-color: ${palette.accent};
      color: ${palette.onAccent};
    }

    .thunar .sidebar treeview:selected,
    .thunar .sidebar treeview:selected:focus,
    .thunar .sidebar row:selected,
    .thunar .sidebar row:selected:focus {
      background-color: ${palette.accent};
      color: ${palette.onAccent};
    }
  '';

  tokyoNightExt = pkgs.vscode-extensions.enkia.tokyo-night;

  vscodeSettings = {
    "workbench.colorTheme" = "Tokyo Night Storm";
    "workbench.preferredDarkColorTheme" = "Tokyo Night Storm";
    "window.autoDetectColorScheme" = false;
  };

  # VS Code profiles isolate extension enablement; settings alone can't load the theme.
  vscodeProfileThemeScript = pkgs.writeShellScript "vscode-apply-profile-themes" ''
    set -euo pipefail
    theme='${builtins.toJSON vscodeSettings}'
    tokyoExt='${builtins.toJSON {
      identifier = {
        id = "enkia.tokyo-night";
        uuid = "1cac7443-911e-48b9-8341-49f3880c288a";
      };
      version = tokyoNightExt.version;
      location = {
        "$mid" = 1;
        path = "${config.home.homeDirectory}/.vscode/extensions/enkia.tokyo-night";
        scheme = "file";
      };
      relativeLocation = "enkia.tokyo-night";
      metadata = {
        id = "1cac7443-911e-48b9-8341-49f3880c288a";
        publisherDisplayName = "enkia";
        publisherId = "745c7670-02e7-4a27-b662-e1b5719f2ba7";
        isApplicationScoped = true;
        isPreReleaseVersion = false;
      };
    }}'
    profilesDir="${config.xdg.configHome}/Code/User/profiles"
    globalExt="${config.home.homeDirectory}/.vscode/extensions/extensions.json"

    apply_theme() {
      local file="$1"
      mkdir -p "$(dirname "$file")"
      if [ -f "$file" ]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$file" <(printf '%s' "$theme") > "$file.new"
        mv "$file.new" "$file"
      else
        printf '%s\n' "$theme" > "$file"
      fi
    }

    enable_theme_ext() {
      local file="$1"
      mkdir -p "$(dirname "$file")"
      if [ -f "$file" ]; then
        ${pkgs.jq}/bin/jq --argjson ext "$tokyoExt" '
          if any(.[]?; .identifier.id == "enkia.tokyo-night") then .
          else . + [$ext]
          end
        ' "$file" > "$file.new"
        mv "$file.new" "$file"
      else
        ${pkgs.jq}/bin/jq -n --argjson ext "$tokyoExt" '[$ext]' > "$file"
      fi
    }

    if [ -f "$globalExt" ]; then
      ${pkgs.jq}/bin/jq '
        map(
          if .identifier.id == "enkia.tokyo-night" then
            .metadata = ((.metadata // {}) + {"isApplicationScoped": true})
          else .
          end
        )
      ' "$globalExt" > "$globalExt.new"
      mv "$globalExt.new" "$globalExt"
    fi

    if [ -d "$profilesDir" ]; then
      for profileDir in "$profilesDir"/*/; do
        [ -d "$profileDir" ] || continue
        apply_theme "''${profileDir}settings.json"
        enable_theme_ext "''${profileDir}extensions.json"
      done
    fi
  '';

  btopStormTheme = ''
    # Theme: mine-storm (Tokyo Night Storm palette)
    theme[main_bg]="${palette.bg}"
    theme[main_fg]="${palette.text}"
    theme[title]="${palette.text}"
    theme[hi_fg]="${palette.cyan}"
    theme[selected_bg]="${palette.accent}"
    theme[selected_fg]="${palette.onAccent}"
    theme[inactive_fg]="${palette.muted}"
    theme[proc_misc]="${palette.cyan}"
    theme[cpu_box]="${palette.muted}"
    theme[mem_box]="${palette.muted}"
    theme[net_box]="${palette.muted}"
    theme[proc_box]="${palette.muted}"
    theme[div_line]="${palette.muted}"
    theme[temp_start]="${palette.ok}"
    theme[temp_mid]="${palette.warning}"
    theme[temp_end]="${palette.urgent}"
    theme[cpu_start]="${palette.ok}"
    theme[cpu_mid]="${palette.warning}"
    theme[cpu_end]="${palette.urgent}"
    theme[free_start]="${palette.ok}"
    theme[free_mid]="${palette.warning}"
    theme[free_end]="${palette.urgent}"
    theme[cached_start]="${palette.ok}"
    theme[cached_mid]="${palette.warning}"
    theme[cached_end]="${palette.urgent}"
    theme[available_start]="${palette.ok}"
    theme[available_mid]="${palette.warning}"
    theme[available_end]="${palette.urgent}"
    theme[used_start]="${palette.ok}"
    theme[used_mid]="${palette.warning}"
    theme[used_end]="${palette.urgent}"
    theme[download_start]="${palette.ok}"
    theme[download_mid]="${palette.warning}"
    theme[download_end]="${palette.urgent}"
    theme[upload_start]="${palette.ok}"
    theme[upload_mid]="${palette.warning}"
    theme[upload_end]="${palette.urgent}"
  '';
in
{
  options.${namespace}.theme.enable =
    lib.mkEnableOption "Tokyo Night Storm (GTK/Qt + native app themes)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          name = cursorName;
          package = pkgs.bibata-cursors;
          size = cursorSize;
        };

        home.sessionVariables = {
          XCURSOR_THEME = cursorName;
          XCURSOR_SIZE = toString cursorSize;
        };

        wayland.windowManager.hyprland.settings.env = [
          "XCURSOR_THEME,${cursorName}"
          "XCURSOR_SIZE,${toString cursorSize}"
        ];

        qt = {
          enable = true;
          platformTheme.name = "gtk";
        };

        gtk = {
          enable = true;
          theme = gtkThemeConfig;
          iconTheme = {
            name = "WhiteSur-dark";
            package = pkgs.whitesur-icon-theme;
          };
          cursorTheme = {
            name = cursorName;
            package = pkgs.bibata-cursors;
            size = cursorSize;
          };
          gtk3.extraCss = gtkSelectionCss;
          gtk4 = {
            theme = gtkThemeConfig;
            extraCss = gtkSelectionCss;
          };
        };

        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      }

      (lib.mkIf (on "editors") {
        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          defaultEditor = false;
          plugins = with pkgs.vimPlugins; [
            {
              plugin = tokyonight-nvim;
              type = "lua";
              config = ''
                require("tokyonight").setup({ style = "storm" })
                vim.cmd.colorscheme("tokyonight-storm")
              '';
            }
          ];
        };

        programs.helix = {
          enable = true;
          defaultEditor = false;
          settings.theme = "tokyonight_storm";
        };
      })

      (lib.mkIf (on "ides") {
        programs.vscode = {
          enable = true;
          profiles.default = {
            userSettings = vscodeSettings;
            extensions = [ tokyoNightExt ];
          };
        };

        home.activation.vscodeProfileThemes =
          inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run ${vscodeProfileThemeScript}
          '';

        xdg.configFile."Cursor/User/settings.json".text = builtins.toJSON vscodeSettings;

        home.file.".cursor/extensions/enkia.tokyo-night".source =
          "${tokyoNightExt}/share/vscode/extensions/enkia.tokyo-night";
      })

      (lib.mkIf (on "monitoring") {
        xdg.configFile."btop/themes/mine-storm.theme".text = btopStormTheme;
        xdg.configFile."btop/btop.conf".text = ''
          color_theme = "mine-storm"
          theme_background = True
        '';

        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              color = {
                "1" = palette.accent;
                "2" = palette.cyan;
                "3" = palette.purple;
              };
              padding.right = 2;
            };
            display = {
              separator = "  ";
              color = {
                keys = palette.accent;
                title = palette.text;
                output = palette.text;
                separator = palette.muted;
              };
            };
            # HM replaces the whole config file — include modules or only the logo prints.
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "wmtheme"
              "theme"
              "icons"
              "font"
              "cursor"
              "terminal"
              "terminalfont"
              "cpu"
              "gpu"
              "memory"
              "swap"
              "disk"
              "localip"
              "battery"
              "poweradapter"
              "locale"
              "break"
              "colors"
            ];
          };
        };
      })

      (lib.mkIf (on "viewers") {
        programs.zathura = {
          enable = true;
          options = {
            # Keep original document colors (recolor breaks EPUB/PDF syntax highlighting).
            recolor = false;
            "default-bg" = palette.bg;
            "default-fg" = palette.text;
            "statusbar-bg" = palette.surface;
            "statusbar-fg" = palette.text;
            "highlight-color" = palette.accent;
            "highlight-active-color" = palette.cyan;
            "index-bg" = palette.surface;
            "index-fg" = palette.muted;
          };
        };
      })

      (lib.mkIf (on "browsers") {
        xdg.configFile."chromium/Initial Preferences".text = builtins.toJSON {
          distribution = {
            import_search_engine = false;
            make_chrome_default_for_user = false;
            skip_first_run_ui = true;
          };
          browser.theme = {
            color_scheme = 2;
            user_color2 = 0;
          };
        };
      })
    ]
  );
}
