#
# librewolf — Home Manager profile (follows GTK Tokyo Night Storm)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.librewolf;

  themeSettings = {
    "ui.systemUsesDarkTheme" = 1;
    "browser.theme.content.theme" = 0;
    "browser.theme.toolbar-theme" = 0;
    "layout.css.prefers-color-scheme.content-override" = 2;
  };

  privacySettings = {
    # Modern fingerprinting stack with color-scheme exempt (see Mozilla bug 1732114).
    "privacy.resistFingerprinting" = false;
    "privacy.fingerprintingProtection" = true;
    "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";

    # LibreWolf defaults sanitize on quit and block session cookies — breaks logins.
    "privacy.sanitize.sanitizeOnShutdown" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "privacy.clearOnShutdown_v2.formdata" = false;
    "browser.sessionstore.privacy_level" = 0;
  };

  # Vertical tabs + collapsed strip that expands on hover (LibreWolf 153+).
  tabSettings = {
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "expand-on-hover";
    "sidebar.expandOnHover" = true;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.toolbars.bookmarks.visibility" = "newtab";
  };

  newTabSettings = {
    "browser.newtabpage.activity-stream.showSearch" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
  };

  sessionSettings = {
    "browser.startup.page" = 3; # restore previous session
    "browser.formfill.enable" = true; # LibreWolf default is false
  };

  waylandSettings = {
    "widget.content.glass" = false;
  };
in
{
  options.${namespace}.librewolf = {
    enable = lib.mkEnableOption "LibreWolf user profile and dark-mode settings via Home Manager";

    profilePath = lib.mkOption {
      type = lib.types.str;
      default = "default";
      example = "default";
      description = ''
        Profile directory name under
        {file}`$XDG_CONFIG_HOME/librewolf/`.
        Must match the `Path` entry in {file}`profiles.ini`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        path = cfg.profilePath;
        isDefault = true;

        settings =
          themeSettings
          // privacySettings
          // tabSettings
          // newTabSettings
          // sessionSettings
          // waylandSettings;
      };
    };
  };
}
