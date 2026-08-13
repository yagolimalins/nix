#
# cli — shell essentials, file tools, HTTP client (gated by mine.packages.cli).
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  pkgCfg = config.${namespace}.packages;
  on = pkgCfg.enable && pkgCfg.cli.enable;

  openers = lib.${namespace}.folderOpenCommands pkgs;
  hx = lib.getExe pkgs.helix;
  kitty = lib.getExe pkgs.kitty;
  zathura = lib.getExe pkgs.zathura;
  vlc = lib.getExe pkgs.vlc;
  ristretto = lib.getExe pkgs.ristretto;
  librewolf = lib.getExe pkgs.librewolf;

  # VS Code and Zed keep their launcher alive during IPC — background explicitly.
  yaziOpenVscode = pkgs.writeShellScriptBin "yazi-open-vscode" ''
    ${lib.getExe pkgs.vscode} --new-window "$@" &
    disown
  '';
  yaziOpenZed = pkgs.writeShellScriptBin "yazi-open-zed" ''
    ${lib.getExe pkgs.zed-editor} -n "$@" &
    disown
  '';
in
{
  config = lib.mkIf on {
    # Packages without HM program modules — the rest come from programs.* below.
    home.packages = with pkgs; [
      ripgrep
      fd
      miniserve
      just
      yazi
      xh
      duf
      dust
      yaziOpenVscode
      yaziOpenZed
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--reverse"
        "--bind=ctrl-/:toggle-preview"
      ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    programs.jq.enable = true;

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };

    programs.tealdeer.enable = true;

    xdg.configFile."yazi/plugins/smart-enter.yazi/main.lua".text = ''
      --- @since 25.5.31
      --- @sync entry

      local function setup(self, opts) self.open_multi = opts.open_multi end

      local function entry(self)
        local h = cx.active.current.hovered
        ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = not self.open_multi })
      end

      return { entry = entry, setup = setup }
    '';

    xdg.configFile."yazi/keymap.toml" = {
      force = true;
      text = ''
      # Enter: enter directories, open files (Yazi default Enter always runs open).
      [mgr]
      prepend_keymap = [
        { on = "<Enter>", run = "plugin smart-enter", desc = "Enter directory or open file" },
      ]
      '';
    };

    xdg.configFile."yazi/yazi.toml" = {
      force = true;
      text = ''
      # orphan = true keeps Yazi usable; edit overrides Yazi preset block = true.
      [opener]
      edit = [
        { run = "${kitty} --detach --directory %d1 -- ${hx} %s", desc = "Helix", orphan = true },
      ]
      folder = [
        { run = "${openers.yazi.terminal}", desc = "Open Terminal Here", orphan = true },
        { run = "${openers.yazi.cursor}", desc = "Open Cursor Here", orphan = true },
        { run = "${lib.getExe yaziOpenVscode} %s", desc = "Open VSCode Here", orphan = true },
        { run = "${lib.getExe yaziOpenZed} %s", desc = "Open Zed Here", orphan = true },
      ]
      zathura = [
        { run = "${zathura} %s", desc = "Zathura", orphan = true },
      ]
      vlc = [
        { run = "${vlc} %s", desc = "VLC", orphan = true },
      ]
      image = [
        { run = "${ristretto} %s", desc = "Ristretto", orphan = true },
      ]
      browser = [
        { run = "${librewolf} %s", desc = "LibreWolf", orphan = true },
      ]

      [open]
      prepend_rules = [
        { url = "*/", use = [ "open", "reveal", "folder" ] },
        { mime = "text/html", use = "browser" },
        { mime = "application/xhtml+xml", use = "browser" },
        { mime = "application/pdf", use = "zathura" },
        { mime = "video/*", use = "vlc" },
        { mime = "audio/*", use = "vlc" },
        { mime = "image/*", use = "image" },
        { mime = "text/*", use = "edit" },
        { url = "*.{rs,toml,nix,md,json,yaml,yml,ts,tsx,js,jsx,css,html,sh}", use = "edit" },
      ]
      '';
    };
  };
}
