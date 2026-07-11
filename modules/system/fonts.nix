#
# fonts.nix — System fonts
#
# Noto for UI/sans-serif, Fira Code Nerd Font Mono for monospace/terminal,
# Noto CJK + emoji as fallbacks.
#
{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK JP" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK KR" ];
      monospace = [ "FiraCode Nerd Font Mono" "Noto Sans Mono CJK JP" "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK KR" ];
    };
  };
}
