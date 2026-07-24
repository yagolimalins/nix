#
# lib/default.nix — Shared flake library
#
# Merged into `lib.${namespace}` by Snowfall Lib and available to every
# system, home and module.
#
{ lib, ... }:

{
  # Turn a list of Snowfall module names into `{ <name>.enable = true; }`
  # for each, merged into one attrset. Lets systems/ and homes/ toggle a
  # whole batch of modules in one line instead of repeating
  # `<name>.enable = true;` by hand.
  #
  # Usage: ${namespace} = lib.${namespace}.enable-modules [ "audio" "boot" ];
  enable-modules =
    names:
    lib.genAttrs names (_name: {
      enable = true;
    });
}
