#
# bluetooth.nix — Bluetooth stack
#
# BlueZ powered on at boot with experimental features and the Blueman
# applet for tray management. Codec/autoswitch tuning lives in audio.nix.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.bluetooth;
in
{
  options.${namespace}.bluetooth.enable = lib.mkEnableOption "Bluetooth (BlueZ + Blueman)";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        Policy.AutoEnable = true;
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };

    services.blueman.enable = true;
  };
}
