#
# programs.nix — System-wide programs
#
# Things that need a NixOS module (not just a package): Firefox, the JDK,
# and nix-ld so unpatched dynamic binaries (e.g. .NET tooling) can run.
#
{ pkgs, ... }:

{
  programs.firefox.enable = true;

  programs.java = {
    enable  = true;
    package = pkgs.jdk25;
  };

  programs.nix-ld.enable    = true;
  programs.nix-ld.libraries = with pkgs; [
    dotnet-sdk_10
    stdenv.cc.cc
    openssl
    zlib
    curl
    icu
  ];
}
