# Package group: nix, monitoring (gated by mine.packages.enable).
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
    (lib.mkIf (on "nix") {
      home.packages = with pkgs; [
        nixfmt
        nixd
        nil
      ];
    })

    (lib.mkIf (on "monitoring") {
      home.packages = with pkgs; [
        btop
        bottom
        fastfetch
      ];
    })
  ];
}
