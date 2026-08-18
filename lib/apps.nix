# Launch commands shared by the Thunar UCA actions and Yazi openers.
{ lib, ... }:

let
  # Keep commands identical between both. Placeholders: Thunar %f, Yazi %s.
  # Kitty is the terminal; zellij is started by hand inside it, never wrapped.
  folderOpenCommands =
    pkgs:
    let
      kitty = lib.getExe pkgs.kitty;
      cursor = lib.getExe pkgs.code-cursor;
      vscode = lib.getExe pkgs.vscode;
      zed = lib.getExe pkgs.zed-editor;
    in
    {
      thunar = {
        terminal = "${kitty} --working-directory %f";
        cursor = "${cursor} %f";
        vscode = "${vscode} --new-window %f";
        zed = "${zed} -n %f";
      };
      yazi = {
        terminal = "${kitty} --detach --working-directory %s";
        cursor = "${cursor} %s";
        vscode = "${vscode} --new-window %s";
        zed = "${zed} -n %s";
      };
    };
in
{
  inherit folderOpenCommands;
}
