{ config, pkgs, hostName, ... }:

{
  ############################################################
  # Network
  ############################################################

  networking = {
    hostName = hostName;
    networkmanager = {
      enable  = true;
      dns     = "systemd-resolved";
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  ############################################################
  # AdGuard Home — system-wide DNS ad blocker
  ############################################################

  services.adguardhome = {
    enable          = true;
    mutableSettings = true;
    host            = "127.0.0.1";
    port            = 9000;
    settings = {
      dns = {
        bind_host     = "127.0.0.1";
        port          = 5335;
        bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
        upstream_dns  = [ "https://dns.cloudflare.com/dns-query" "https://dns10.quad9.net/dns-query" ];
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve.DNS    = "127.0.0.1:5335";
    settings.Resolve.DNSSEC = "false";
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
