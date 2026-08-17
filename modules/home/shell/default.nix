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

      autosuggestion = {
        enable = true;
        highlight = "fg=${palette.muted}";
      };

      syntaxHighlighting = {
        enable = true;
        styles = {
          default = "fg=${palette.text}";
          command = "fg=${palette.accent},bold";
          alias = "fg=${palette.cyan}";
          builtin = "fg=${palette.accent}";
          function = "fg=${palette.accent}";
          path = "fg=${palette.text},underline";
          globbing = "fg=${palette.warning},bold";
          comment = "fg=${palette.muted}";
          unknown-token = "fg=${palette.urgent}";
          redirection = "fg=${palette.cyan}";
        };
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "rust"
          "npm"
        ];
      };

      # Blank line before the prompt except the first draw in this shell, or right after clear.
      initContent = ''
        typeset -g _mine_first_prompt=1
        _mine_prompt_newline() {
          if (( _mine_first_prompt )); then
            _mine_first_prompt=0
          else
            print
          fi
        }
        add-zsh-hook precmd _mine_prompt_newline
        clear() {
          _mine_first_prompt=1
          command clear "$@"
        }
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
