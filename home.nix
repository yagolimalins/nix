{ config, pkgs, username, ... }:

{
  home.username      = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion  = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.file."Desktop/.keep".text           = "";
  home.file."Development/.keep".text      = "";
  home.file."Documents/.keep".text        = "";
  home.file."Downloads/.keep".text        = "";
  home.file."Music/.keep".text            = "";
  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Public/.keep".text           = "";
  home.file."Templates/.keep".text        = "";
  home.file."Videos/.keep".text           = "";

  xdg.configFile."cava/config".text = ''
    [general]
    bars = 10
    framerate = 30
    sleep_timer = 5

    [input]
    method = pipewire

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 7
    bar_delimiter = 0
    channels = mono
  '';

  home.file.".local/bin/cava-waybar" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      cava -p "$HOME/.config/cava/config" | while IFS= read -r line; do
        out=""
        for (( i=0; i<''${#line}; i++ )); do
          case "''${line:$i:1}" in
            0) out+=" "  ;;
            1) out+="▁"  ;;
            2) out+="▂"  ;;
            3) out+="▃"  ;;
            4) out+="▄"  ;;
            5) out+="▅"  ;;
            6) out+="▆"  ;;
            7) out+="▇"  ;;
            8) out+="█"  ;;
          esac
        done
        echo "$out"
      done
    '';
  };

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  imports = [
    ./modules/home/packages.nix
    ./modules/home/theme.nix
    ./modules/home/hyprland.nix
    ./modules/home/waybar.nix
    ./modules/home/terminals.nix
    ./modules/home/launchers.nix
    ./modules/home/services.nix
  ];
}
