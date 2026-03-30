{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

    # ── Nix ──────────────────────────────────────────────────
    nixfmt-rfc-style

    # ── Terminal ─────────────────────────────────────────────
    kitty

    # ── System monitoring ────────────────────────────────────
    btop
    fastfetch

    # ── Screenshots & clipboard ──────────────────────────────
    grimblast
    wl-clipboard

    # ── Desktop utilities ────────────────────────────────────
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    j4-dmenu-desktop
    xfce.tumbler

    # ── File viewers ─────────────────────────────────────────
    xfce.ristretto
    zathura

    # ── Fonts ────────────────────────────────────────────────
    jetbrains-mono
    nerd-fonts.jetbrains-mono

    # ── Editors & IDEs ───────────────────────────────────────
    claude-code
    vscode
    zed-editor
    jetbrains.idea
    # jetbrains.rider

    # ── Version control ──────────────────────────────────────
    git
    gh
    lazygit
    github-desktop

    # ── JavaScript / TypeScript ──────────────────────────────
    nodejs
    deno

    # ── JVM ──────────────────────────────────────────────────
    maven

    # ── Rust ─────────────────────────────────────────────────
    rustup

    # ── .NET ─────────────────────────────────────────────────
    dotnet-sdk_10
    dotnet-ef

    # ── Databases ────────────────────────────────────────────
    dbeaver-bin

    # ── API testing ──────────────────────────────────────────
    insomnia

    # ── Productivity ─────────────────────────────────────────
    libreoffice-fresh
    anki

    # ── Browsers ─────────────────────────────────────────────
    # google-chrome
    chromium

    # ── Communication ────────────────────────────────────────
    zoom-us

    # ── Music ────────────────────────────────────────────────
    spotify

    # ── Video ────────────────────────────────────────────────
    vlc
    kdePackages.kdenlive

    # ── Torrents ─────────────────────────────────────────────
    fragments

    # ── Audio production ─────────────────────────────────────
    reaper
    qpwgraph
    carla
    alsa-utils
    (pkgs.lsp-plugins.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -rf $out/share/applications
      '';
    }))

  ];
}
