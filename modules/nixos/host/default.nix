# Per-machine facts for HM (via osConfig). Always imported — options only.
{ lib, namespace, ... }:

{
  options.${namespace}.host = {
    outputs = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = ''
        Umbriel `[output.<name>]` tables for this machine. Empty lets Umbriel
        auto-enable preferred outputs. Keys are connector names (e.g. HDMI-A-1)
        or monitor identity strings from `umbriel outputs`.
      '';
      example = {
        "HDMI-A-1" = {
          mode = "2560x1080@60";
          position = [
            0
            0
          ];
          scale = 1.0;
          workspaces = 9;
        };
      };
    };

    sessionAutostart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Extra Umbriel `general.autostart` commands for this host
        (e.g. delayed USB audio switch after a dock enumerates).
      '';
    };
  };
}
