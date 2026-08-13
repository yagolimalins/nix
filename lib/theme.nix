# Tokyo Night Storm theme helpers (used by modules/home/theme/).
{ ... }:

let
  # Tokyo Night Storm — accent = selection/active; semantic colors for status only.
  palette = {
    bg = "#24283b";
    surface = "#1f2335";
    border = "#414868";
    text = "#c0caf5";
    muted = "#565f89";
    accent = "#7aa2f7";
    cyan = "#7dcfff";
    onAccent = "#1f2335";
    urgent = "#f7768e";
    warning = "#e0af68";
    ok = "#9ece6a";
    purple = "#bb9af7"; # terminal ANSI magenta only
  };
in
{
  inherit palette;

  vscodeTokyoNightSettings = {
    "workbench.colorTheme" = "Tokyo Night Storm";
    "workbench.preferredDarkColorTheme" = "Tokyo Night Storm";
    "window.autoDetectColorScheme" = false;
  };

  # HM fastfetch replaces the whole config — modules must be explicit.
  fastfetchDefaultModules = [
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

  mkBtopStormTheme = p: ''
    # Theme: mine-storm (Tokyo Night Storm palette)
    theme[main_bg]="${p.bg}"
    theme[main_fg]="${p.text}"
    theme[title]="${p.text}"
    theme[hi_fg]="${p.cyan}"
    theme[selected_bg]="${p.accent}"
    theme[selected_fg]="${p.onAccent}"
    theme[inactive_fg]="${p.muted}"
    theme[proc_misc]="${p.cyan}"
    theme[cpu_box]="${p.muted}"
    theme[mem_box]="${p.muted}"
    theme[net_box]="${p.muted}"
    theme[proc_box]="${p.muted}"
    theme[div_line]="${p.muted}"
    theme[temp_start]="${p.ok}"
    theme[temp_mid]="${p.warning}"
    theme[temp_end]="${p.urgent}"
    theme[cpu_start]="${p.ok}"
    theme[cpu_mid]="${p.warning}"
    theme[cpu_end]="${p.urgent}"
    theme[free_start]="${p.ok}"
    theme[free_mid]="${p.warning}"
    theme[free_end]="${p.urgent}"
    theme[cached_start]="${p.ok}"
    theme[cached_mid]="${p.warning}"
    theme[cached_end]="${p.urgent}"
    theme[available_start]="${p.ok}"
    theme[available_mid]="${p.warning}"
    theme[available_end]="${p.urgent}"
    theme[used_start]="${p.ok}"
    theme[used_mid]="${p.warning}"
    theme[used_end]="${p.urgent}"
    theme[download_start]="${p.ok}"
    theme[download_mid]="${p.warning}"
    theme[download_end]="${p.urgent}"
    theme[upload_start]="${p.ok}"
    theme[upload_mid]="${p.warning}"
    theme[upload_end]="${p.urgent}"
  '';

  # VS Code profile extensions.json entry for enkia.tokyo-night.
  mkVscodeTokyoNightExtEntry =
    {
      homeDirectory,
      extVersion,
    }:
    {
      identifier = {
        id = "enkia.tokyo-night";
        uuid = "1cac7443-911e-48b9-8341-49f3880c288a";
      };
      version = extVersion;
      location = {
        "$mid" = 1;
        path = "${homeDirectory}/.vscode/extensions/enkia.tokyo-night";
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
    };

  cursorTheme = {
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtkStormThemeName = "Tokyonight-Dark-Storm";
  numixSquareThemeName = "Numix-Square";
}
