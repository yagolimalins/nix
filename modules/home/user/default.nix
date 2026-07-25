# Per-user facts for HM modules. Always imported — options only.
{
  lib,
  pkgs,
  namespace,
  ...
}:

{
  options.${namespace}.user = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
      description = "Wallpaper path used by Hyprland and hyprlock.";
    };
  };
}
