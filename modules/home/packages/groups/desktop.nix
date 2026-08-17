# Package group: wayland, clipboard, viewers, fonts (gated by mine.packages.enable).
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  on = lib.${namespace}.packageGroupOn cfg;
in
{
  config = lib.mkMerge [
    (lib.mkIf (on "wayland") {
      home.packages = with pkgs; [
        playerctl
        brightnessctl
        networkmanagerapplet
        blueman
        pwvucontrol
        seahorse
        tumbler
      ];

      xdg.dataFile."icons/hicolor/scalable/apps/blueman-device.svg".source =
        "${pkgs.blueman}/share/icons/hicolor/scalable/devices/blueman-device.svg";
    })

    (lib.mkIf (on "clipboard") {
      home.packages = with pkgs; [
        grimblast
        wl-clipboard
      ];
    })

    (lib.mkIf (on "viewers") {
      home.packages = with pkgs; [
        ristretto
        zathura
      ];
    })

    (lib.mkIf (on "fonts") {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
      ];
    })
  ];
}
