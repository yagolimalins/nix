{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    whitesur-gtk-theme
    whitesur-icon-theme
    dconf-editor
    gnome-tweaks
    rustup
    vscode
    zed-editor
    dbeaver-bin
    github-desktop
    spotify
    git
    gh
  ];
}
