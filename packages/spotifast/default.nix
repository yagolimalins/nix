# 26.05 is still on an older spotifast; take the package from nixos-unstable.
{ inputs, pkgs }:

inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.spotifast
