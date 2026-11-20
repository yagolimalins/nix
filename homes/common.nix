# Shared Home Manager toggles (wired via homes.modules).
# Literal `mine` required — `${namespace}` hits an HM freeformType cycle here.
{ lib, ... }:

{
  home.stateVersion = "26.05";

  mine = lib.mkMerge [
    (lib.mine.enable-modules [
      "xdg"
      "umbriel"
      "noctalia"
      "kitty"
      "shell"
      # nightshift (gammastep) replaced by Noctalia nightlight widget/service
      "nh"
      "thunar"
      "theme"
      "helix"
      "neovim"
      "librewolf"
      "packages"
      "input-remapper"
      "input-method"
    ])
    {
      usbAudio.enable = true;
    }
  ];
}
