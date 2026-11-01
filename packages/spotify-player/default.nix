# 26.05 is still on 0.23.0; take the binary from nixos-unstable.
{ inputs, pkgs }:

inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.spotify-player
