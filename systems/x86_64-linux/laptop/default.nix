{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
  ];

  networking.hostName = "laptop";

  ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-1";
}
