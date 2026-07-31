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
  on = group: cfg.enable && cfg.${group}.enable;
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
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
    })
  ];
}
