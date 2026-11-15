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
        brightnessctl
        pwvucontrol
        seahorse
        tumbler
      ];
    })

    (lib.mkIf (on "clipboard") {
      home.packages = with pkgs; [
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
