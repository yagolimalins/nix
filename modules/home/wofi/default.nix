#
# wofi — Application launcher (drun + Waybar power menu dmenu)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.wofi;
  palette = lib.${namespace}.palette;
in
{
  options.${namespace}.wofi.enable = lib.mkEnableOption "Wofi application launcher";

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
        width = 380;
        height = 300;
        hide_scroll = true;
        allow_images = true;
        image_size = 24;
        hide_actions = true;
      };
      style = ''
        window {
          background-color: ${palette.bg};
          border: 1px solid ${palette.accent};
          border-radius: 4px;
        }

        #input {
          all: unset;
          border: none;
          border-bottom: 1px solid ${palette.accent};
          border-radius: 3px 3px 0 0;
          padding: 10px 14px;
          color: ${palette.text};
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
          color: ${palette.text};
        }

        #entry:selected {
          background-color: #1a1a1a;
          outline: none;
        }

        #text {
          font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
          font-size: 16px;
          color: ${palette.text};
        }

        #text:selected {
          color: ${palette.accent};
          font-weight: bold;
        }

        #img { margin-right: 10px; }
      '';
    };
  };
}
