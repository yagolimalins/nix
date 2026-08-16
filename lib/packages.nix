# Home Manager package group helpers (mine.packages.*).
# Custom flake derivations live in top-level packages/ — not here.
{ lib, ... }:

let
  # Single source of truth for mine.packages.<group>.enable options.
  packageGroups = {
    nix = "Nix tooling (nixfmt, nixd, nil)";
    monitoring = "system monitors (btop, bottom, fastfetch)";

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

  # Thunar UCA + Yazi folder openers — keep commands identical between both.
  folderOpenCommands =
    pkgs:
    let
      terminal = lib.getExe pkgs.kitty;
      zellij = lib.getExe pkgs.zellij;
      cursor = lib.getExe pkgs.code-cursor;
      vscode = lib.getExe pkgs.vscode;
      zed = lib.getExe pkgs.zed-editor;
    in
    {
      thunar = {
        terminal = "${terminal} --working-directory %f";
        zellijIde = "${terminal} --working-directory %f -- ${zellij} -l ide";
        cursor = "${cursor} %f";
        vscode = "${vscode} --new-window %f";
        zed = "${zed} -n %f";
      };
      yazi = {
        # --detach opens a new Kitty OS window without blocking the caller.
        terminal = "${terminal} --detach --working-directory %s";
        zellijIde = "${terminal} --detach --working-directory %s -- ${zellij} -l ide";
        cursor = "${cursor} %s";
        vscode = "${vscode} --new-window %s";
        zed = "${zed} -n %s";
      };
    };
}
