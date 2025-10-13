{ config, pkgs, ... }:

{
  programs.gnome-shell = {
    enable = true;
    extensions = [
      {
        id = "user-theme@gnome-shell-extensions.gcampax.github.com";
        package = pkgs.gnome-shell-extensions;
      }
    ];
    theme = {
      name = "WhiteSur-Dark-solid";
      package = pkgs.whitesur-gtk-theme;
    };
  };
}
