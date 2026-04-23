{ config, pkgs, username, ... }:

{
  ############################################################
  # Display server & greeter
  ############################################################

  programs.hyprland.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --remember-session \
          --greeting "  ThinkPad" \
          --asterisks \
          --cmd "start-hyprland &>/dev/null" \
          --theme "border=#cc2222;text=#dedede;prompt=#7a7a7a;time=#dedede;action=#7a7a7a;button=#171717;container=#171717;input=#dedede"
      '';
      user = "greeter";
    };
  };

  console.keyMap = "br-abnt2";

  ############################################################
  # Power management
  ############################################################

  powerManagement.cpuFreqGovernor = "powersave";
  services.upower.enable = true;
  environment.systemPackages = with pkgs; [ engrampa zip unzip ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.tuigreet.enableGnomeKeyring = true;

  virtualisation.docker.enable = false;

  services.ollama.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  ############################################################
  # User account
  ############################################################

  users.users.${username} = {
    isNormalUser = true;
    description  = username;
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "realtime" "docker" ];
    packages     = with pkgs; [ ];
  };

  ############################################################
  # System-level programs
  ############################################################

  programs.firefox.enable = true;

  programs.java = {
    enable  = true;
    package = pkgs.jdk25;
  };

  ############################################################
  # Session environment
  ############################################################

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}";
    PATH        = [ "$HOME/.dotnet/tools" ];
  };

  ############################################################
  # nix-ld — run unpatched binaries
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
}
