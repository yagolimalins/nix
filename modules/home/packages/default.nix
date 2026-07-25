#
# packages.nix — User package set (split into toggles)
#
# `mine.packages.enable` turns on direnv and, by default, every package
# group below. Flip individual groups off without dropping the rest:
#
#   mine.packages.creator.enable = false;
#   mine.packages.ides.enable = false;
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;

  mkGroup = desc: lib.mkEnableOption desc;

  # Groups that `packages.enable` turns on by default. Override any one
  # with `mine.packages.<name>.enable = false`.
  groupNames = [
    "nix"
    "monitoring"
    "wayland"
    "clipboard"
    "viewers"
    "fonts"
    "editors"
    "ides"
    "cli"
    "c"
    "python"
    "ai"
    "vcs"
    "js"
    "jvm"
    "rust"
    "gtk"
    "dotnet"
    "databases"
    "api"
    "office"
    "notes"
    "learning"
    "browsers"
    "proton"
    "mail"
    "communication"
    "media"
    "creator"
    "audio"
  ];

  defaultGroups = lib.mkIf cfg.enable {
    ${namespace}.packages = lib.genAttrs groupNames (_: {
      enable = lib.mkDefault true;
    });
  };

  waylandLibs = [
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.vulkan-loader
    pkgs.libGL
  ];

  gtkLibs = [
    pkgs.gtk4
    pkgs.libadwaita
    pkgs.glib
    pkgs.cairo
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.graphene
    pkgs.harfbuzz
  ];

  gtkPkgConfig = [
    pkgs.gtk4.dev
    pkgs.libadwaita.dev
    pkgs.glib.dev
    pkgs.cairo.dev
    pkgs.pango.dev
    pkgs.gdk-pixbuf.dev
    pkgs.graphene.dev
    pkgs.harfbuzz.dev
    pkgs.vulkan-loader.dev
  ];
