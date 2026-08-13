# User package orchestrator (mine.packages.*). Groups default to on when
# `enable` is set; override toggles in homes/x86_64-linux/<user>/package-groups.nix.
#
# Group names and descriptions: lib.mine.packageGroups (lib/packages.nix).
# Custom flake derivations (dioxus-cli, numix-square-storm, …): top-level packages/.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  mkGroup = lib.mkEnableOption;
  packageGroups = lib.${namespace}.packageGroups;
  groupNames = lib.${namespace}.packageGroupNames;
in
{
  imports = [
    ./groups/system.nix
    ./groups/desktop.nix
    ./groups/dev.nix
    ./groups/apps.nix
    ./groups/media.nix
  ];

  options.${namespace}.packages = {
    enable = mkGroup "user package orchestrator (direnv + default groups)";
  }
  // lib.mapAttrs (_: description: {
    enable = mkGroup description;
  }) packageGroups;

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      ${namespace}.packages = lib.genAttrs groupNames (_: {
        enable = lib.mkDefault true;
      });

      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
      };
    })
  ];
}
