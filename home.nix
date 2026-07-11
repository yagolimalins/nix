#
# home.nix — Home Manager base
#
# Sets up the user identity and XDG scaffolding, then imports every
# per-user module. Loaded by the flake as home-manager.users.<username>.
#
{ config, pkgs, username, ... }:

{
  home.username      = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion  = "25.05";

  nixpkgs.config.allowUnfree = true;

  # XDG user directories (kept in git via .keep placeholders).
  home.file."Desktop/.keep".text              = "";
  home.file."Development/.keep".text          = "";
  home.file."Documents/.keep".text            = "";
  home.file."Downloads/.keep".text            = "";
  home.file."Music/.keep".text                = "";
  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Public/.keep".text               = "";
  home.file."Templates/.keep".text            = "";
  home.file."Videos/.keep".text               = "";

  # Let Home Manager own the GTK settings files.
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  imports = [
    # ── Packages & theming ───────────────────────────────────
    ./modules/home/packages.nix
    ./modules/home/theme.nix

    # ── Compositor & bar ─────────────────────────────────────
    ./modules/home/hyprland.nix
    ./modules/home/waybar.nix
    ./modules/home/launchers.nix

    # ── Terminal & shell ─────────────────────────────────────
    ./modules/home/kitty.nix
    ./modules/home/shell.nix

    # ── Desktop services ─────────────────────────────────────
    ./modules/home/notifications.nix
    ./modules/home/lockscreen.nix
    ./modules/home/nightshift.nix
    ./modules/home/mail.nix

    # ── Applications ─────────────────────────────────────────
    ./modules/home/spotify.nix
  ];
}
