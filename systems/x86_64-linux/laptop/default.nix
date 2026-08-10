{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
  ];

  networking.hostName = "laptop";

  ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-1";
}
