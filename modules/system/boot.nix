{ config, pkgs, username, ... }:

{
  ############################################################
  # Nix store & flake settings
  ############################################################

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/home/${username}/.nix";
    dates = "daily";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
  };

  ############################################################
  # Bootloader & kernel
  ############################################################

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_rt_6_1;
    kernelParams = [ "quiet" "splash" "loglevel=3" ];

    plymouth = {
      enable = true;
      theme = "bgrt";
    };

    initrd.systemd.enable = true;

    tmp.cleanOnBoot = true;
  };

  ############################################################
  # Journald limits
  ############################################################

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';

  ############################################################
  # NixOS release compatibility
  ############################################################

  system.stateVersion = "25.05";
}
