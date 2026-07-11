#
# shell.nix — Bash configuration
#
# Minimal red [user@host:cwd]$ prompt.
#
{ ... }:

{
  programs.bash = {
    enable    = true;
    initExtra = ''
      PS1='\[\e[1;31m\][\u@\h:\w]\$\[\e[0m\] '
    '';
  };
}
