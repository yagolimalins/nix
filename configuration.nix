{ config, pkgs, username, hostName, ... }:

{
  imports = [
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/security.nix
    ./modules/system/users.nix
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK JP" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK KR" ];
      monospace  = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK KR" ];
    };
  };
}
