{ config, pkgs, username, hostName, ... }:

{
  imports = [
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/security.nix
    ./modules/system/users.nix
  ];
}
