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
    (lib.mkIf cfg.nix.enable {
      home.packages = with pkgs; [
        nixfmt
        nixd
        nil
      ];
    })

    (lib.mkIf cfg.monitoring.enable {
      home.packages = with pkgs; [
        btop
        fastfetch
      ];
    })
  ];
}
