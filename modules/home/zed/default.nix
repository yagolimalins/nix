#
# zed.nix — Zed editor (settings, keymap, extensions)
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.zed;
in
{
  options.${namespace}.zed.enable = lib.mkEnableOption "Zed editor with declarative settings";

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      extensions = [
        "csharp"
        "html"
        "java"
        "nix"
        "sql"
        "toml"
        "xml"
      ];

      userSettings = {
        edit_predictions.provider = "zed";
        show_edit_predictions = false;
        format_on_save = "on";
        code_lens = "off";
        semantic_tokens = "combined";
        show_signature_help_after_edits = false;
        auto_signature_help = false;
        gutter.runnables = true;

        languages.Rust = {
          show_edit_predictions = false;
          format_on_save = "on";
          inlay_hints = {
            enabled = true;
            show_type_hints = false;
            show_parameter_hints = false;
            show_other_hints = false;
          };
        };

        project_panel.dock = "left";
        outline_panel.dock = "left";
        collaboration_panel.dock = "left";
        agent = {
          dock = "right";
          favorite_models = [ ];
          model_parameters = [ ];
        };
        git_panel.dock = "left";

        ui_font_size = 16;
        buffer_font_size = 15;
        theme = {
          mode = "dark";
          light = "One Light";
          dark = "One Dark";
        };

        lsp.rust-analyzer.initialization_options = {
          check = {
            command = "clippy";
            extraArgs = [
              "--"
              "-W"
              "clippy::pedantic"
            ];
          };
          completion.postfix.enable = true;
          rust.analyzerTargetDir = true;
          procMacro.enable = true;
          cargo = {
            buildScripts.enable = true;
            allFeatures = true;
          };
          inlayHints = {
            chainingHints.enable = false;
            maxLength = null;
            lifetimeElisionHints = {
              enable = "skip_trivial";
              useParameterNames = true;
            };
            closureReturnTypeHints.enable = "always";
            bindingModeHints.enable = true;
          };
          imports = {
            granularity.group = "module";
            prefix = "self";
          };
        };
      };

      userKeymaps = [
        {
          context = "Editor";
          bindings = {
            shift-space = "task::Rerun";
          };
        }
      ];
    };
  };
}
