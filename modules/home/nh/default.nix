#
# nh.nix — per-user NH_FLAKE for the logged-in account
#
# Points nh at `$HOME/.nix/` so each Snowfall user uses their own checkout.
# Trailing slash is required: nh rejects any flake path ending in ".nix".
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.nh;
  flake = "${config.home.homeDirectory}/.nix/";
in
{
  options.${namespace}.nh.enable =
    lib.mkEnableOption "NH_FLAKE from the logged-in user's home directory";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.NH_FLAKE = flake;

    programs.zsh.envExtra = ''
      export NH_FLAKE=${lib.escapeShellArg flake}
    '';
  };
}
