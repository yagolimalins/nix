# Shared Home Manager toggles (wired via homes.modules).
# Literal `mine` required — `${namespace}` hits an HM freeformType cycle here.
{ lib, pkgs, ... }:

{
  home.stateVersion = "26.05";

  mine =
    (lib.mine.enable-modules [
      "xdg"
      "hyprland"
      "waybar"
      "fuzzel"
      "kitty"
      "shell"
      "notifications"
      "lockscreen"
      "nightshift"
      "thunar"
      "theme"
      "helix"
      "neovim"
      "firefox"
      "packages"
      "input-remapper"
    ])
    // {
      user.wallpaper =
        "${pkgs.nixos-artwork.wallpapers.binary-blue}/share/backgrounds/nixos/nix-wallpaper-binary-blue.png";
    };
}
