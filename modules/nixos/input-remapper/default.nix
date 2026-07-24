#
# input-remapper.nix — Key/button remapping
#
# input-remapper needs root to read raw /dev/input events and udev rules
# to handle hotplugged devices, so it's a system service. The service has
# no idea which user/config to load until something calls
# `input-remapper-control --command autoload` inside the graphical
# session — Hyprland doesn't run XDG autostart .desktop files, so that
# call is wired directly into its exec-once instead (see hyprland.nix).
#
# The upstream package's polkit policy hardcodes /usr/bin/input-remapper-control
# as the authorized exec path, which doesn't exist on NixOS — pkexec then
# refuses to authorize the real (Nix store) binary with "Not authorized",
# even with a correct password. Patch every copy of the policy file to
# point at the actual store path instead.
# https://github.com/NixOS/nixpkgs/issues/236441
#
# The package also ships input-remapper-autoload.desktop in share/applications
# (it belongs in xdg/autostart instead), which just clutters the app launcher
# with an entry that stops/reloads all mappings if clicked by accident — we
# already trigger the same autoload command ourselves from exec-once, so drop it.
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.input-remapper;

  input-remapper = pkgs.input-remapper.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      for f in $(find "$out" -iname "*.policy"); do
        substituteInPlace "$f" \
          --replace-fail "/usr/bin/input-remapper-control" \
          "$out/bin/input-remapper-control"
      done
      find "$out" -iname "input-remapper-autoload.desktop" -delete
    '';
  });
in
{
  options.${namespace}.input-remapper.enable =
    lib.mkEnableOption "input-remapper key/button remapping service";

  config = lib.mkIf cfg.enable {
    services.input-remapper = {
      enable = true;
      enableUdevRules = true;
      package = input-remapper;
    };
  };
}
