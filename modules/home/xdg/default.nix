#
# xdg — Mime defaults, XDG user dirs, HM force-overwrite for managed files
#
# Kept out of homes/common.nix so that file stays an enable-list like
# systems/common.nix.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.xdg;

  # Stub overrides in ~/.local/share/applications (wins over system/profile).
  hideFromLauncher = ids: lib.listToAttrs (
    map (id: {
      name = id;
      value = {
        name = id;
        noDisplay = true;
        exec = "true";
      };
    }) ids
  );
in
{
  options.${namespace}.xdg.enable = lib.mkEnableOption "XDG dirs, mime defaults, and HM force flags";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER = "firefox";

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };

    # CLI/demos/helpers that clutter fuzzel — keep Spotify, Blueman Manager, etc.
    xdg.desktopEntries = hideFromLauncher [
      "btop"
      "nvim"
      "org.gtk.Demo4"
      "org.gtk.WidgetFactory4"
      "org.gtk.PrintEditor4"
      "org.gtk.gtk4.NodeEditor"
      "org.gtk.Shaper"
      "blueman-adapters"
      "org.fcitx.Fcitx5"
      "org.fcitx.fcitx5-migrator"
      "kbd-layout-viewer5"
      "carla-control"
      "cups"
      "nm-connection-editor"
      "thunar-settings"
      "thunar-volman-settings"
      "thunar-bulk-rename"
    ];

    home.file = {
      "Desktop/.keep".text = "";
      "Development/.keep".text = "";
      "Documents/.keep".text = "";
      "Downloads/.keep".text = "";
      "Music/.keep".text = "";
      "Pictures/Screenshots/.keep".text = "";
      "Public/.keep".text = "";
      "Templates/.keep".text = "";
      "Videos/.keep".text = "";
    };

    # HM owns these; avoid races with other generators.
    xdg.configFile."gtk-3.0/settings.ini".force = true;
    xdg.configFile."gtk-4.0/settings.ini".force = true;
    xdg.configFile."mimeapps.list".force = true;
    xdg.dataFile."applications/mimeapps.list".force = true;
  };
}
