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
    };

    nix.daemonCPUSchedPolicy = "idle";

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    # Keep in lockstep with the nixpkgs channel in flake.nix.
    system.stateVersion = "26.05";
  };
}
