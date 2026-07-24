#
# systems/x86_64-linux/laptop — AMD laptop (amdgpu)
#
{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
  ];

  # See systems/x86_64-linux/thinkpad for why this uses explicit `config`.
  config = {
    networking.hostName = "laptop";

    ${namespace} = lib.${namespace}.enable-modules [
      "audio"
      "bluetooth"
      "boot"
      "desktop"
      "display"
      "dns"
      "fonts"
      "input-method"
      "input-remapper"
      "locale"
      "logging"
      "networking"
      "nix"
      "postgresql"
      "power"
      "printing"
      "programs"
      "tailscale"
      "users"
      "virtualisation"
    ];
  };
}
