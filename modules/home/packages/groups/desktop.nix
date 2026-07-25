{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.wayland.enable {
      home.packages = with pkgs; [
        playerctl
        brightnessctl
        networkmanagerapplet
        blueman
        seahorse
        tumbler
      ];
    })

    (lib.mkIf cfg.clipboard.enable {
      home.packages = with pkgs; [
        grimblast
        wl-clipboard
      ];
    })

    (lib.mkIf cfg.viewers.enable {
      home.packages = with pkgs; [
        ristretto
        zathura
      ];
    })

    (lib.mkIf cfg.fonts.enable {
      home.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
    })
  ];
}
