# Shared Home Manager toggles (wired via homes.modules).
# Literal `mine` required — `${namespace}` hits an HM freeformType cycle here.
{ lib, ... }:

{
  home.stateVersion = "26.05";

  mine = lib.mine.enable-modules [
    "xdg"
    "hyprland"
    "waybar"
    "fuzzel"
    "kitty"
    "shell"
    "notifications"
    "lockscreen"
    "nightshift"
    "thunar"
    "theme"
    "packages"
    "input-remapper"
  ];
}
