# Shared helpers merged into `lib.${namespace}` by Snowfall Lib.
{ lib, ... }:

let
  modules = import ./modules.nix { inherit lib; };
  packages = import ./packages.nix { inherit lib; };
  theme = import ./theme.nix { inherit lib; };
  host = import ./host.nix { inherit lib; };
in
modules // packages // theme // host
