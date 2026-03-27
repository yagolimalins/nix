{
  config,
  pkgs,
  username,
  ...
}:

{
  ############################################################
  # Nix configuration
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
  # Bootloader, kernel & Plymouth
  ############################################################

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_rt_6_1;

    initrd = {
      systemd.enable = true;
    };

    tmp.cleanOnBoot = true;
  };

  ############################################################
  # Logging
  ############################################################

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';

  ############################################################
  # Networking
  ############################################################

  networking = {
    hostName = "nixos";
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
  };

  ############################################################
  # Display, desktop & input
  ############################################################

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --remember-session \
            --greeting "  ThinkPad" \
            --asterisks \
            --cmd "Hyprland &>/dev/null" \
            --theme "border=#cc2222;text=#dedede;prompt=#7a7a7a;time=#dedede;action=#7a7a7a;button=#171717;container=#171717;input=#dedede"
        '';
        user = "greeter";
      };
    };
  };

  console.keyMap = "br-abnt2";

  ############################################################
  # Printing
  ############################################################

  services.printing.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = true;
  };

  services.blueman.enable = true;

  ############################################################
  # Audio (PipeWire + realtime)
  ############################################################

  security.rtkit.enable = true;

  environment.etc."cpugov-toggle" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
      case $GOV in
        performance) NEXT=powersave ;;
        *)           NEXT=performance ;;
      esac
      for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$NEXT" > "$f"
      done
    '';
  };

  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "/etc/cpugov-toggle";
      options = [ "NOPASSWD" ];
    }];
  }];

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

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;

    wireplumber.extraConfig."10-bluetooth-autoswitch" = {
      "monitor.bluez.rules" = [
        {
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions.update-props = {
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          };
        }
      ];
    };

    extraConfig.pipewire."10-audio-settings" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.allowed-rates = [
          44100
          48000
          96000
        ];
        default.clock.quantum = 128;
        default.clock.min-quantum = 128;
        default.clock.max-quantum = 128;
        default.clock.quantum-limit = 1024;
      };
    };
  };

  ############################################################
  # Power management
  ############################################################

  powerManagement.cpuFreqGovernor = "performance";

  services.upower.enable = true;

  ############################################################
  # Users
  ############################################################

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "realtime"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  ############################################################
  # Applications
  ############################################################

  programs.firefox.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  ############################################################
  # Containers (PostgreSQL)
  ############################################################

  # virtualisation.oci-containers = {
  #   backend = "docker";

  #   containers.postgres = {
  #     image = "postgres:18";
  #     environment = {
  #       POSTGRES_USER = "postgres";
  #       POSTGRES_PASSWORD = "postgres";
  #       POSTGRES_DB = "postgres";
  #     };
  #     ports = [ "5432:5432" ];
  #     volumes = [
  #       "/var/lib/postgres-docker:/var/lib/postgresql"
  #     ];
  #   };
  # };

  ############################################################
  # System packages
  ############################################################


  ############################################################
  # Session variables
  ############################################################

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}";
    PATH = [ "$HOME/.dotnet/tools" ];
  };

  ############################################################
  # Nix-LD
  ############################################################

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    dotnet-sdk_10
    stdenv.cc.cc
    openssl
    zlib
    curl
    icu
  ];

  ############################################################
  # NixOS release compatibility
  ############################################################

  system.stateVersion = "25.05";
}
