{ config, pkgs, username, ... }:

{
  ############################################################
  # Display server & greeter
  ############################################################

  programs.hyprland.enable = true;

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
          --cmd "Hyprland &>/dev/null" \
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
