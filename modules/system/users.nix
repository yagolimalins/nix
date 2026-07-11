#
# users.nix — User account and session environment
#
# The primary user (name resolved by the flake) plus the shell env for
# .NET tooling. Per-user packages are managed by Home Manager, so the
# account's own package list stays empty.
#
{ config, pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description  = username;
    shell        = pkgs.zsh;
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "realtime" "docker" ];
    packages     = [ ];
  };

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}";
    PATH        = [ "$HOME/.dotnet/tools" ];
  };
}
