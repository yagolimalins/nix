#
# shell.nix — Zsh + Starship
#
# oh-my-zsh for plugins, zsh-autosuggestions and zsh-syntax-highlighting
# for inline completions/colouring, and Starship as the prompt.
# direnv hooks are injected automatically by the programs.direnv module.
#
# Colour palette — matches the system ThinkPad theme:
#   #cc2222  accent red       #dedede  primary text
#   #e63329  bright red       #aaaaaa  secondary text
#   #5a9e5a  green (positive) #7a7a7a  muted text
#
{ ... }:

{
  programs.zsh = {
    enable                    = true;
    enableCompletion          = true;
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" "docker" "rust" "npm" ];
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
    enable   = true;
    settings = {
      add_newline = false;

      directory    = { style = "bold #cc2222"; };
      git_branch   = { style = "bold #dedede"; };
      git_status   = { style = "bold #cc2222"; };
      cmd_duration = { style = "#7a7a7a"; };
      username     = { style_user = "bold #dedede"; style_root = "bold #e63329"; };
      hostname     = { style = "bold #aaaaaa"; };
      nix_shell    = { style = "bold #5a9e5a"; };

      # character has colors embedded in the symbol strings.
      character = {
        success_symbol = "[❯](bold #5a9e5a)";
        error_symbol   = "[❯](bold #e63329)";
      };
    };
  };
}
