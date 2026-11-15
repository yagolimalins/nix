{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
    # Must match `umbriel outputs` Config name (includes serial) or position is ignored.
    (lib.${namespace}.dualMonitorHostModuleDesc "LG Electronics LG HDR WFHD 0x0001372E")
  ];

  networking.hostName = "thinkpad";
}
