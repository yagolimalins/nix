#
# homes/x86_64-linux/yago — Home Manager base
#
# The username/home directory are inferred by Snowfall Lib from this
# directory's name. Which modules under ./modules/home are active is
# declared below via the shared `enable-modules` helper (lib/default.nix).
#
# NOTE: unlike systems/x86_64-linux/*/default.nix, this file can't use
# `${namespace}` dynamically (tried an explicit `config = {...}` wrapper
# and a nested `imports` module — both still recurse). Home Manager is
# wired in as the *value* of the NixOS option `home-manager.users.<name>`,
# which has a `freeformType` that needs to inspect this module's merged
# config to validate it — and that inspection happens as part of
# resolving `home-manager.extraSpecialArgs` (where `namespace` comes
# from), so forcing `namespace` here wants `config`, which wants this
# file's own result first. `--impure` doesn't change this — it's a
# structural module-system cycle, not an impurity issue. The namespace
# (`snowfall.namespace` in flake.nix, currently "mine") has to be
# spelled out literally right here; every module *imported* from
# ./modules/home still reads/writes `config.${namespace}.*` dynamically
# without any issue.
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
