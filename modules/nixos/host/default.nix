#
# host.nix — Per-machine facts
#
# Declarative host metadata consumed by other modules (especially Home
# Manager via osConfig). Hosts under systems/ set these; UI modules must
# not switch on hostname strings.
#
# Always imported — options only, no enable toggle.
#
{
  lib,
  namespace,
  ...
}:

{
  options.${namespace}.host = {
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ", preferred, auto, 1" ];
      description = ''
        Hyprland `monitor=` lines for this machine. Example:
        `"HDMI-A-2, 2560x1080@60, 0x0, 1"`.
      '';
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Hyprland `workspace=` lines for this machine (monitor binding,
        defaults, etc.). Empty means Hyprland's built-in defaults.
      '';
    };
  };
}
