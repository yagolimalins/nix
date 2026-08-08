# Neovim + Helix — Tokyo Night Storm colorschemes (package groups: editors).
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;
in
{
  config = lib.mkIf (cfg.enable && on "editors") {
    programs.neovim.plugins = with pkgs.vimPlugins; [
      {
        plugin = tokyonight-nvim;
        type = "lua";
        config = ''
          require("tokyonight").setup({ style = "storm" })
          vim.cmd.colorscheme("tokyonight-storm")
        '';
      }
    ];
  };
}
