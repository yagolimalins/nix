{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;

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
  config = lib.mkMerge [
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

    (lib.mkIf cfg.dotnet.enable {
      home.packages = with pkgs; [
        dotnet-sdk_10
        dotnet-ef
      ];
    })

    # Single assignments so rust/gtk/wayland groups don't clash under mkMerge.
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
  ];
}
