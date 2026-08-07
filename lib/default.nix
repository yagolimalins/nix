  # Shared helpers merged into `lib.${namespace}` by Snowfall Lib.
{ lib, ... }:

{
  # `[ "audio" "boot" ]` → `{ audio.enable = true; boot.enable = true; }`
  enable-modules =
    names:
    lib.genAttrs names (_: {
      enable = true;
    });

  # Keep in sync with modules/home/packages/default.nix options.
  packageGroupNames = [
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
    "dioxus"
    "tauri"
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

  # Home toggle file: { rust = true; creator = false; } → mine.packages.*.enable
  packageGroupsFromToggles = toggles: lib.mapAttrs (_: on: { enable = on; }) toggles;

  # Tokyo Night Storm — accent = selection/active; semantic colors for status only.
  palette = {
    bg = "#24283b";
    surface = "#1f2335";
    border = "#414868";
    text = "#c0caf5";
    muted = "#565f89";
    accent = "#7aa2f7";
    cyan = "#7dcfff";
    onAccent = "#1f2335";
    urgent = "#f7768e";
    warning = "#e0af68";
    ok = "#9ece6a";
    purple = "#bb9af7"; # terminal ANSI magenta only
  };

  # Ultrawide HDMI + internal eDP layout shared by thinkpad/laptop hosts.
  mkDualMonitorHost =
    hdmi:
    let
      external = builtins.genList (
        i:
        let
          n = i + 1;
        in
        if n == 1 then "1, monitor:${hdmi}, default:true" else "${toString n}, monitor:${hdmi}"
      ) 9;
    in
    {
      monitors = [
        "${hdmi}, 2560x1080@60, 0x0, 1"
        "eDP-1, 1920x1080@60, 320x1080, 1"
      ];
      workspaces = external ++ [ "10, monitor:eDP-1, default:true" ];
    };

  # Stock gtk.portal is UseIn=gnome only; Hyprland sessions need this sibling.
  mkGtkHyprlandPortal =
    pkgs:
    pkgs.writeTextDir "share/xdg-desktop-portal/portals/gtk-hyprland.portal" ''
      [portal]
      DBusName=org.freedesktop.impl.portal.desktop.gtk
      Interfaces=org.freedesktop.impl.portal.FileChooser;org.freedesktop.impl.portal.AppChooser;org.freedesktop.impl.portal.Print;org.freedesktop.impl.portal.Notification;org.freedesktop.impl.portal.Inhibit;org.freedesktop.impl.portal.Access;org.freedesktop.impl.portal.Account;org.freedesktop.impl.portal.Email;org.freedesktop.impl.portal.DynamicLauncher;org.freedesktop.impl.portal.Lockdown;org.freedesktop.impl.portal.Settings;org.freedesktop.impl.portal.Wallpaper;
      UseIn=Hyprland
    '';
}
