{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
  ];

  networking.hostName = "thinkpad";

  ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-2";
}
