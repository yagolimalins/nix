{ config, pkgs, ... }:

{
  # Enable experimental Nix features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.kernelPackages = pkgs.linuxPackages_rt_6_1;

  # PAM limits for audio group
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix.settings.auto-optimise-store = true;

  # Clean /tmp on boot
  boot.tmp.cleanOnBoot = true;

  # Clear journal logs periodically
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';

  # Automatic system updates
  system.autoUpgrade = {
    enable = true;
    flake = "/home/yago/.nix";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "daily";
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone and locales
  time.timeZone = "America/Maceio";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # X11 and GNOME
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "br";
  services.xserver.xkb.variant = "";

  # Console keymap
  console.keyMap = "br-abnt2";

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire = {
      "10-audio-settings" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 128;
          "default.clock.quantum-limit" = 1024;
        };
      };
    };
  };

  # Power management
  powerManagement.cpuFreqGovernor = "performance";

  # Users
  users.users.yago = {
    isNormalUser = true;
    description = "Yago";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "realtime"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  # Applications
  programs.firefox.enable = true;

  # PostgreSQL
  virtualisation.oci-containers = {
    backend = "docker";

    containers.postgres = {
      image = "postgres:18";
      environment = {
        POSTGRES_USER = "postgres";
        POSTGRES_PASSWORD = "postgres";
        POSTGRES_DB = "postgres";
      };
      ports = [
        "5432:5432"
      ];
      volumes = [
        "/var/lib/postgres-docker:/var/lib/postgresql"
      ];

    };
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [ ];

  # System version
  system.stateVersion = "25.05";
}
