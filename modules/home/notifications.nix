#
# notifications.nix — Mako notification daemon
#
# Dark theme matching the system red/charcoal palette.
#
{ ... }:

{
  services.mako = {
    enable   = true;
    settings = {
      font               = "JetBrainsMono Nerd Font 14";
      "background-color"  = "#0d0d0d";
      "border-color"      = "#cc2222";
      "text-color"        = "#dedede";
      "border-size"       = 1;
      "border-radius"     = 3;
      "default-timeout"   = 5000;
      padding             = "10,14";
      width               = 320;
      icons               = true;
      "on-button-left"    = "invoke";
      "on-button-right"   = "dismiss";

      "urgency=critical" = {
        "default-timeout" = 0;
        "border-color"    = "#ffaa00";
      };
    };
  };
}
