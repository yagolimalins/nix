#
# input-method.nix — fcitx5 (Chinese + Japanese)
#
# Wayland frontend: Rime + 雾凇拼音 (rime-ice) for Chinese prediction,
# chinese-addons Pinyin as backup, Mozc for Japanese.
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

  # nixpkgs renames rime-ice's default.yaml → rime_ice_suggestion.yaml so it
  # does not clash with other schemas; this patch turns that suggestion on.
  rimeIceDefault = pkgs.writeTextDir "share/rime-data/default.custom.yaml" ''
    patch:
      __include: rime_ice_suggestion:/
  '';
in
{
  options.${namespace}.input-method.enable =
    lib.mkEnableOption "fcitx5 input method (Chinese Rime + Japanese Mozc)";

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        # Stock Pinyin kept as a fallback engine in the Fcitx group.
        qt6Packages.fcitx5-chinese-addons
        (fcitx5-rime.override {
          # rime-ice alone — do not mix with rime-data (file overlap).
          rimeDataPkgs = [
            rime-ice
            rimeIceDefault
          ];
        })
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };
  };
}
