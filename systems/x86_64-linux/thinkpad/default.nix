#
# systems/x86_64-linux/thinkpad — ThinkPad T480 (i915, TLP thresholds)
#
{ namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./thinkpad.nix
  ];

  networking.hostName = "thinkpad";

  ${namespace}.host = {
    monitors = [
      "HDMI-A-2, 2560x1080@60, 0x0, 1"
      "eDP-1, 1920x1080@60, 320x1080, 1"
    ];
    workspaces = [
      "1, monitor:HDMI-A-2, default:true"
      "2, monitor:HDMI-A-2"
      "3, monitor:HDMI-A-2"
      "4, monitor:HDMI-A-2"
      "5, monitor:HDMI-A-2"
      "6, monitor:HDMI-A-2"
      "7, monitor:HDMI-A-2"
      "8, monitor:HDMI-A-2"
      "9, monitor:HDMI-A-2"
      "10, monitor:eDP-1, default:true"
    ];
  };
}
