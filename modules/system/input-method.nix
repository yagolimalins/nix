#
# input-method.nix — fcitx5 (Chinese + Japanese)
#
# Wayland frontend with Pinyin/Chinese addons and Mozc for Japanese.
#
{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable                 = true;
    type                   = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-mozc
      fcitx5-gtk
      libsForQt5.fcitx5-qt
    ];
  };
}
