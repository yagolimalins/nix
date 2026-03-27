{ config, pkgs, hostName, ... }:

{
  ############################################################
  # Network
  ############################################################

  networking = {
    hostName = hostName;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  ############################################################
  # Time & locale
  ############################################################

  time.timeZone = "America/Maceio";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS        = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT    = "pt_BR.UTF-8";
      LC_MONETARY       = "pt_BR.UTF-8";
      LC_NAME           = "pt_BR.UTF-8";
      LC_NUMERIC        = "pt_BR.UTF-8";
      LC_PAPER          = "pt_BR.UTF-8";
      LC_TELEPHONE      = "pt_BR.UTF-8";
      LC_TIME           = "pt_BR.UTF-8";
    };
  };

  ############################################################
  # Printing
  ############################################################

  services.printing.enable = true;
}
