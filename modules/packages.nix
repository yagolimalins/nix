{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    whitesur-gtk-theme
    whitesur-icon-theme
    dconf-editor
    gnome-terminal
    gnome-tweaks
    nodejs
    deno
    jdk
    spring-boot-cli
    maven
    rustup
    vscode
    # zed-editor
    jetbrains.idea
    jetbrains-mono
    libreoffice-fresh
    dbeaver-bin
    insomnia
    github-desktop
    gnome-solanum
    # google-chrome
    chromium
    zoom-us
    reaper
    spotify
    vlc
    anki
    git
    gh
  ];
}
