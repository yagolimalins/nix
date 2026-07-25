#
# systems/x86_64-linux/laptop — AMD laptop (amdgpu)
#
{ namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
  ];

  networking.hostName = "laptop";

  ${namespace}.host = {
    monitors = [
      "HDMI-A-1, 2560x1080@60, 0x0, 1"
      "eDP-1, 1920x1080@60, 320x1080, 1"
    ];
    workspaces = [
      "1, monitor:HDMI-A-1, default:true"
      "2, monitor:HDMI-A-1"
      "3, monitor:HDMI-A-1"
      "4, monitor:HDMI-A-1"
      "5, monitor:HDMI-A-1"
      "6, monitor:HDMI-A-1"
      "7, monitor:HDMI-A-1"
      "8, monitor:HDMI-A-1"
      "9, monitor:HDMI-A-1"
      "10, monitor:eDP-1, default:true"
    ];
  };
}
