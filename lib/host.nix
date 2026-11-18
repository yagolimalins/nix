# Host layout facts for Umbriel outputs.
{ lib, ... }:

let
  # Shared dual-monitor layout: ultrawide above, laptop below.
  # workspace_axis = horizontal → workspace switch slides left/right.
  mkDualOutputs =
    externalName:
    {
      ${externalName} = {
        mode = "2560x1080@60";
        position = [
          0
          0
        ];
        scale = 1.0;
        # Fixed inventory so empty workspaces keep their numbers (dynamic prunes/renumbers).
        workspaces = 5;
        workspace_axis = "horizontal";
        focus_at_startup = true;
        layout.mode = "dwindle";
      };
      "eDP-1" = {
        mode = "1920x1080@60";
        position = [
          320
          1080
        ];
        scale = 1.0;
        # Built-in panel: connector name is stable (identity is "LG Display 0x0521 Unknown").
        workspaces = 5;
        workspace_axis = "horizontal";
        layout.mode = "dwindle";
      };
    };
in
{
  # Parameterized HM/NixOS module: set mine.host from an HDMI connector name.
  dualMonitorHostModule =
    hdmiPort:
    {
      namespace,
      ...
    }:
    {
      ${namespace}.host = {
        outputs = mkDualOutputs hdmiPort;
      };
    };

  # Match the external panel by EDID / monitor identity so connector names
  # (HDMI-A-2 vs DP-3 on a USB-C dock) do not break layout.
  dualMonitorHostModuleDesc =
    monitorDesc:
    {
      namespace,
      ...
    }:
    {
      ${namespace}.host = {
        outputs = mkDualOutputs monitorDesc;
        # USB-C docks enumerate late; pick HDMI monitor audio after settle.
        sessionAutostart = [ "bash -c 'sleep 6; switch-usb-audio'" ];
      };
    };
}
