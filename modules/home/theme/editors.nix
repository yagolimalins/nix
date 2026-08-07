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
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = false;
      plugins = with pkgs.vimPlugins; [
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

    programs.helix = {
      enable = true;
      defaultEditor = false;
      settings.theme = "tokyonight_storm";
    };
  };
}
