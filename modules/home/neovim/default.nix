#
# neovim — ABNT2 navigation (JKLÇ), mirrors mine.helix
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.neovim;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;
in
{
  options.${namespace}.neovim.enable =
    lib.mkEnableOption "Neovim (ABNT2 keymap; Tokyo Night Storm via mine.theme)";

  config = lib.mkIf (cfg.enable && on "editors") {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = false;
      initLua = lib.fileContents ./abnt2.lua;
    };
  };
}
