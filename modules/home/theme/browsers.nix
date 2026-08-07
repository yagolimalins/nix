# Chromium — dark UI; toolbar follows GTK Storm (package group: browsers).
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;
in
{
  config = lib.mkIf (cfg.enable && on "browsers") {
    xdg.configFile."chromium/Initial Preferences".text = builtins.toJSON {
      distribution = {
        import_search_engine = false;
        make_chrome_default_for_user = false;
        skip_first_run_ui = true;
      };
      browser.theme = {
        color_scheme = 2;
        user_color2 = 0;
      };
    };
  };
}
