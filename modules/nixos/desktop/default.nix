#
# desktop — Session integration (not the WM; see display + hyprland)
#
# Power stats, GVFS/Thunar system bits, GNOME keyring (tuigreet unlock),
# dconf, archives, GParted.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.desktop;
  themeName = lib.${namespace}.gtkStormThemeName;
  iconName = lib.${namespace}.numixSquareThemeName;
  cursor = lib.${namespace}.cursorTheme;
  gtkTheme = pkgs.tokyonight-gtk-theme.override { tweakVariants = [ "storm" ]; };
  iconTheme = pkgs.${namespace}.numix-square-storm;

  # pkexec clears the user GTK env — GParted would fall back to Adwaita light.
  gpartedThemed =
    let
      launch = pkgs.writeShellScriptBin "gparted" ''
        set -euo pipefail
        export GTK_THEME=${lib.escapeShellArg themeName}
        export GTK_ICON_THEME=${lib.escapeShellArg iconName}
        export XCURSOR_THEME=${lib.escapeShellArg cursor.name}
        export XCURSOR_SIZE=${toString cursor.size}
        export XDG_DATA_DIRS="${gtkTheme}/share:${iconTheme}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
        if [ "$(id -u)" -ne 0 ]; then
          ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:root >/dev/null 2>&1 || true
          self=$(${pkgs.coreutils}/bin/readlink -f "$0")
          exec ${lib.getExe' pkgs.polkit "pkexec"} env \
            DISPLAY="''${DISPLAY:-}" \
            WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-}" \
            XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-}" \
            XAUTHORITY="''${XAUTHORITY:-}" \
            GTK_THEME="$GTK_THEME" \
            GTK_ICON_THEME="$GTK_ICON_THEME" \
            XCURSOR_THEME="$XCURSOR_THEME" \
            XCURSOR_SIZE="$XCURSOR_SIZE" \
            XDG_DATA_DIRS="$XDG_DATA_DIRS" \
            "$self" "$@"
        fi
        exec ${lib.getExe pkgs.gparted} "$@"
      '';
    in
    pkgs.runCommand "gparted-themed" { } ''
        mkdir -p $out/bin $out/share/applications $out/share/icons
        cp ${lib.getExe launch} $out/bin/gparted
        chmod +x $out/bin/gparted
        substitute ${pkgs.gparted}/share/applications/gparted.desktop \
          $out/share/applications/gparted.desktop \
          --replace-fail '${lib.getExe pkgs.gparted}' $out/bin/gparted
        cp -r ${pkgs.gparted}/share/icons/hicolor $out/share/icons/
      '';
in
{
  options.${namespace}.desktop.enable =
    lib.mkEnableOption "desktop integration (upower, Thunar, keyring, dconf)";

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.udisks2.enable = true; # automount removable drives
    services.gvfs.enable = true; # trash, MTP, network mounts for Thunar

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.tuigreet.enableGnomeKeyring = true;

    programs.dconf.enable = true; # GTK apps persist settings here
    programs.xfconf.enable = true; # Thunar sidebar prefs (hidden-bookmarks)

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    };

    environment.systemPackages = with pkgs; [
      engrampa
      gpartedThemed
      zip
      unzip
      unrar
      pipewire.jack
    ];
  };
}
