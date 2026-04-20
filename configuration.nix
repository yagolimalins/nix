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

  ############################################################
  # Input method — Chinese (fcitx5 + Pinyin)
  ############################################################

  i18n.inputMethod = {
    enable = true;
    type   = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-mozc
      fcitx5-gtk
      libsForQt5.fcitx5-qt
    ];
  };

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
