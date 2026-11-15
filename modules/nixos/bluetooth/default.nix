#
# bluetooth.nix — Bluetooth stack
#
# BlueZ powered on at boot with experimental features. Tray/UI via Noctalia
# bluetooth widget — no Blueman applet. Codec/autoswitch in audio.nix.
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
  options.${namespace}.bluetooth.enable = lib.mkEnableOption "Bluetooth (BlueZ)";

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
  };
}
