#
# fonts.nix — System fonts
#
# Inter for UI (GTK/Qt/LibreWolf/Waybar/Fuzzel), Noto CJK/emoji as fallback,
# Fira Code + JetBrains Mono Nerd Fonts for terminal/IDEs, Symbols Nerd Font
# for bar icons.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.fonts;

  # Spotifast walks four levels below each fontconfig directory, and NixOS
  # points those at the package root. Noto CJK keeps its files one level
  # deeper (share/fonts/opentype/noto-cjk), so the walk never reaches them
  # and Han text is drawn with Unifont. This link sits where the walk looks.
  notoCjkShallow = pkgs.runCommand "noto-cjk-sans-shallow" { } ''
    mkdir -p $out/share/fonts/opentype
    ln -s ${pkgs.noto-fonts-cjk-sans-static}/share/fonts/opentype/noto-cjk/NotoSansCJK-Regular.ttc \
      $out/share/fonts/opentype/NotoSansCJK-Regular.ttc
  '';
in
{
  options.${namespace}.fonts.enable =
    lib.mkEnableOption "system fonts (Inter, Noto, Nerd Fonts, CJK)";

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        inter
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        notoCjkShallow
      ];
      fontconfig.defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans CJK JP"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK KR"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK KR"
        ];
      };
    };
  };
}
