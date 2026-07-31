#
# input-remapper.nix — Key/button remapping
#
# input-remapper needs root to read raw /dev/input events and udev rules
# to handle hotplugged devices, so it's a system service. Presets live in
# each user's ~/.config/input-remapper-2 (HM) and are applied by
# `input-remapper-control --command autoload`:
#
#   - login: Hyprland exec-once
#   - hotplug: upstream udev rules
#   - nixos-rebuild: ExecStartPost below (runuser — not root/--config-dir)
#
# The upstream package's polkit policy hardcodes /usr/bin/input-remapper-control
# as the authorized exec path, which doesn't exist on NixOS — pkexec then
# refuses to authorize the real (Nix store) binary with "Not authorized",
# even with a correct password. Patch every copy of the policy file to
# point at the actual store path instead.
# https://github.com/NixOS/nixpkgs/issues/236441
#
# The package also ships input-remapper-autoload.desktop in share/applications
# (it belongs in xdg/autostart instead), which clutters the launcher — drop it.
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

  # Re-apply presets for every logged-in user after the daemon (re)starts.
  # Must run *as that user*: root + --config-dir still fails with
  # "autoload all before a user told the service about their session using
  # set_config_dir" — the daemon only accepts set_config_dir from the session owner.
  autoloadUsers = pkgs.writeShellScript "input-remapper-autoload-users" ''
    set +e
    control=${lib.getExe' input-remapper "input-remapper-control"}
    runuser=${lib.getExe' pkgs.util-linux "runuser"}
    sleep 0.5
    for rundir in /run/user/*; do
      [ -d "$rundir" ] || continue
      uid="''${rundir##*/}"
      case "$uid" in
        *[!0-9]*) continue ;;
      esac
      user="$(${pkgs.coreutils}/bin/id -nu "$uid" 2>/dev/null)" || continue
      home="$(${pkgs.gawk}/bin/awk -F: -v u="$user" '$1 == u { print $6; exit }' /etc/passwd)"
      [ -n "$home" ] || continue
      [ -r "$home/.config/input-remapper-2/config.json" ] || continue
      "$runuser" -u "$user" -- "$control" --command autoload || true
    done
  '';
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

    systemd.services.input-remapper.serviceConfig.ExecStartPost = [ "+${autoloadUsers}" ];
  };
}
