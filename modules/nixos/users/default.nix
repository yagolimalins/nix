#
# users.nix — User account and session environment
#
# Layers our shared preferences (shell, groups) onto every user Snowfall
# Lib already knows about — one entry per directory under homes/ (see
# `config.snowfallorg.users`) — instead of hardcoding a specific
# username. Per-user packages are managed by Home Manager, so each
# account's own package list stays empty.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.users;
in
{
  options.${namespace}.users = {
    enable = lib.mkEnableOption "primary user account(s) and shared session environment";

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "realtime"
        "docker"
        "libvirtd"
      ];
      description = "Extra groups granted to every user declared under homes/.";
    };

    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zsh;
      description = "Login shell for every user declared under homes/.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.realtime = { };

    users.users = lib.genAttrs (lib.attrNames config.snowfallorg.users) (_name: {
      shell = cfg.shell;
      extraGroups = cfg.extraGroups;
      packages = [ ];
    });

    environment.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_10}";
      PATH = [ "$HOME/.dotnet/tools" ];
    };
  };
}
