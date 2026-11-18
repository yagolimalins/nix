# ArtCraft suite (17 Crafting Apps + launcher) from the upstream OCI remote.
# nix-flatpak installs these at Home Manager activation, which `nh os switch`
# runs. The launcher does not install the other apps during that activation,
# so each app id is listed here. ArtCraft Studio (ai.artcraft.app) is a
# separate program and is not part of this suite.
#
# Declaring remotes replaces nix-flatpak's default Flathub remote, so Flathub
# is listed again: the apps need org.freedesktop.Platform//26.08 from there.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.artcraft;

  # Stable x86_64 names from https://getartcraft.com/index/static.
  appIds = [
    "ai.storyteller.artcraft-launcher"
    "ai.storyteller.photocraft"
    "ai.storyteller.vectorcraft"
    "ai.storyteller.filmcraft"
    "ai.storyteller.lightcraft"
    "ai.storyteller.pdfcraft"
    "ai.storyteller.effectcraft"
    "ai.storyteller.anicraft"
    "ai.storyteller.designcraft"
    "ai.storyteller.figcraft"
    "ai.storyteller.texturecraft"
    "ai.storyteller.materialcraft"
    "ai.storyteller.soundcraft"
    "ai.storyteller.wordcraft"
    "ai.storyteller.deckcraft"
    "ai.storyteller.cadcraft"
    "ai.storyteller.gridcraft"
    "ai.storyteller.craft-anything"
  ];
in
{
  options.${namespace}.artcraft.enable = lib.mkEnableOption "ArtCraft suite (Flatpak)";

  # nix-flatpak defaults this to the NixOS daemon flag. Force it off unless
  # this user opted in, so other accounts do not gain the Flathub remote.
  config = lib.mkMerge [
    {
      services.flatpak.enable = cfg.enable;
    }
    (lib.mkIf cfg.enable {
      services.flatpak = {
        remotes = [
          {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          }
          {
            name = "artcraft-oci";
            location = "https://getartcraft.com/artcraft-oci.flatpakrepo";
          }
        ];
        packages = map (appId: {
          inherit appId;
          origin = "artcraft-oci";
        }) appIds;
      };
    })
  ];
}
