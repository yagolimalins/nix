# Nix daemon: flakes, store optimise, GC, stateVersion.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.nix;
in
{
  options.${namespace}.nix.enable =
    lib.mkEnableOption "Nix daemon settings (flakes, GC, store optimisation)";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      max-jobs = "auto";
      keep-outputs = true;
      extra-substituters = [
        "https://noctalia.cachix.org"
        "https://umbriel.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      ];
    };

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    # Keep in lockstep with the nixpkgs channel in flake.nix.
    system.stateVersion = "26.05";
  };
}
