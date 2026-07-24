#
# systems/x86_64-linux/thinkpad — ThinkPad T480 (i915, TLP thresholds)
#
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./thinkpad.nix
  ];

  networking.hostName = "thinkpad";
}