in
{
  options.${namespace}.packages = {
    enable = lib.mkEnableOption "user package orchestrator (direnv + default groups)";

    # ── Meta / system ─────────────────────────────────────────
    nix.enable = mkGroup "Nix tooling (nixfmt, nixd, nil)";
    monitoring.enable = mkGroup "system monitors (btop, fastfetch)";

    # ── Desktop shell ─────────────────────────────────────────
    wayland.enable = mkGroup "Wayland session applets and helpers";
    clipboard.enable = mkGroup "screenshots and clipboard (grimblast, wl-clipboard)";
    viewers.enable = mkGroup "light file viewers (ristretto, zathura)";
    fonts.enable = mkGroup "user fonts (JetBrains Mono, nerd fonts)";

    # ── Editing ───────────────────────────────────────────────
    editors.enable = mkGroup "terminal/lightweight editors (neovim)";
    ides.enable = mkGroup "heavy IDEs (VS Code, Zed, Cursor, IntelliJ)";

    # ── General tooling ───────────────────────────────────────
    cli.enable = mkGroup "CLI search tools (ripgrep, fd)";
    c.enable = mkGroup "C toolchain (gcc)";
    python.enable = mkGroup "Python tooling (uv)";
    ai.enable = mkGroup "AI CLI tools (claude-code)";
    vcs.enable = mkGroup "version control (git, gh, lazygit)";

    # ── Language stacks ───────────────────────────────────────
    js.enable = mkGroup "JavaScript / TypeScript toolchain";
    jvm.enable = mkGroup "JVM tooling (maven)";
    rust.enable = mkGroup "Rust toolchain (rustc, cargo, mold, sccache, …)";
    gtk.enable = mkGroup "GTK4/Libadwaita libs for Relm4 and similar";
    dotnet.enable = mkGroup ".NET SDK + ef";

    # ── Data / APIs ───────────────────────────────────────────
    databases.enable = mkGroup "database GUIs";
    api.enable = mkGroup "API clients (insomnia)";

    # ── Productivity ──────────────────────────────────────────
    office.enable = mkGroup "office suite (LibreOffice)";
    notes.enable = mkGroup "markdown/notes (marktext, glow)";
    learning.enable = mkGroup "flashcards / study (anki)";
    browsers.enable = mkGroup "browsers";

    # ── Privacy / comms ───────────────────────────────────────
    proton.enable = mkGroup "Proton VPN / Pass / Mail Bridge";
    mail.enable = mkGroup "mail client (Thunderbird)";
    communication.enable = mkGroup "communication apps (Zoom)";

    # ── Media ─────────────────────────────────────────────────
    media.enable = mkGroup "media playback (VLC, PopcornTime)";
    creator.enable = mkGroup "recording / editing (OBS, Kdenlive)";
    audio.enable = mkGroup "audio production (REAPER, Carla, …)";
  };

  config = lib.mkMerge [
    defaultGroups

    (lib.mkIf cfg.enable {
      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
      };
    })

    (lib.mkIf cfg.nix.enable {
      home.packages = with pkgs; [
        nixfmt
        nixd
        nil
      ];
    })

    (lib.mkIf cfg.monitoring.enable {
      home.packages = with pkgs; [
        btop
        fastfetch
      ];
    })

    (lib.mkIf cfg.wayland.enable {
      home.packages = with pkgs; [
        playerctl
        brightnessctl
        networkmanagerapplet
        blueman
        seahorse
        tumbler
      ];
    })

    (lib.mkIf cfg.clipboard.enable {
      home.packages = with pkgs; [
        grimblast
        wl-clipboard
      ];
    })

    (lib.mkIf cfg.viewers.enable {
      home.packages = with pkgs; [
        ristretto
        zathura
      ];
    })

    (lib.mkIf cfg.fonts.enable {
      home.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
    })

    (lib.mkIf cfg.editors.enable {
      home.packages = [ pkgs.neovim ];
    })

    (lib.mkIf cfg.ides.enable {
      home.packages = with pkgs; [
        vscode
        zed-editor
        code-cursor
        jetbrains.idea
      ];
    })

    (lib.mkIf cfg.cli.enable {
      home.packages = with pkgs; [
        ripgrep
        fd
      ];
    })

    (lib.mkIf cfg.c.enable {
      home.packages = [ pkgs.gcc ];
    })

    (lib.mkIf cfg.python.enable {
      home.packages = [ pkgs.uv ];
    })

    (lib.mkIf cfg.ai.enable {
      home.packages = [ pkgs.claude-code ];
    })

    (lib.mkIf cfg.vcs.enable {
      home.packages = with pkgs; [
        git
        gh
        lazygit
      ];
    })

    (lib.mkIf cfg.js.enable {
      home.packages = with pkgs; [
        typescript
        nodejs
        deno
        tsx
      ];
    })

    (lib.mkIf cfg.jvm.enable {
      home.packages = [ pkgs.maven ];
    })

    (lib.mkIf cfg.rust.enable {
      home.packages = with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
        sqlx-cli
        sea-orm-cli
        pkg-config
        openssl
        mold
        sccache
      ];

      home.sessionVariables = {
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
        RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };

      home.file.".cargo/config.toml".text = ''
        [target.x86_64-unknown-linux-gnu]
        rustflags = ["-C", "link-arg=-fuse-ld=mold", "-C", "link-arg=-B${pkgs.mold}/bin"]
      '';
    })

    (lib.mkIf cfg.gtk.enable {
      home.packages = gtkLibs;
    })

    # Shared env paths — one assignment each so groups don't mkMerge-clash.
    (lib.mkIf (cfg.rust.enable || cfg.gtk.enable) {
      home.sessionVariables.PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" (
        lib.optionals cfg.rust.enable [ pkgs.openssl.dev ] ++ lib.optionals cfg.gtk.enable gtkPkgConfig
      );
    })

    (lib.mkIf (cfg.wayland.enable || cfg.gtk.enable) {
      home.sessionVariables.LD_LIBRARY_PATH = lib.makeLibraryPath (
        lib.optionals (cfg.wayland.enable || cfg.gtk.enable) waylandLibs
        ++ lib.optionals cfg.gtk.enable gtkLibs
      );
    })

    (lib.mkIf cfg.dotnet.enable {
      home.packages = with pkgs; [
        dotnet-sdk_10
        dotnet-ef
      ];
    })

    (lib.mkIf cfg.databases.enable {
      home.packages = with pkgs; [
        dbeaver-bin
        beekeeper-studio
      ];
    })

    (lib.mkIf cfg.api.enable {
      home.packages = [ pkgs.insomnia ];
    })

    (lib.mkIf cfg.office.enable {
      home.packages = [ pkgs.libreoffice-fresh ];
    })

    (lib.mkIf cfg.notes.enable {
      home.packages = with pkgs; [
        marktext
        glow
      ];
    })

    (lib.mkIf cfg.learning.enable {
      home.packages = [ pkgs.anki ];
    })

    (lib.mkIf cfg.browsers.enable {
      home.packages = [ pkgs.chromium ];
    })

    (lib.mkIf cfg.proton.enable {
      home.packages = with pkgs; [
        proton-vpn
        proton-pass
        protonmail-bridge
      ];
    })

    (lib.mkIf cfg.mail.enable {
      home.packages = [ pkgs.thunderbird ];
    })

    (lib.mkIf cfg.communication.enable {
      home.packages = [ pkgs.zoom-us ];
    })

    (lib.mkIf cfg.media.enable {
      home.packages = with pkgs; [
        vlc
        popcorntime
      ];
    })

    (lib.mkIf cfg.creator.enable {
      home.packages = with pkgs; [
        obs-studio
        kdePackages.kdenlive
      ];
    })

    (lib.mkIf cfg.audio.enable {
      xdg.desktopEntries.reaper = {
        name = "REAPER";
        exec = "pw-jack reaper %U";
        icon = "cockos-reaper";
        comment = "Digital Audio Workstation";
        categories = [
          "Audio"
          "AudioVideo"
        ];
      };

      xdg.desktopEntries."cockos-reaper" = {
        name = "REAPER";
        exec = "pw-jack reaper %U";
        noDisplay = true;
      };

      home.packages = with pkgs; [
        reaper
        qpwgraph
        carla
        alsa-utils
      ];
    })
  ];
}
