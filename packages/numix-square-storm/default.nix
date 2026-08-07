# Numix Square with Tokyo Night Storm folder tints (accent + cyan).
# Keep folderAccent/folderBody/folderEmblem in sync with lib.mine.palette.
{
  lib,
  pkgs,
  numix-icon-theme-square,
  folderAccent ? "7aa2f7",
  folderBody ? "7dcfff",
  folderEmblem ? "565f89",
}:

pkgs.runCommand "numix-square-storm"
  {
    nativeBuildInputs = with pkgs; [
      findutils
      gnused
    ];
  }
  ''
    mkdir -p $out/share/icons
    cp -rL --no-preserve=mode ${numix-icon-theme-square}/share/icons/* $out/share/icons/
    chmod -R u+w $out/share/icons

    find $out/share/icons/Numix -path '*/places/*.svg' -type f \
      -exec sed -i \
        -e 's/#ea9036/#${folderAccent}/gI' \
        -e 's/#f2bb64/#${folderBody}/gI' \
        -e 's/#897757/#${folderEmblem}/gI' \
        -e 's/#1976d2/#${folderAccent}/gI' \
        -e 's/#42a5f5/#${folderBody}/gI' \
        {} +

    # Thunar sidebar uses "go-home"; Numix only ships user-home in places/.
    find $out/share/icons/Numix -path '*/places/user-home.svg' | while read -r home; do
      cp -L "$home" "$(dirname "$home")/go-home.svg"
    done

    find $out/share/icons -name icon-theme.cache -delete
    find $out/share/icons -name .icon-theme.cache -delete
  ''
