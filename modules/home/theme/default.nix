#
# theme — Tokyo Night Storm (orchestrator)
#
# Submodules: gtk (desktop shell), editors, vscode-profiles, monitoring, viewers, browsers.
# Shared palette and helpers live in lib/default.nix.
#
{
  lib,
  namespace,
  ...
}:

{
  imports = [
    ./gtk.nix
    ./editors.nix
    ./vscode-profiles.nix
    ./monitoring.nix
    ./viewers.nix
    ./browsers.nix
  ];

  options.${namespace}.theme.enable =
    lib.mkEnableOption "Tokyo Night Storm (GTK/Qt + native app themes)";
}
