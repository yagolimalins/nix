#
# input-remapper.nix — Declarative presets
#
# The GUI writes these under ~/.config/input-remapper-2/. Since Home Manager
# symlinks them from the Nix store, the GUI can no longer save edits to
# them directly — edit the JSON here and rebuild instead.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.input-remapper;
in
{
  options.${namespace}.input-remapper.enable =
    lib.mkEnableOption "declarative input-remapper presets";

  config = lib.mkIf cfg.enable {
    xdg.configFile."input-remapper-2/config.json" = {
      force = true;
      text = builtins.toJSON {
        version = "2.2.0";
        autoload = {
          "Compx 2.4G Wireless Receiver" = "Redragon Fizz Pro";
          "BT5.0 KB Keyboard" = "Redragon Fizz Pro";
        };
      };
    };

    xdg.configFile."input-remapper-2/presets/Compx 2.4G Wireless Receiver/Redragon Fizz Pro.json" = {
      force = true;
      text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 17;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Up";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 30;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Left";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 31;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Down";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 32;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Right";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 42;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Shift_L + apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 42;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Shift_L + apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 17;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Up";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 30;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Left";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 31;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Down";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 32;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Right";
          mapping_type = "key_macro";
        }
      ];
    };
    xdg.configFile."input-remapper-2/presets/BT5.0 KB Keyboard/Redragon Fizz Pro.json" = {
      force = true;
      text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 17;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Up";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 30;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Left";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 31;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Down";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 32;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Right";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 97;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 42;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Shift_L + apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 42;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Shift_L + apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 1;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "apostrophe";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 17;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Up";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 30;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Left";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 31;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Down";
          mapping_type = "key_macro";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 54;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
            {
              type = 1;
              code = 32;
              origin_hash = "16449b01c96d206924e4566166d681f8";
            }
          ];
          target_uinput = "keyboard";
          output_symbol = "Right";
          mapping_type = "key_macro";
        }
      ];
    };
  };
}
