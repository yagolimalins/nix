{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    whitesur-gtk-theme
    whitesur-icon-theme
    dconf-editor
    gnome-terminal
    gnome-tweaks
    jdk
    rustup
    vscode
    zed-editor
    jetbrains.idea-community-bin
    libreoffice-fresh
    dbeaver-bin
    insomnia
    github-desktop
    gnome-solanum
    reaper
    spotify
    vlc
    anki
    git
    gh
  ];
}
