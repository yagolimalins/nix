#
# firefox — Home Manager profile (follows GTK Tokyo Night Storm)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.firefox;
in
{
  options.${namespace}.firefox = {
    enable = lib.mkEnableOption "Firefox user profile and dark-mode settings via Home Manager";

    profilePath = lib.mkOption {
      type = lib.types.str;
      default = "default";
      example = "default";
      description = ''
        Profile directory name under
        {file}`$XDG_CONFIG_HOME/mozilla/firefox/`.
        Must match the `Path` entry in {file}`profiles.ini`.
        Set per-user in {file}`homes/x86_64-linux/<user>/default.nix` when
        adopting an existing profile (see `Path=` in the current
        {file}`profiles.ini`).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        path = cfg.profilePath;
        isDefault = true;

        settings = {
          "ui.systemUsesDarkTheme" = true;
          "browser.theme.content.theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "layout.css.prefers-color-scheme.content-override" = 0;
        };
      };
    };
  };
}
