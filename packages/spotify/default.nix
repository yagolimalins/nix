# Official Spotify client with the pinyin/jyutping lyrics extension
# (https://github.com/0x-ultra/spotify-pinyin-lyrics).
#
# Spicetify patches xpui.spa. The store path is read-only after the build,
# so the patch has to happen here rather than via `spicetify apply` at runtime.
{
  lib,
  pkgs,
  buildNpmPackage,
  fetchFromGitHub,
  spicetify-cli,
}:

let
  lyricPinyin = buildNpmPackage {
    pname = "spotify-pinyin-lyrics";
    version = "1.0.0-unstable-2026-09-24";

    src = fetchFromGitHub {
      owner = "0x-ultra";
      repo = "spotify-pinyin-lyrics";
      rev = "e2e168db45355e794febeea8f2c4d9b5007b03ba";
      hash = "sha256-pdgLX2IOwA2hm3b/svsZb1mTlne6Mau936tBn0nSU14=";
    };

    npmDepsHash = "sha256-5qlWgZSN8r2R+9+fVZtq3+RRmk4K+iL8aF9I1g2IMIE=";

    installPhase = ''
      runHook preInstall
      install -Dm644 dist/lyric-pinyin.js $out/lyric-pinyin.js
      runHook postInstall
    '';
  };

  # Stock look: the extension only. Spicetify still wants a theme directory.
  theme = pkgs.writeTextDir "color.ini" "[Base]\n";

  xpuiConfig = pkgs.writeText "config-xpui.ini" (
    lib.generators.toINI { } {
      AdditionalOptions = {
        extensions = "lyric-pinyin.js";
        custom_apps = "";
        sidebar_config = false;
        home_config = false;
        experimental_features = false;
      };
      Setting = {
        spotify_path = "__SPOTIFY__";
        prefs_path = "__PREFS__";
        inject_theme_js = false;
        replace_colors = false;
        check_spicetify_update = false;
        current_theme = "Default";
        color_scheme = "";
        inject_css = false;
        overwrite_assets = false;
        spotify_launch_flags = "";
        always_enable_devtools = false;
      };
      Preprocesses = {
        disable_ui_logging = true;
        remove_rtl_rule = true;
        expose_apis = true;
        disable_sentry = true;
      };
      Backup = {
        version = pkgs.spotify.version;
        "with" = "Dev";
      };
    }
  );
in
pkgs.spotify.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    export SPICETIFY_CONFIG="$PWD/spicetify"
    export SPICETIFY_STATE="$SPICETIFY_CONFIG/state"
    mkdir -p "$SPICETIFY_STATE" "$SPICETIFY_CONFIG"/{Extensions,CustomApps,Themes/Default}

    cp ${lyricPinyin}/lyric-pinyin.js "$SPICETIFY_CONFIG/Extensions/lyric-pinyin.js"
    cp ${theme}/color.ini "$SPICETIFY_CONFIG/Themes/Default/color.ini"
    touch "$SPICETIFY_CONFIG/prefs"

    sed \
      -e "s|__SPOTIFY__|$out/share/spotify|g" \
      -e "s|__PREFS__|$SPICETIFY_CONFIG/prefs|g" \
      ${xpuiConfig} > "$SPICETIFY_CONFIG/config-xpui.ini"

    ${lib.getExe spicetify-cli} --no-restart backup apply
  '';
})
