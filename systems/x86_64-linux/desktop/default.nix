#
# systems/x86_64-linux/desktop — AMD desktop (amdgpu)
#
{ lib, namespace, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # See systems/x86_64-linux/thinkpad for why this uses explicit `config`.
  config = {
    networking.hostName = "desktop";

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
      "nh"
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
