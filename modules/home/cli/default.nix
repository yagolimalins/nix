#
# cli — shell essentials, file tools, HTTP client (gated by mine.packages.cli).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  pkgCfg = config.${namespace}.packages;
  on = pkgCfg.enable && pkgCfg.cli.enable;
in
{
  config = lib.mkIf on {
    # Packages without HM program modules — the rest come from programs.* below.
    home.packages = with pkgs; [
      ripgrep
      fd
      miniserve
      just
      yazi
      xh
      duf
      dust
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--reverse"
        "--bind=ctrl-/:toggle-preview"
      ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    programs.jq.enable = true;

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };

    programs.tealdeer.enable = true;
  };
}
