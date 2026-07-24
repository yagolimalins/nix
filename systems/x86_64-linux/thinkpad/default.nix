#
# systems/x86_64-linux/thinkpad — ThinkPad T480 (i915, TLP thresholds)
#
{ lib, namespace, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./thinkpad.nix
  ];

  # Explicit `config = { ... }` (instead of the usual implicit shorthand)
  # so `${namespace}` can stay dynamic: Nix must know a module's top-level
  # attribute *names* before `config` exists, and with implicit syntax
  # that includes user-defined keys like `${namespace}` — forcing it would
  # need `_module.args.namespace`, which needs `config`. Wrapping in an
  # explicit, statically-named `config` attribute sidesteps that; the
  # dynamic key only has to be known once we're already resolving config.
  config = {
    networking.hostName = "thinkpad";

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
