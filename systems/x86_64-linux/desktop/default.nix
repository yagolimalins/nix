#
# systems/x86_64-linux/desktop — AMD desktop (amdgpu)
#
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "desktop";
}
