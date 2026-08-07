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
        # Print a blank line before each prompt except after opening the
        # terminal or running `clear`.
        _first_prompt=1
        _last_cmd=""

        preexec_track() { _last_cmd="$1"; }
        precmd_newline() {
          if (( _first_prompt )); then
            _first_prompt=0
          elif [[ "$_last_cmd" != "clear" ]]; then
            print ""
          fi
        }

        preexec_functions+=( preexec_track )
        precmd_functions+=( precmd_newline )
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
