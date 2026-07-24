#
# systems/x86_64-linux/laptop — AMD laptop (amdgpu)
#
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
  ];

  networking.hostName = "laptop";
}
