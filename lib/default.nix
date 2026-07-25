# Shared helpers merged into `lib.${namespace}` by Snowfall Lib.
{ lib, ... }:

{
  # `[ "audio" "boot" ]` → `{ audio.enable = true; boot.enable = true; }`
  enable-modules =
    names:
    lib.genAttrs names (_: {
      enable = true;
    });

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
