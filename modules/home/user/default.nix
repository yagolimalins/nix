#
# user.nix — Per-user facts
#
# Declarative user metadata for Home Manager modules. Set overrides in
# homes/<user>/default.nix; shared defaults live here.
#
# Always imported — options only, no enable toggle.
#
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
      description = "Wallpaper image path used by the Hyprland session.";
    };
  };
}
