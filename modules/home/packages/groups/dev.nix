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

  # zlib (and some others) put .pc files in share/pkgconfig, not lib/pkgconfig.
  mkPkgConfigPath =
    packages:
    lib.concatStringsSep ":" (
      lib.filter (p: p != "") [
        (lib.makeSearchPath "lib/pkgconfig" packages)
        (lib.makeSearchPath "share/pkgconfig" packages)
      ]
    );

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

  # Shared wry/tao stack (Dioxus desktop + Tauri).
  wryDesktopLibs = [
    pkgs.webkitgtk_4_1
    pkgs.gtk3
    pkgs.libayatana-appindicator
    pkgs.zlib
    pkgs.xdotool # libxdo — dioxus-desktop / muda link -lxdo
  ];

  # gtk3's .pc files pull zlib/atk/epoxy/etc. — without these, gdk-sys fails.
  wryDesktopPkgConfig = [
    pkgs.webkitgtk_4_1.dev
    pkgs.gtk3.dev
    pkgs.zlib.dev
    pkgs.atk.dev
    pkgs.libepoxy.dev
    pkgs.libffi.dev
    pkgs.pcre2.dev
    pkgs.xdotool
  ];

  # Tauri v2 Linux extras beyond the wry stack (see tauri.app prerequisites).
  tauriLibs = wryDesktopLibs ++ [
    pkgs.librsvg
    pkgs.xdotool
    pkgs.libsoup_3
    pkgs.glib-networking
    pkgs.dbus
  ];

  tauriPkgConfig = wryDesktopPkgConfig ++ [
    pkgs.librsvg.dev
    pkgs.libsoup_3.dev
    pkgs.dbus.dev
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

  cursorIcons =
    pkgs.runCommand "cursor-app-icons"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        src=${pkgs.code-cursor}/share/pixmaps/cursor.png
        for size in 32 48 64; do
          mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
          magick "$src" -filter Lanczos -resize "''${size}x''${size}" \
            "$out/share/icons/hicolor/''${size}x''${size}/apps/cursor.png"
        done
      '';

  # nixpkgs ships cursor-agent; upstream CLI entrypoint is also named agent.
  cursorAgentCli = pkgs.symlinkJoin {
    name = "cursor-agent-cli";
    paths = [ pkgs.cursor-cli ];
    postBuild = "ln -s cursor-agent $out/bin/agent";
  };

  # WebKitGTK on NixOS reads wrong font/DPI settings without schema paths + TLS GIO
  # modules (https://github.com/tauri-apps/tauri/issues/7354).
  webkitGtkSessionVars = {
    GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules";
    XDG_DATA_DIRS = lib.concatStringsSep ":" [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${config.home.profileDirectory}/share"
      "/etc/profiles/per-user/${config.home.username}/share"
      "/nix/var/nix/profiles/default/share"
      "/run/current-system/sw/share"
    ];
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf (on "ides") {
      home.packages = [
        pkgs.code-cursor
        cursorIcons
      ];

      programs.zed-editor = {
        enable = true;
        mutableUserSettings = false;

        extensions = [
          "csharp"
          "html"
          "java"
          "nix"
          "prisma"
          "proto"
          "sql"
          "tokyo-night"
          "toml"
          "xml"
        ];

        userSettings = {
          edit_predictions.provider = "zed";
          show_edit_predictions = false;
          format_on_save = "on";
          code_lens = "off";
          semantic_tokens = "combined";
          show_signature_help_after_edits = false;
          auto_signature_help = false;
          gutter.runnables = true;

          languages.Rust = {
            show_edit_predictions = false;
            format_on_save = "on";
            inlay_hints = {
              enabled = true;
              show_type_hints = false;
              show_parameter_hints = false;
              show_other_hints = false;
            };
          };

          project_panel.dock = "left";
          outline_panel.dock = "left";
          collaboration_panel.dock = "left";
          agent = {
            dock = "right";
            favorite_models = [ ];
            model_parameters = [ ];
          };
          git_panel.dock = "left";

          ui_font_size = 16;
          buffer_font_size = 15;
          theme = {
            mode = "dark";
            light = "One Light";
            dark = "Tokyo Night Storm";
          };

          lsp.rust-analyzer.initialization_options = {
            check = {
              command = "clippy";
              extraArgs = [
                "--"
                "-W"
                "clippy::pedantic"
              ];
            };
            completion.postfix.enable = true;
            rust.analyzerTargetDir = true;
            procMacro.enable = true;
            cargo = {
              buildScripts.enable = true;
              allFeatures = true;
            };
            inlayHints = {
              chainingHints.enable = false;
              maxLength = null;
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
              closureReturnTypeHints.enable = "always";
              bindingModeHints.enable = true;
            };
            imports = {
              granularity.group = "module";
              prefix = "self";
            };
          };
        };

        userKeymaps = [
          {
            context = "Editor";
            bindings = {
              shift-space = "task::Rerun";
            };
          }
        ];
      };
    })

    (lib.mkIf (on "c") {
      home.packages = [ pkgs.gcc ];
    })

    (lib.mkIf (on "python") {
      home.packages = [ pkgs.uv ];
    })

    (lib.mkIf (on "ai") {
      home.packages = [
        pkgs.claude-code
        cursorAgentCli
      ];
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
        tailwindcss_4
        prisma
      ];

      # Prisma 7 CLI wraps schema-engine; export for project-local `npx prisma` too.
      home.sessionVariables = {
        PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      };
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
          cargo-watch
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

        home.file.".cargo/config.toml".text =
          let
            moldFlags = [
              "-C"
              "link-arg=-fuse-ld=mold"
              "-C"
              "link-arg=-B${pkgs.mold}/bin"
            ];
            xdoFlags = lib.optionals (cfg.dioxus.enable || cfg.tauri.enable) [
              "-C"
              "link-arg=-L${pkgs.xdotool}/lib"
            ];
            rustflags = moldFlags ++ xdoFlags;
            flagsToml = lib.concatMapStringsSep ",\n    " (f: ''"${f}"'') rustflags;
          in
          ''
            [target.x86_64-unknown-linux-gnu]
            rustflags = [
                ${flagsToml}
            ]
          '';
      }
    ))

    (lib.mkIf (on "dioxus") {
      # Local dx 0.7.10 + wasm-bindgen 0.2.127 (nixpkgs dx is 0.7.9 / older bindgen).
      # dioxus-cli and deno both ship `bin/dx` — prefer Dioxus.
      home.packages = [
        (lib.hiPrio pkgs.${namespace}.dioxus-cli)
        (lib.hiPrio pkgs.${namespace}.wasm-bindgen-cli_0_2_127)
        pkgs.binaryen
        pkgs.lld
        pkgs.gsettings-desktop-schemas
      ] ++ wryDesktopLibs;
    })

    (lib.mkIf (cfg.enable && (cfg.dioxus.enable || cfg.tauri.enable)) {
      home.sessionVariables = webkitGtkSessionVars // {
        # mold/cc need this at link time for -lxdo (libxdo ships inside xdotool).
        LIBRARY_PATH = lib.makeSearchPath "lib" (
          if cfg.tauri.enable then tauriLibs else wryDesktopLibs
        );
      };
    })

    (lib.mkIf (on "tauri") {
      # Native libs stay on PKG_CONFIG_PATH / LD_LIBRARY_PATH only —
      # putting librsvg in home.packages conflicts with gdk-pixbuf's loaders.cache.
      home.packages = [
        pkgs.cargo-tauri
        pkgs.${namespace}.create-tauri-app
        pkgs.xdotool
        pkgs.gsettings-desktop-schemas
      ];

      # DMABUF workaround for NVIDIA blank WebKit windows only.
      # Do NOT set WEBKIT_DISABLE_COMPOSITING_MODE — breaks CSS scale on Intel/Wayland.
      home.sessionVariables.WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    })

    (lib.mkIf (on "gtk") {
      home.packages = gtkLibs;
    })

    (lib.mkIf (on "dotnet") {
      home.packages = with pkgs; [
        dotnet-sdk_10
        dotnet-ef
      ];
    })

    # Single assignments so rust/gtk/wayland/dioxus/tauri groups don't clash under mkMerge.
    (lib.mkIf (
      cfg.enable && (cfg.rust.enable || cfg.gtk.enable || cfg.dioxus.enable || cfg.tauri.enable)
    ) {
      home.sessionVariables.PKG_CONFIG_PATH = mkPkgConfigPath (
        lib.optionals cfg.rust.enable ([ pkgs.openssl.dev ] ++ rustNativePkgConfig)
        ++ lib.optionals cfg.gtk.enable gtkPkgConfig
        ++ lib.optionals cfg.dioxus.enable wryDesktopPkgConfig
        ++ lib.optionals cfg.tauri.enable tauriPkgConfig
      );
    })

    (lib.mkIf (
      cfg.enable
      && (
        cfg.wayland.enable
        || cfg.gtk.enable
        || cfg.rust.enable
        || cfg.dioxus.enable
        || cfg.tauri.enable
      )
    ) {
      home.sessionVariables.LD_LIBRARY_PATH = lib.makeLibraryPath (
        lib.optionals (cfg.wayland.enable || cfg.gtk.enable || cfg.rust.enable) (
          if cfg.rust.enable then rustNativeLibs else waylandLibs
        )
        ++ lib.optionals cfg.gtk.enable gtkLibs
        ++ lib.optionals cfg.dioxus.enable wryDesktopLibs
        ++ lib.optionals cfg.tauri.enable tauriLibs
      );
    })
  ];
}
