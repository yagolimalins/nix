{ config, pkgs, lib, ... }:

{
  home.activation.papirus-folders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.gawk}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:$PATH"
    MARKER="$HOME/.local/share/icons/.papirus-version"
    CURRENT="${pkgs.papirus-icon-theme}"
    if [ ! -f "$MARKER" ] || [ "$(cat $MARKER)" != "$CURRENT" ]; then
      ICONS_DIR="$HOME/.local/share/icons"
      mkdir -p "$ICONS_DIR"
      for THEME in Papirus Papirus-Dark Papirus-Light; do
        cp -rf ${pkgs.papirus-icon-theme}/share/icons/$THEME "$ICONS_DIR/$THEME"
        chmod -R u+w "$ICONS_DIR/$THEME"
      done
      ${pkgs.papirus-folders}/bin/papirus-folders -C red --theme Papirus-Dark
      echo "$CURRENT" > "$MARKER"
    fi
  '';

  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
