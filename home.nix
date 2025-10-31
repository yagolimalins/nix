{ config, pkgs, ... }:

{
  home.username = "yago";
  home.homeDirectory = "/home/yago";
  home.stateVersion = "25.05";
  
  nixpkgs.config.allowUnfree = true;

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  imports = [
    ./modules/packages.nix
    ./modules/theme.nix
    ./modules/gnome.nix
    ./modules/dconf.nix
  ];
}
