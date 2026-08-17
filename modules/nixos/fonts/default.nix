#
# fonts.nix — System fonts
#
# Noto for UI/sans-serif, Fira Code Nerd Font Mono for monospace/terminal,
# Noto CJK + emoji as fallbacks.
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
    lib.mkEnableOption "system fonts (Noto, Fira Code Nerd Font, CJK)";

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.fira-code
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
