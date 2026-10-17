# Flip groups on/off here, then `nh os switch`.
{ lib, ... }:

let
  toggles = {
    # system + desktop
    nix = true;
    monitoring = true;
    wayland = true;
    clipboard = true;
    viewers = true;
    fonts = true;

    # dev
    editors = true;
    ides = true;
    cli = true;
    c = true;
    python = true;
    ai = true;
    vcs = true;
    js = true;
    jvm = true;
    rust = true;
    dioxus = true;
    tauri = true;
    gtk = true;
    dotnet = true;

    # apps
    databases = true;
    api = true;
    office = false;
    notes = false;
    learning = false;
    browsers = true;
    proton = true;
    mail = true;
    communication = true;

    # media
    media = true;
    creator = true;
    audio = true;
  };
in
{
  mine.packages = lib.recursiveUpdate {
    enable = true;
  } (lib.mine.packageGroupsFromToggles toggles);
}
