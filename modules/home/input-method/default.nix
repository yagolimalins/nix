#
# input-method — Fcitx5 profile: Rime (雾凇) default, Mozc + Pinyin backup
#
# Packages live in the NixOS module; this only owns the user profile so
# ignoreUserConfig stays off and Rime can keep learning from typing.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.input-method;
in
{
  options.${namespace}.input-method.enable =
    lib.mkEnableOption "fcitx5 user profile (Rime default)";

  config = lib.mkIf cfg.enable {
    xdg.configFile."fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        Name=Default
        Default Layout=br
        DefaultIM=rime

        [Groups/0/Items/0]
        Name=keyboard-br
        Layout=

        [Groups/0/Items/1]
        Name=rime
        Layout=

        [Groups/0/Items/2]
        Name=mozc
        Layout=

        [Groups/0/Items/3]
        Name=pinyin
        Layout=

        [GroupOrder]
        0=Default
      '';
    };
  };
}
