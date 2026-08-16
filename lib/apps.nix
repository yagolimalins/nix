# Launch commands shared by the default terminal, Thunar UCA actions and Yazi openers.
{ lib, ... }:

let
  # Kitty stays the emulator; sessions start zellij inside it.
  terminalCommands =
    pkgs:
    let
      kitty = lib.getExe pkgs.kitty;
      zellij = lib.getExe pkgs.zellij;
      zsh = lib.getExe pkgs.zsh;
      # Login shell defers zellij until kitty is mapped — avoids stale size on Hyprland open.
      zellijCmd = "${zsh} -l -c ${lib.escapeShellArg zellij}";
    in
    {
      launch = "${kitty} -- ${zellijCmd}";
      # Placeholders for Thunar (%f) and Yazi (%s).
      thunarOpenHere = "${kitty} --working-directory %f -- ${zellijCmd}";
      yaziOpenHere = "${kitty} --detach --working-directory %s -- ${zellijCmd}";
    };

  # Thunar UCA + Yazi folder openers — keep commands identical between both.
  folderOpenCommands =
    pkgs:
    let
      term = terminalCommands pkgs;
      cursor = lib.getExe pkgs.code-cursor;
      vscode = lib.getExe pkgs.vscode;
      zed = lib.getExe pkgs.zed-editor;
    in
    {
      thunar = {
        terminal = term.thunarOpenHere;
        cursor = "${cursor} %f";
        vscode = "${vscode} --new-window %f";
        zed = "${zed} -n %f";
      };
      yazi = {
        terminal = term.yaziOpenHere;
        cursor = "${cursor} %s";
        vscode = "${vscode} --new-window %s";
        zed = "${zed} -n %s";
      };
    };
in
{
  inherit terminalCommands folderOpenCommands;
}
