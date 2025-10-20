{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    whitesur-gtk-theme
    whitesur-icon-theme
    dconf-editor
    gnome-terminal
    gnome-tweaks
    rustup
    vscode
    zed-editor
    libreoffice-fresh
    dbeaver-bin
    github-desktop
    reaper
    spotify
    vlc
    anki
    git
    gh
  ];
}
