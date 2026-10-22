#
# adb.nix — Android Debug Bridge
#
# Puts adb/fastboot on PATH. USB access is handled by systemd 258
# uaccess rules — programs.adb and the adbusers group were removed
# from nixpkgs (PR 454366).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.adb;
in
{
  options.${namespace}.adb.enable = lib.mkEnableOption "Android Debug Bridge (adb/fastboot)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.android-tools ];
  };
}
