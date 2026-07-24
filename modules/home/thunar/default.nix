#
# thunar.nix — Thunar file manager user-level config
#
# Sets Kitty as the preferred terminal for exo-open and defines custom
# right-click actions for opening the current folder in editors/terminal.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.thunar;
in
{
  options.${namespace}.thunar.enable = lib.mkEnableOption "Thunar file manager user-level config";

  config = lib.mkIf cfg.enable {
    # Tell Thunar's exo-open which terminal to launch from the context menu.
    xdg.configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=kitty
    '';

    # Custom actions — shown when right-clicking a folder or the background.
    # force = true so Nix can overwrite the file Thunar manages itself.
    xdg.configFile."Thunar/uca.xml" = {
      force = true;
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          <action>
            <icon>utilities-terminal</icon>
            <name>Open Terminal Here</name>
            <unique-id>thunar-uca-terminal</unique-id>
            <command>kitty --working-directory %f</command>
            <description>Open Kitty in this folder</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
          <action>
            <icon>cursor</icon>
            <name>Open Cursor Here</name>
            <unique-id>thunar-uca-cursor</unique-id>
            <command>cursor %f</command>
            <description>Open folder in Cursor</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
          <action>
            <icon>vscode</icon>
            <name>Open VSCode Here</name>
            <unique-id>thunar-uca-vscode</unique-id>
            <command>code %f</command>
            <description>Open folder in Visual Studio Code</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
          <action>
            <icon>zed</icon>
            <name>Open Zed Here</name>
            <unique-id>thunar-uca-zed</unique-id>
            <command>zeditor %f</command>
            <description>Open folder in Zed</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
        </actions>
      '';
    };
  };
}
