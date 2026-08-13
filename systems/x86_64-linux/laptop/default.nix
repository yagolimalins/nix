{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
    (lib.${namespace}.dualMonitorHostModule "HDMI-A-1")
  ];

  networking.hostName = "laptop";
}
