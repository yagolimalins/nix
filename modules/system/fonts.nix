#
# fonts.nix — System fonts
#
# Noto (incl. CJK + colour emoji) for general text, JetBrains Mono Nerd
# Font for monospace. Defaults wire CJK fallbacks after the primaries.
#
{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK JP" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK KR" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK KR" ];
    };
  };
}
