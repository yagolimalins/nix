# Host layout facts and NixOS portal helpers.
{ lib, ... }:

{
  # Parameterized HM/NixOS module: set mine.host from an HDMI output name.
  # Ultrawide HDMI + internal eDP layout shared by thinkpad/laptop hosts.
  dualMonitorHostModule =
    hdmiPort:
    {
      namespace,
      ...
    }:
    {
      ${namespace}.host = {
        monitors = [
          "${hdmiPort}, 2560x1080@60, 0x0, 1"
          "eDP-1, 1920x1080@60, 320x1080, 1"
        ];
        # Workspaces 1-9 live on the ultrawide, 10 on the internal panel.
        workspaces =
          map (
            n: if n == 1 then "1, monitor:${hdmiPort}, default:true" else "${toString n}, monitor:${hdmiPort}"
          ) (lib.range 1 9)
          ++ [ "10, monitor:eDP-1, default:true" ];
      };
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
