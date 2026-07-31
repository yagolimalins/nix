# HM-managed presets are store symlinks — edit here and rebuild (GUI can't save).
# Login: Hyprland exec-once. Rebuild: NixOS input-remapper ExecStartPost.
# Avoid a user oneshot here — HM waits on it during switch while the system
# daemon is still restarting, which added ~1min of failed retries per activate.
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.input-remapper;
  origin = "16449b01c96d206924e4566166d681f8";

  mkMap = codes: symbol: {
    input_combination = builtins.map (code: {
      type = 1;
      inherit code;
      origin_hash = origin;
    }) codes;
    target_uinput = "keyboard";
    output_symbol = symbol;
    mapping_type = "key_macro";
  };

  redragonPreset = [
    (mkMap [ 97 17 ] "Up")
    (mkMap [ 97 30 ] "Left")
    (mkMap [ 97 31 ] "Down")
    (mkMap [ 97 32 ] "Right")
    (mkMap [ 97 1 ] "apostrophe")
    (mkMap [ 97 42 1 ] "Shift_L + apostrophe")
    (mkMap [ 54 42 1 ] "Shift_L + apostrophe")
    (mkMap [ 54 1 ] "apostrophe")
    (mkMap [ 54 17 ] "Up")
    (mkMap [ 54 30 ] "Left")
    (mkMap [ 54 31 ] "Down")
    (mkMap [ 54 32 ] "Right")
  ];

  presetFile = {
    force = true;
    text = builtins.toJSON redragonPreset;
  };
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

    xdg.configFile."input-remapper-2/presets/Compx 2.4G Wireless Receiver/Redragon Fizz Pro.json" =
      presetFile;

    xdg.configFile."input-remapper-2/presets/BT5.0 KB Keyboard/Redragon Fizz Pro.json" = presetFile;
  };
}
