# Module enable helpers merged into lib.${namespace} by Snowfall Lib.
{ lib, ... }:

{
  # `[ "audio" "boot" ]` → `{ audio.enable = true; boot.enable = true; }`
  enable-modules =
    names:
    lib.genAttrs names (_: {
      enable = true;
    });
}
