{ config, pkgs, username, ... }:

{
  home.username      = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion  = "25.05";

  nixpkgs.config.allowUnfree = true;

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  imports = [
    ./modules/home/packages.nix
    ./modules/home/theme.nix
    ./modules/home/hyprland.nix
    ./modules/home/waybar.nix
    ./modules/home/terminals.nix
    ./modules/home/launchers.nix
    ./modules/home/services.nix
  ];
}
