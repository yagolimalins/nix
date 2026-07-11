#
# desktop.nix — Desktop integration
#
# The bits that make a bare compositor feel like a desktop: power stats,
# removable-media mounting, the Thunar file manager, the GNOME keyring
# (unlocked at login by tuigreet), dconf for GTK settings, and a couple
# of archive utilities.
#
{ config, pkgs, ... }:

{
  services.upower.enable  = true;
  services.udisks2.enable = true; # automount removable drives
  services.gvfs.enable    = true; # trash, MTP, network mounts for Thunar

  services.gnome.gnome-keyring.enable               = true;
  security.pam.services.tuigreet.enableGnomeKeyring = true;

  programs.dconf.enable = true; # GTK apps persist settings here

  programs.thunar = {
    enable  = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = with pkgs; [ engrampa zip unzip pipewire.jack ];
}
