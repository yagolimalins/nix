# Shared Home Manager toggles + XDG basics (wired via homes.modules).
# Literal `mine` required — `${namespace}` hits an HM freeformType cycle here.
{ lib, ... }:

{
  home.stateVersion = "26.05";

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

  mine = lib.mine.enable-modules [
    "hyprland"
    "waybar"
    "launchers"
    "kitty"
    "shell"
    "notifications"
    "lockscreen"
    "nightshift"
    "mail"
    "thunar"
    "spotify"
    "theme"
    "packages"
    "input-remapper"
    "zed"
  ];
}
