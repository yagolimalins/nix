{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./thinkpad.nix
  ];

  networking.hostName = "thinkpad";

  ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-2";
}
