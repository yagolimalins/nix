#
# helix — Tokyo Night Storm + ABNT2 navigation (JKLÇ)
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.helix;
  themeCfg = config.${namespace}.theme;
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages;

  lldbDap = "${pkgs.lldb}/bin/lldb-dap";

  # Merged with Helix built-in languages.toml — debugger override only; format via rust-analyzer.
  rustLanguage = {
    name = "rust";
    "auto-format" = true;
    debugger = {
      name = "lldb-dap";
      transport = "stdio";
      command = lldbDap;
      templates = [
        {
          name = "binary";
          request = "launch";
          completion = [
            {
              name = "binary";
              completion = "filename";
            }
          ];
          args.program = "{0}";
        }
        {
          name = "binary (terminal)";
          request = "launch";
          completion = [
            {
              name = "binary";
              completion = "filename";
            }
          ];
          args = {
            program = "{0}";
            runInTerminal = true;
          };
        }
        {
          name = "attach";
          request = "attach";
          completion = [ "pid" ];
          args.pid = "{0}";
        }
      ];
    };
  };

  # Same clippy check as Zed (modules/home/packages/groups/dev.nix).
  rustAnalyzerConfig = {
    check = {
      command = "clippy";
      extraArgs = [
        "--"
        "-W"
        "clippy::pedantic"
      ];
    };
  };

  # Helix defines tailwindcss-ls but does not attach it to web languages.
  withTailwind = name: servers: {
    inherit name;
    language-servers = servers ++ [ "tailwindcss-ls" ];
  };

  # Helix ships js-debug-dap for javascript with an empty command; typescript
  # has no debugger at all. vscode-js-debug's `js-debug` wrapper is the server.
  jsDebugger = {
    name = "js-debug-dap";
    transport = "tcp";
    command = lib.getExe pkgs.vscode-js-debug;
    "port-arg" = "{} 127.0.0.1";
    quirks.absolute-paths = true;
    templates = [
      {
        name = "source";
        request = "launch";
        completion = [
          {
            name = "main";
            completion = "filename";
            default = "index.js";
          }
        ];
        args = {
          program = "{0}";
          skipFiles = [ "<node_internals>/**" ];
        };
      }
      {
        name = "source (deno)";
        request = "launch";
        completion = [
          {
            name = "main";
            completion = "filename";
            default = "main.ts";
          }
        ];
        args = {
          program = "{0}";
          runtimeExecutable = "deno";
          runtimeArgs = [
            "run"
            "--inspect-wait"
            "--allow-all"
          ];
          attachSimplePort = "9229";
          skipFiles = [ "<node_internals>/**" ];
        };
      }
      {
        name = "attach";
        request = "attach";
        completion = [ "pid" ];
        args = {
          mode = "local";
          processId = "{0}";
        };
      }
    ];
  };

  # deno lsp for deno.json; tsserver for Node. Both attached, gated by roots.
  jsTsLanguage = name: ext: {
    inherit name;
    roots = [
      "deno.json"
      "deno.jsonc"
      "package.json"
      "tsconfig.json"
    ];
    # Both listed; required-root-patterns start only one per project.
    language-servers = [
      "typescript-language-server"
      "deno"
      "tailwindcss-ls"
    ];
    "auto-format" = true;
    formatter = {
      command = "deno";
      args = [
        "fmt"
        "-"
        "--ext"
        ext
      ];
    };
    debugger = jsDebugger;
  };

  jsLanguages = [
    (withTailwind "html" [ "vscode-html-language-server" ])
    (withTailwind "css" [ "vscode-css-language-server" ])
    (jsTsLanguage "javascript" "js")
    (jsTsLanguage "typescript" "ts")
    (jsTsLanguage "jsx" "jsx")
    (jsTsLanguage "tsx" "tsx")
  ];

  # Full server tables — Helix does not merge `command` from the built-in
  # languages.toml when the user file redefines the same server name.
  jsLanguageServers = {
    deno = {
      command = "deno";
      args = [ "lsp" ];
      config.deno.enable = true;
      required-root-patterns = [
        "deno.json"
        "deno.jsonc"
      ];
    };
    typescript-language-server = {
      command = lib.getExe pkgs.typescript-language-server;
      args = [ "--stdio" ];
      config = {
        hostInfo = "helix";
        # Workspace has no node_modules/typescript; pin the nixpkgs tsserver.
        tsserver.path = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js";
      };
      required-root-patterns = [ "package.json" ];
    };
  };

  helixExtraPackages =
    lib.optionals (on "rust") [ pkgs.lldb ]
    ++ lib.optionals (on "c") [ pkgs.clang-tools ]
    ++ lib.optionals (on "python") [
      pkgs.ty
      pkgs.ruff
    ]
    ++ lib.optionals (on "js") [
      pkgs.typescript
      pkgs.typescript-language-server
      pkgs.vscode-langservers-extracted
      pkgs.tailwindcss-language-server
      pkgs.taplo
      pkgs.prisma-language-server
      pkgs.vscode-js-debug
    ]
    ++ lib.optionals (on "jvm") [ pkgs.jdt-language-server ]
    ++ lib.optionals (on "dotnet") [
      pkgs.omnisharp-roslyn
      pkgs.netcoredbg
    ]
    ++ [
      pkgs.marksman
      pkgs.bash-language-server
      pkgs.yaml-language-server
    ];

  # Shift hjkl one key right on ABNT2: j/k/l/ç = ← ↓ ↑ →
  abnt2Dirs =
    {
      left,
      down,
      up,
      right,
    }:
    {
      h = "no_op";
      j = left;
      k = down;
      l = up;
      "ç" = right;
    };

  # Hide arrow keys; view mode also drops default Ctrl-hjkl scroll aliases
  abnt2LegacyArrows = {
    left = "no_op";
    right = "no_op";
    up = "no_op";
    down = "no_op";
  };

  abnt2LegacyView = abnt2LegacyArrows // {
    "C-h" = "no_op";
    "C-j" = "no_op";
    "C-k" = "no_op";
    "C-l" = "no_op";
  };

  abnt2LegacyWindow = abnt2LegacyArrows // {
    "C-h" = "no_op";
    H = "no_op";
    J = "no_op";
    K = "no_op";
    L = "no_op";
  };

  abnt2Vertical =
    {
      down,
      up,
    }:
    {
      h = "no_op";
      j = "no_op"; # default scroll_down, superseded by k
      k = down;
      l = up;
    }
    // abnt2LegacyView;

  # Ctrl + same key as jump: swap instead (reliable on ABNT2 vs Shift)
  abnt2Swap =
    {
      left,
      down,
      up,
      right,
    }:
    {
      H = "no_op";
      J = "no_op";
      K = "no_op";
      L = "no_op";
      "C-j" = left;
      "C-k" = down;
      "C-l" = up;
      "C-ç" = right;
    };

  # Ctrl + JKLÇ — jump split from normal mode (swap stays under Ctrl-w / Space w)
  abnt2GlobalJump =
    {
      left,
      down,
      up,
      right,
    }:
    {
      "C-j" = left;
      "C-k" = down;
      "C-l" = up;
      "C-ç" = right;
    };

  abnt2Move = {
    left = "move_char_left";
    down = "move_line_down";
    up = "move_line_up";
    right = "move_char_right";
  };

  abnt2Extend = {
    left = "extend_char_left";
    down = "extend_line_down";
    up = "extend_line_up";
    right = "extend_char_right";
  };

  windowMode =
    abnt2Dirs {
      left = "jump_view_left";
      down = "jump_view_down";
      up = "jump_view_up";
      right = "jump_view_right";
    }
    // abnt2Swap {
      left = "swap_view_left";
      down = "swap_view_down";
      up = "swap_view_up";
      right = "swap_view_right";
    }
    // abnt2LegacyWindow;

  viewMode = abnt2Vertical {
    down = "scroll_down";
    up = "scroll_up";
  };

  abnt2Movement = {
    normal =
      abnt2Dirs abnt2Move
      // abnt2GlobalJump {
        left = "jump_view_left";
        down = "jump_view_down";
        up = "jump_view_up";
        right = "jump_view_right";
      }
      // {
        g =
          abnt2Dirs {
            left = "goto_line_start";
            down = "move_line_down";
            up = "move_line_up";
            right = "goto_line_end";
          }
          // {
            d = "goto_definition";
            r = "goto_reference";
            i = "goto_implementation";
            y = "goto_type_definition";
          };
        "," = {
          d = "goto_definition";
          r = "goto_reference";
          i = "goto_implementation";
          t = "goto_type_definition";
          a = "code_action";
          n = "goto_next_diag";
          p = "goto_prev_diag";
          h = "hover";
          s = "symbol_picker";
          "/" = "global_search";
        };
        z = viewMode;
        Z = viewMode;
        "C-w" = windowMode;
        space = {
          w = windowMode;
        };
      };
    select = abnt2Dirs abnt2Extend;
  };
in
{
  options.${namespace}.helix.enable =
    lib.mkEnableOption "Helix (ABNT2 keymap + Tokyo Night Storm when mine.theme is on)";

  config = lib.mkIf (cfg.enable && on "editors") {
    programs.helix = {
      enable = true;
      defaultEditor = false;
      extraPackages = helixExtraPackages;
      languages = {
        language = lib.optionals (on "rust") [ rustLanguage ] ++ lib.optionals (on "js") jsLanguages;
        language-server =
          lib.optionalAttrs (on "rust") {
            rust-analyzer.config = rustAnalyzerConfig;
          }
          // lib.optionalAttrs (on "js") jsLanguageServers;
      };
      settings = {
        editor = {
          "auto-format" = true;
          bufferline = "multiple";
          "clipboard-provider" = "wayland";
          "end-of-line-diagnostics" = "error";
          inline-diagnostics = {
            cursor-line = "warning";
          };
          lsp = {
            "display-messages" = true;
            "display-progress-messages" = true;
          };
        };
        keys = abnt2Movement;
      }
      // lib.optionalAttrs themeCfg.enable {
        theme = "tokyonight_storm";
      };
    };
  };
}
