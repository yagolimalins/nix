{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable        = true;
    powerOnBoot   = true;
    settings.Policy.AutoEnable = true;
  };

  services.blueman.enable = true;
}
