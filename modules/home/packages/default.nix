# User package orchestrator. `enable` turns on direnv, defaults every group
# to on, and gates all group installs — leaf `*.enable = true` alone is not
# enough. Override with e.g. `mine.packages.ides.enable = false`.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  mkGroup = lib.mkEnableOption;

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
in
{
  imports = [
    ./groups/system.nix
    ./groups/desktop.nix
    ./groups/dev.nix
    ./groups/apps.nix
    ./groups/media.nix
  ];

  options.${namespace}.packages = {
    enable = mkGroup "user package orchestrator (direnv + default groups)";

    nix.enable = mkGroup "Nix tooling (nixfmt, nixd, nil)";
    monitoring.enable = mkGroup "system monitors (btop, fastfetch)";

    wayland.enable = mkGroup "Wayland session applets and helpers";
    clipboard.enable = mkGroup "screenshots and clipboard";
    viewers.enable = mkGroup "light file viewers";
    fonts.enable = mkGroup "user fonts";

    editors.enable = mkGroup "lightweight editors (neovim)";
    ides.enable = mkGroup "heavy IDEs";
    cli.enable = mkGroup "CLI search tools";
    c.enable = mkGroup "C toolchain (gcc)";
    python.enable = mkGroup "Python tooling (uv)";
    ai.enable = mkGroup "AI CLI tools";
    vcs.enable = mkGroup "version control";
    js.enable = mkGroup "JavaScript / TypeScript";
    jvm.enable = mkGroup "JVM tooling";
    rust.enable = mkGroup "Rust toolchain (stable + wasm32-unknown-unknown + trunk)";
    gtk.enable = mkGroup "GTK4/Libadwaita (Relm4, …)";
    dotnet.enable = mkGroup ".NET SDK";

    databases.enable = mkGroup "database GUIs";
    api.enable = mkGroup "API clients";
    office.enable = mkGroup "office suite";
    notes.enable = mkGroup "markdown / notes";
    learning.enable = mkGroup "flashcards / study";
    browsers.enable = mkGroup "browsers";
    proton.enable = mkGroup "Proton suite";
    mail.enable = mkGroup "mail client";
    communication.enable = mkGroup "communication apps";

    media.enable = mkGroup "media playback";
    creator.enable = mkGroup "recording / editing";
    audio.enable = mkGroup "audio production";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      ${namespace}.packages = lib.genAttrs groupNames (_: {
        enable = lib.mkDefault true;
      });

      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
      };
    })
  ];
}
