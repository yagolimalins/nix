#
# homes/common.nix — Modules and basics shared by every Home Manager user
#
# Wired into every home via `homes.modules` in flake.nix, so individual
# users under homes/x86_64-linux/*/default.nix only need to declare what's
# actually different about them. Add a module here once it's wanted for
# everyone; a user can still layer on extra `mine = lib.mine.enable-modules
# [ ... ]` entries of their own.
#
# The toggle attr must be the literal namespace ("mine") — same Home Manager
# freeformType cycle that prevents `${namespace}` in per-user entry points
# also applies to modules injected via homes.modules.
#
{ lib, ... }:

{
  home.stateVersion = "25.05";

  # XDG user directories (kept in git via .keep placeholders).
  home.file."Desktop/.keep".text = "";
  home.file."Development/.keep".text = "";
  home.file."Documents/.keep".text = "";
  home.file."Downloads/.keep".text = "";
  home.file."Music/.keep".text = "";
  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Public/.keep".text = "";
  home.file."Templates/.keep".text = "";
  home.file."Videos/.keep".text = "";

  # Let Home Manager own the GTK settings files.
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

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
  ];
}
