# Per-machine facts for HM (via osConfig). Always imported — options only.
{ lib, namespace, ... }:

{
  options.${namespace}.host = {
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ", preferred, auto, 1" ];
      description = "Hyprland `monitor=` lines for this machine.";
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Hyprland `workspace=` lines (empty = Hyprland defaults).";
    };

    hyprExecOnce = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Extra Hyprland `exec-once` lines for this host (e.g. delayed monitor relayout).
      '';
    };
  };
}
