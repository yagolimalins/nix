#
# cli/broot — modal file tree that opens files in Helix.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages "cli";
  themeCfg = config.${namespace}.theme;
  palette = lib.${namespace}.palette;
  # Profile hx is the extraPackages wrapper. pkgs.helix has no LSPs on PATH.
  hx = "${config.home.profileDirectory}/bin/hx";
  rgb = lib.${namespace}.hexToRgbFunc;

  brootStormSkin = {
    default = "${rgb palette.text} ${rgb palette.bg}";
    tree = "${rgb palette.muted} none";
    parent = "${rgb palette.muted} none";
    file = "${rgb palette.text} none";
    directory = "${rgb palette.accent} none bold";
    exe = "${rgb palette.ok} none";
    link = "${rgb palette.purple} none";
    selected_line = "none ${rgb palette.border}";
    char_match = "${rgb palette.ok} none bold";
    file_error = "${rgb palette.urgent} none";
    input = "${rgb palette.text} ${rgb palette.surface}";
    flag_label = "${rgb palette.muted} ${rgb palette.surface}";
    flag_value = "${rgb palette.cyan} ${rgb palette.surface}";
    status_normal = "${rgb palette.muted} ${rgb palette.surface}";
    status_error = "${rgb palette.text} ${rgb palette.urgent}";
    status_italic = "${rgb palette.cyan} ${rgb palette.surface}";
    status_bold = "${rgb palette.accent} ${rgb palette.surface} bold";
    git_status_modified = "${rgb palette.warning} none";
    git_status_new = "${rgb palette.ok} none bold";
    git_status_conflicted = "${rgb palette.urgent} none";
    mode_command_mark = "${rgb palette.onAccent} ${rgb palette.accent} bold";
    scrollbar_thumb = "${rgb palette.accent} none";
    scrollbar_track = "${rgb palette.border} none";
  };
in
{
  config = lib.mkIf on {
    # Modal: j/k/l/ç are verbs (type-to-filter would eat them). Search with / or space.
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        modal = true;
        initial_mode = "command";
        default_flags = "";
        show_selection_mark = false;
        auto_open_staging_area = false;
        quit_on_last_cancel = false;
        cols_order = [
          "branch"
          "name"
        ];
        verbs = [
          {
            key = "h";
            execution = ":mode_command";
          }
          {
            key = "j";
            execution = ":parent";
          }
          {
            key = "k";
            execution = ":line_down";
          }
          {
            key = "l";
            execution = ":line_up";
          }
          {
            key = "ç";
            apply_to = "directory";
            execution = ":focus";
          }
          {
            key = "enter";
            apply_to = "directory";
            execution = ":focus";
          }
          {
            invocation = "helix";
            key = "enter";
            apply_to = "file";
            external = [
              "${hx}"
              "{file}"
            ];
            leave_broot = false;
            switch_terminal = false;
          }
        ];
      }
      // lib.optionalAttrs themeCfg.enable {
        skin = brootStormSkin;
        syntax_theme = "OceanDark";
      };
    };
  };
}
