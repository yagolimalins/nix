#
# input-method.nix — fcitx5 (Chinese + Japanese)
#
# Wayland frontend with Pinyin/Chinese addons and Mozc for Japanese.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.input-method;
in
{
  options.${namespace}.input-method.enable =
    lib.mkEnableOption "fcitx5 input method (Chinese + Japanese)";

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };
  };
}
