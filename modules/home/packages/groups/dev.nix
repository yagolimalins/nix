# Package group: editors … gtk/dotnet + rust/gtk env (gated by mine.packages.enable).
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  on = group: cfg.enable && cfg.${group}.enable;

  waylandLibs = [
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.vulkan-loader
    pkgs.libGL
  ];

  rustNativeLibs = waylandLibs ++ [
    pkgs.alsa-lib
    pkgs.udev
  ];

  rustNativePkgConfig = [
    pkgs.wayland.dev
    pkgs.libxkbcommon.dev
    pkgs.vulkan-loader.dev
    pkgs.alsa-lib.dev
    pkgs.udev.dev
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
    (lib.mkIf (on "editors") {
      home.packages = [ pkgs.neovim ];
    })

    (lib.mkIf (on "ides") {
      home.packages = with pkgs; [
        vscode
        code-cursor
      ];
    })

    (lib.mkIf (on "cli") {
      home.packages = with pkgs; [
        ripgrep
        fd
        miniserve
      ];
    })

    (lib.mkIf (on "c") {
      home.packages = [ pkgs.gcc ];
    })

    (lib.mkIf (on "python") {
      home.packages = [ pkgs.uv ];
    })

    (lib.mkIf (on "ai") {
      home.packages = [ pkgs.claude-code ];
    })

    (lib.mkIf (on "vcs") {
      home.packages = with pkgs; [
        git
        gh
        lazygit
      ];
    })

    (lib.mkIf (on "js") {
      home.packages = with pkgs; [
        typescript
        nodejs
        deno
        tsx
      ];
    })

    (lib.mkIf (on "jvm") {
      home.packages = [ pkgs.maven ];
    })

    (lib.mkIf (on "rust") (
      let
        # Binary toolchain with wasm target (nixpkgs rustc has host only).
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
            "rust-analyzer"
          ];
          targets = [ "wasm32-unknown-unknown" ];
        };
      in
      {
        home.packages = with pkgs; [
          rustToolchain
          trunk
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
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        };

        home.file.".cargo/config.toml".text = ''
          [target.x86_64-unknown-linux-gnu]
          rustflags = ["-C", "link-arg=-fuse-ld=mold", "-C", "link-arg=-B${pkgs.mold}/bin"]
        '';
      }
    ))

    (lib.mkIf (on "gtk") {
      home.packages = gtkLibs;
    })

    (lib.mkIf (on "dotnet") {
      home.packages = with pkgs; [
        dotnet-sdk_10
        dotnet-ef
      ];
    })

    # Single assignments so rust/gtk/wayland groups don't clash under mkMerge.
    (lib.mkIf (cfg.enable && (cfg.rust.enable || cfg.gtk.enable)) {
      home.sessionVariables.PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" (
        lib.optionals cfg.rust.enable ([ pkgs.openssl.dev ] ++ rustNativePkgConfig)
        ++ lib.optionals cfg.gtk.enable gtkPkgConfig
      );
    })

    (lib.mkIf (cfg.enable && (cfg.wayland.enable || cfg.gtk.enable || cfg.rust.enable)) {
      home.sessionVariables.LD_LIBRARY_PATH = lib.makeLibraryPath (
        lib.optionals (cfg.wayland.enable || cfg.gtk.enable || cfg.rust.enable) (
          if cfg.rust.enable then rustNativeLibs else waylandLibs
        )
        ++ lib.optionals cfg.gtk.enable gtkLibs
      );
    })
  ];
}
