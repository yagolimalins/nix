# VS Code multi-profile theme + extension enablement (activation script).
#
# Profiles isolate extension enablement; settings alone cannot load Tokyo Night Storm.
# Close VS Code before `nixos-rebuild` — the script mutates profiles/*/settings.json
# and profiles/*/extensions.json while HM activates.
{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.theme;
  pkgCfg = config.${namespace}.packages;
  on = lib.${namespace}.packageGroupOn pkgCfg;

  tokyoNightExt = pkgs.vscode-extensions.enkia.tokyo-night;
  vscodeSettings = lib.${namespace}.vscodeTokyoNightSettings;

  # Default profile is HM-managed; this script only touches User/profiles/*.
  applyProfileThemesScript = pkgs.writeShellScript "vscode-apply-profile-themes" ''
    set -euo pipefail
    theme='${builtins.toJSON vscodeSettings}'
    tokyoExt='${
      builtins.toJSON (
        lib.${namespace}.mkVscodeTokyoNightExtEntry {
          homeDirectory = config.home.homeDirectory;
          extVersion = tokyoNightExt.version;
        }
      )
    }'
    profilesDir="${config.xdg.configHome}/Code/User/profiles"
    globalExt="${config.home.homeDirectory}/.vscode/extensions/extensions.json"

    apply_theme() {
      local file="$1"
      mkdir -p "$(dirname "$file")"
      if [ -f "$file" ]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$file" <(printf '%s' "$theme") > "$file.new"
        mv "$file.new" "$file"
      else
        printf '%s\n' "$theme" > "$file"
      fi
    }

    enable_theme_ext() {
      local file="$1"
      mkdir -p "$(dirname "$file")"
      if [ -f "$file" ]; then
        ${pkgs.jq}/bin/jq --argjson ext "$tokyoExt" '
          if any(.[]?; .identifier.id == "enkia.tokyo-night") then .
          else . + [$ext]
          end
        ' "$file" > "$file.new"
        mv "$file.new" "$file"
      else
        ${pkgs.jq}/bin/jq -n --argjson ext "$tokyoExt" '[$ext]' > "$file"
      fi
    }

    if [ -f "$globalExt" ]; then
      ${pkgs.jq}/bin/jq '
        map(
          if .identifier.id == "enkia.tokyo-night" then
            .metadata = ((.metadata // {}) + {"isApplicationScoped": true})
          else .
          end
        )
      ' "$globalExt" > "$globalExt.new"
      mv "$globalExt.new" "$globalExt"
    fi

    if [ -d "$profilesDir" ]; then
      for profileDir in "$profilesDir"/*/; do
        [ -d "$profileDir" ] || continue
        apply_theme "''${profileDir}settings.json"
        enable_theme_ext "''${profileDir}extensions.json"
      done
    fi
  '';
in
{
  config = lib.mkIf (cfg.enable && on "ides") {
    programs.vscode = {
      enable = true;
      profiles.default = {
        userSettings = vscodeSettings;
        extensions = [ tokyoNightExt ];
      };
    };

    home.activation.vscodeProfileThemes =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
        ''
          run ${applyProfileThemesScript}
        '';

    xdg.configFile."Cursor/User/settings.json".text = builtins.toJSON vscodeSettings;

    home.file.".cursor/extensions/enkia.tokyo-night".source =
      "${tokyoNightExt}/share/vscode/extensions/enkia.tokyo-night";
  };
}
