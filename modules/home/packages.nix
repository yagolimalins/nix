#
# packages.nix — User package set
#
# Everything installed into the user profile, grouped by purpose, plus
# direnv/nix-direnv for automatic per-project dev shells.
#
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

    # ── Nix ──────────────────────────────────────────────────
    nixfmt

    # ── System monitoring ────────────────────────────────────
    btop
    fastfetch

    # ── Desktop utilities ────────────────────────────────────
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    seahorse
    tumbler

    # ── Screenshots & clipboard ──────────────────────────────
    grimblast
    wl-clipboard

    # ── File management ──────────────────────────────────────
    ristretto
    zathura

    # ── Fonts ────────────────────────────────────────────────
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # ── Editors & IDEs ───────────────────────────────────────
    neovim
    vscode
    zed-editor
    code-cursor
    jetbrains.idea

    # ── Dev tools ────────────────────────────────────────────
    ripgrep
    fd
    gcc
    claude-code
    uv

    # ── Version control ──────────────────────────────────────
    git
    gh
    lazygit
    github-desktop

    # ── JavaScript / TypeScript ──────────────────────────────
    typescript
    nodejs
    deno
    tsx

    # ── JVM ──────────────────────────────────────────────────
    maven

    # ── Rust ─────────────────────────────────────────────────
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    sqlx-cli
    sea-orm-cli

    # ── .NET ─────────────────────────────────────────────────
    dotnet-sdk_10
    dotnet-ef

    # ── Databases ────────────────────────────────────────────
    dbeaver-bin
    beekeeper-studio

    # ── API testing ──────────────────────────────────────────
    insomnia

    # ── Productivity ─────────────────────────────────────────
    libreoffice-fresh
    anki

    # ── Browsers ─────────────────────────────────────────────
    # google-chrome
    chromium

    # ── Security & privacy ───────────────────────────────────
    proton-vpn
    proton-pass
    protonmail-bridge
    thunderbird

    # ── Communication ────────────────────────────────────────
    zoom-us

    # ── Video ────────────────────────────────────────────────
    obs-studio
    popcorntime
    vlc
    kdePackages.kdenlive

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

  programs.direnv = {
    enable            = true;
    silent            = true; # suppress all direnv/nix-direnv log output
    nix-direnv.enable = true;
  };
}
