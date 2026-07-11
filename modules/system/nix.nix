#
# nix.nix — Nix daemon behaviour
#
# Flake/CLI features, store optimisation, garbage collection and the
# NixOS release-compatibility marker. Nothing here is host-specific.
#
{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;   # hard-link identical store paths
    max-jobs              = "auto"; # build derivations across all cores
    keep-outputs          = true;   # don't GC build deps of dev shells
  };

  # Build at idle priority so compiles never steal the foreground.
  nix.daemonCPUSchedPolicy = "idle";

  nix.gc = {
    automatic = true;
    dates     = "daily";
    options   = "--delete-older-than 3d";
  };

  # State version for stateful data compatibility — do not change casually.
  system.stateVersion = "25.05";
}
