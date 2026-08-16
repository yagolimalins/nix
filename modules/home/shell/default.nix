#
# shell — Zsh + Starship (direnv hooks come from programs.direnv)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.shell;
  palette = lib.${namespace}.palette;
in
{
  options.${namespace}.shell.enable = lib.mkEnableOption "Zsh + Starship prompt";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "rust"
          "npm"
        ];
      };

      initContent = ''
        # Tokyo Night Storm — zsh-syntax-highlighting + autosuggestions
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[default]="fg=${palette.text}"
        ZSH_HIGHLIGHT_STYLES[command]="fg=${palette.accent},bold"
        ZSH_HIGHLIGHT_STYLES[alias]="fg=${palette.cyan}"
        ZSH_HIGHLIGHT_STYLES[builtin]="fg=${palette.accent}"
        ZSH_HIGHLIGHT_STYLES[function]="fg=${palette.accent}"
        ZSH_HIGHLIGHT_STYLES[path]="fg=${palette.text},underline"
        ZSH_HIGHLIGHT_STYLES[globbing]="fg=${palette.warning},bold"
        ZSH_HIGHLIGHT_STYLES[comment]="fg=${palette.muted}"
        ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${palette.urgent}"
        ZSH_HIGHLIGHT_STYLES[redirection]="fg=${palette.cyan}"
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${palette.muted}"
      '';
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;

        directory = {
          style = "bold ${palette.accent}";
        };
        git_branch = {
          style = "bold ${palette.text}";
        };
        git_status = {
          style = "bold ${palette.accent}";
        };
        cmd_duration = {
          style = palette.muted;
        };
        username = {
          style_user = "bold ${palette.text}";
          style_root = "bold ${palette.urgent}";
        };
        hostname = {
          style = "bold ${palette.muted}";
        };
        nix_shell = {
          style = "bold ${palette.ok}";
        };

        character = {
          success_symbol = "[❯](bold ${palette.accent})";
          error_symbol = "[❯](bold ${palette.urgent})";
        };
      };
    };
  };
}
