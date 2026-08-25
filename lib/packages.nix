# Home Manager package group helpers (mine.packages.*).
# Custom flake derivations live in top-level packages/ — not here.
{ lib, ... }:

let
  # Single source of truth for mine.packages.<group>.enable options.
  packageGroups = {
    nix = "Nix tooling (nixfmt, nixd, nil)";
    monitoring = "system monitors (btop, bottom, fastfetch) + stress (s-tui, stress-ng)";

    wayland = "Wayland session applets and helpers";
    clipboard = "screenshots and clipboard";
    viewers = "light file viewers";
    fonts = "user fonts";

    editors = "lightweight editors (neovim, helix)";
    ides = "heavy IDEs (VS Code, Cursor, Zed)";
    cli = "CLI essentials (fzf, bat, broot, yazi, …)";
    c = "C toolchain (gcc)";
    python = "Python tooling (uv)";
    ai = "AI CLI tools";
    vcs = "version control";
    js = "JavaScript / TypeScript";
    jvm = "JVM tooling";
    rust = "Rust toolchain (stable + wasm32-unknown-unknown + trunk)";
    dioxus = "Dioxus CLI + web/desktop native deps";
    tauri = "Tauri CLI, create-tauri-app, + Linux WebKit/GTK deps";
    gtk = "GTK4/Libadwaita (Relm4, …)";
    dotnet = ".NET SDK";

    databases = "database GUIs";
    api = "API clients";
    office = "office suite";
    notes = "markdown / notes";
    learning = "flashcards / study";
    browsers = "browsers";
    proton = "Proton suite (VPN, Pass, Mail Bridge)";
    mail = "mail client";
    communication = "communication apps";

    media = "media playback (VLC, Popcorn Time, spotify-player)";
    creator = "recording / editing";
    audio = "audio production";
  };
in
{
  inherit packageGroups;

  packageGroupNames = builtins.attrNames packageGroups;

  # Home toggle file: { rust = true; creator = false; } → mine.packages.*.enable
  packageGroupsFromToggles = toggles: lib.mapAttrs (_: on: { enable = on; }) toggles;

  # Gated package group: mine.packages.enable && mine.packages.<group>.enable
  packageGroupOn = pkgCfg: group: pkgCfg.enable && pkgCfg.${group}.enable;
}
