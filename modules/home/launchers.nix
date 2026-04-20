{ config, pkgs, ... }:

{
  programs.wofi = {
    enable   = true;
    settings = {
      width        = 380;
      height       = 300;
      hide_scroll  = true;
      allow_images = true;
      image_size   = 24;
      hide_actions = true;
    };
    style = ''
      window {
        background-color: #0d0d0d;
        border: 1px solid #cc2222;
        border-radius: 4px;
      }

      #input {
        all: unset;
        border: none;
        border-bottom: 1px solid #cc2222;
        border-radius: 3px 3px 0 0;
        padding: 10px 14px;
        color: #dedede;
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 16px;
        font-weight: bold;
        outline: none;
        caret-color: transparent;
      }

      #outer-box { padding: 6px; }

      #scroll {
        border: none;
        margin-top: 2px;
      }

      #entry {
        padding: 7px 12px;
        border-radius: 2px;
        color: #dedede;
      }

      #entry:selected {
        background-color: #1a1a1a;
        outline: none;
      }

      #text {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 16px;
        color: #dedede;
      }

      #text:selected {
        color: #cc2222;
        font-weight: bold;
      }

      #img { margin-right: 10px; }
    '';
  };
}
