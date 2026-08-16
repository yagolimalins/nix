#
# cli — shell essentials, file tools, HTTP client (gated by mine.packages.cli).
#
# No mine.cli option: the whole tree is gated by the cli package group.
# Submodules: tools (fzf, bat, eza, …), broot, zellij, yazi.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages "cli";
in
{
  imports = [
    ./tools.nix
    ./broot.nix
    ./zellij.nix
    ./yazi.nix
  ];

  config = lib.mkIf on {
    # Standalone binaries — the rest come from programs.* in the submodules.
    home.packages = with pkgs; [
      ripgrep
      fd
      miniserve
      just
      xh
      duf
      dust
    ];
  };
}
