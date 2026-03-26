{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    whitesur-gtk-theme
    whitesur-icon-theme
    kitty
    grim
    slurp
    wl-clipboard
    playerctl
    networkmanagerapplet
    blueman
    brightnessctl
    nodejs
    deno
    maven
    rustup
    dotnet-sdk_10
    dotnet-ef
    claude-code
    vscode
    zed-editor
    jetbrains.idea
    # jetbrains.rider
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    libreoffice-fresh
    dbeaver-bin
    insomnia
    github-desktop
    # google-chrome
    chromium
    fragments
    zoom-us
    reaper
    kdePackages.kdenlive
    spotify
    vlc
    anki
    git
    gh
    lazygit
    btop
    xfce.thunar
  ];
}
