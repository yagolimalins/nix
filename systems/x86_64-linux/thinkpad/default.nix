{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
    (lib.${namespace}.dualMonitorHostModule "HDMI-A-2")
  ];

  networking.hostName = "thinkpad";
}
