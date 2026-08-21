#
# fonts.nix — System fonts
#
# Inter for Waybar/Fuzzel, Noto for GTK/CJK/emoji, Fira Code + JetBrains
# Mono Nerd Fonts for terminal/IDEs, Symbols Nerd Font for bar icons.
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
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
      ];
      fontconfig.defaultFonts = {
        sansSerif = [
          "Noto Sans"
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
