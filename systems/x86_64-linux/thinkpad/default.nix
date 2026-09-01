{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
    (lib.${namespace}.dualMonitorHostModuleDesc "LG Electronics LG HDR WFHD")
  ];

  networking.hostName = "thinkpad";
}
