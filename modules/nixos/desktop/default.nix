#
# desktop — Session integration (not the WM; see display + hyprland)
#
# Power stats, GVFS/Thunar system bits, GNOME keyring (tuigreet unlock),
# dconf, archives.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.enable =
    lib.mkEnableOption "desktop integration (upower, Thunar, keyring, dconf)";

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.udisks2.enable = true; # automount removable drives
    services.gvfs.enable = true; # trash, MTP, network mounts for Thunar

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.tuigreet.enableGnomeKeyring = true;

    programs.dconf.enable = true; # GTK apps persist settings here

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    };

    environment.systemPackages = with pkgs; [
      engrampa
      zip
      unzip
      pipewire.jack
    ];
  };
}
