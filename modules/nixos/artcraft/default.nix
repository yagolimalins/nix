# Flatpak daemon for the ArtCraft suite. The apps themselves are declared
# in the Home Manager module and installed for the user at activation.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.artcraft;
in
{
  options.${namespace}.artcraft.enable = lib.mkEnableOption "Flatpak daemon for ArtCraft";

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
