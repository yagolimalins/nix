#
# locale.nix — Time zone, locale and console keymap
#
# English UI with Brazilian regional formats (dates, currency, paper size)
# and the ABNT2 console keyboard layout.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.locale;
in
{
  options.${namespace}.locale.enable =
    lib.mkEnableOption "timezone, locale and console keymap (en_US UI, pt_BR regional)";

  config = lib.mkIf cfg.enable {
    time.timeZone = "America/Maceio";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };

    console.keyMap = "br-abnt2";
  };
}
