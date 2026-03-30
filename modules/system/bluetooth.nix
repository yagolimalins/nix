{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
    settings = {
      Policy.AutoEnable = true;
      General = {
        Experimental    = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;
}
