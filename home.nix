{ config, pkgs, ... }:

{
  home.username = "yago";
  home.homeDirectory = "/home/yago";
  home.stateVersion = "25.05";

  imports = [
    ./modules/packages.nix
    ./modules/theme.nix
    ./modules/gnome.nix
    ./modules/dconf.nix
  ];
}
