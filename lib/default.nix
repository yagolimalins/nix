# Shared helpers merged into `lib.${namespace}` by Snowfall Lib.
{ lib, ... }:

let
  parts = [
    (import ./modules.nix { inherit lib; })
    (import ./packages.nix { inherit lib; })
    (import ./apps.nix { inherit lib; })
    (import ./theme.nix { inherit lib; })
    (import ./host.nix { inherit lib; })
  ];
in
# Plain `//` would let a redefined helper silently shadow an earlier one.
lib.foldl' (
  acc: part:
  let
    collisions = lib.intersectLists (lib.attrNames acc) (lib.attrNames part);
  in
  if collisions == [ ] then
    acc // part
  else
    throw "lib.mine helper name collision: ${lib.concatStringsSep ", " collisions}"
) { } parts
