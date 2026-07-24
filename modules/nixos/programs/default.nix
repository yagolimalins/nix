#
# programs.nix — System-wide programs
#
# Things that need a NixOS module (not just a package): Firefox, the JDK,
# nix-ld so unpatched dynamic binaries (e.g. .NET tooling) can run, and
# Zsh (must be registered in /etc/shells for it to be a valid login shell).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.programs;
in
{
  options.${namespace}.programs.enable =
    lib.mkEnableOption "Firefox, JDK, nix-ld and Zsh registration";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true; # registers zsh in /etc/shells
    programs.firefox.enable = true;

    programs.java = {
      enable = true;
      package = pkgs.jdk25;
    };

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      dotnet-sdk_10
      stdenv.cc.cc
      openssl
      zlib
      curl
      icu
    ];
  };
}
