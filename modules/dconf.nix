{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      next = ["<Super>period"];
      play = ["<Super>semicolon"];
      previous = ["<Super>comma"];
      volume-down = ["<Super>bracketright"];
      volume-up = ["<Super>bracketleft"];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "gnome-terminal";
      binding = "<Super>Return";
    };
  };
}
