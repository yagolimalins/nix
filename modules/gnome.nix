{ config, pkgs, ... }:

{
  programs.gnome-shell = {
    enable = true;
    extensions = [
      {
        id = "user-theme@gnome-shell-extensions.gcampax.github.com";
        package = pkgs.gnome-shell-extensions;
      }
      {
        id = "blur-my-shell@aunetx";
        package = pkgs.gnomeExtensions.blur-my-shell;
      }
    ];
    theme = {
      name = "WhiteSur-Dark-solid";
      package = pkgs.whitesur-gtk-theme;
    };
  };
}
