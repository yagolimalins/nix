{ config, pkgs, ... }:

{
  xdg.desktopEntries.spotify-player = {
    name = "Spotify";
    exec = "kitty spotify_player";
    icon = "spotify";
    comment = "Terminal Spotify client";
    categories = [
      "Audio"
      "Music"
      "Player"
    ];
  };

  xdg.configFile."spotify-player/app.toml".text = ''
    [app_config]
    theme = "thinkpad"
  '';

  xdg.configFile."spotify-player/theme.toml".text = ''
    [[themes]]
    name = "thinkpad"
    [themes.palette]
    background     = "#0d0d0d"
    foreground     = "#dedede"
    black          = "#0d0d0d"
    red            = "#cc2222"
    green          = "#cc2222"
    yellow         = "#dedede"
    blue            = "#aaaaaa"
    magenta        = "#cc2222"
    cyan           = "#aaaaaa"
    white          = "#dedede"
    bright_black   = "#777777"
    bright_red     = "#e03333"
    bright_green   = "#e03333"
    bright_yellow  = "#ffffff"
    bright_blue    = "#cccccc"
    bright_magenta = "#e03333"
    bright_cyan    = "#cccccc"
    bright_white   = "#ffffff"
  '';

  home.packages = with pkgs; [

    # ── Nix ──────────────────────────────────────────────────
    nixfmt

    # ── Terminal ─────────────────────────────────────────────
    kitty

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

    # ── Communication ────────────────────────────────────────
    zoom-us
    anydesk

    # ── Music ────────────────────────────────────────────────
    spotify-player

    # ── Video ────────────────────────────────────────────────
    obs-studio
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
}
