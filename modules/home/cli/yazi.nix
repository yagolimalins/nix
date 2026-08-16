#
# cli/yazi — file manager, its background openers and ABNT2 keymap.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  on = lib.${namespace}.packageGroupOn config.${namespace}.packages "cli";
  openers = lib.${namespace}.folderOpenCommands pkgs;
  # Profile hx is the extraPackages wrapper. pkgs.helix has no LSPs on PATH.
  hx = "${config.home.profileDirectory}/bin/hx";
  kitty = lib.getExe pkgs.kitty;

  # GUI/IDE launchers must return immediately — otherwise Yazi waits on the child.
  mkYaziBgOpener =
    name: bin:
    pkgs.writeShellScriptBin name ''
      ${bin} "$@" &
      disown
    '';

  yaziOpenZathura = mkYaziBgOpener "yazi-open-zathura" (lib.getExe pkgs.zathura);
  yaziOpenVlc = mkYaziBgOpener "yazi-open-vlc" (lib.getExe pkgs.vlc);
  yaziOpenRistretto = mkYaziBgOpener "yazi-open-ristretto" (lib.getExe pkgs.ristretto);
  yaziOpenLibrewolf = mkYaziBgOpener "yazi-open-librewolf" (lib.getExe pkgs.librewolf);
  yaziOpenXdg = mkYaziBgOpener "yazi-open-xdg" "${lib.getExe' pkgs.xdg-utils "xdg-open"}";
  yaziOpenCursor = mkYaziBgOpener "yazi-open-cursor" (lib.getExe pkgs.code-cursor);
  yaziOpenVscode = mkYaziBgOpener "yazi-open-vscode" "${lib.getExe pkgs.vscode} --new-window";
  yaziOpenZed = mkYaziBgOpener "yazi-open-zed" "${lib.getExe pkgs.zed-editor} -n";
in
{
  config = lib.mkIf on {
    home.packages = [
      pkgs.yazi
      yaziOpenZathura
      yaziOpenVlc
      yaziOpenRistretto
      yaziOpenLibrewolf
      yaziOpenXdg
      yaziOpenCursor
      yaziOpenVscode
      yaziOpenZed
    ];

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
        # ABNT2: j/k/l/ç = ← ↓ ↑ → (unbind default h/j/k/l).
        # Enter: enter directories, open files (Yazi default Enter always runs open).
        [mgr]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "leave", desc = "Back to parent" },
          { on = "k", run = "arrow next", desc = "Next file" },
          { on = "l", run = "arrow prev", desc = "Previous file" },
          { on = "ç", run = "enter", desc = "Enter directory" },
          { on = "<Enter>", run = "plugin smart-enter", desc = "Enter directory or open file" },
        ]

        [tasks]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next task" },
          { on = "l", run = "arrow prev", desc = "Previous task" },
        ]

        [spot]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "swipe prev", desc = "Swipe to previous file" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
          { on = "ç", run = "swipe next", desc = "Swipe to next file" },
        ]

        [pick]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next option" },
          { on = "l", run = "arrow prev", desc = "Previous option" },
        ]

        [input]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "move -1", desc = "Move left" },
          { on = "k", run = "recall 1", desc = "Next input" },
          { on = "l", run = "recall -1", desc = "Previous input" },
          { on = "ç", run = "move 1", desc = "Move right" },
        ]

        [confirm]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
        ]

        [help]
        prepend_keymap = [
          { on = "h", run = "noop" },
          { on = "j", run = "noop" },
          { on = "k", run = "arrow next", desc = "Next line" },
          { on = "l", run = "arrow prev", desc = "Previous line" },
        ]
      '';
    };

    xdg.configFile."yazi/yazi.toml" = {
      force = true;
      text = ''
        # orphan = true detaches from Yazi's task queue; wrappers & disown so the shell returns too.
        [opener]
        edit = [
          { run = "${kitty} --detach --directory %d1 -- ${hx} %s", desc = "Helix", orphan = true },
        ]
        # Replace Yazi presets — stock xdg-open openers block until the handler exits.
        open = [
          { run = "${lib.getExe yaziOpenXdg} %s1", desc = "Open", orphan = true },
        ]
        reveal = [
          { run = "${lib.getExe yaziOpenXdg} %d1", desc = "Reveal", orphan = true },
        ]
        play = [
          { run = "${lib.getExe yaziOpenVlc} %s1", desc = "Play", orphan = true },
        ]
        folder = [
          { run = "${openers.yazi.terminal}", desc = "Open Terminal Here", orphan = true },
          { run = "${lib.getExe yaziOpenCursor} %s", desc = "Open Cursor Here", orphan = true },
          { run = "${lib.getExe yaziOpenVscode} %s", desc = "Open VSCode Here", orphan = true },
          { run = "${lib.getExe yaziOpenZed} %s", desc = "Open Zed Here", orphan = true },
        ]
        zathura = [
          { run = "${lib.getExe yaziOpenZathura} %s", desc = "Zathura", orphan = true },
        ]
        vlc = [
          { run = "${lib.getExe yaziOpenVlc} %s", desc = "VLC", orphan = true },
        ]
        image = [
          { run = "${lib.getExe yaziOpenRistretto} %s", desc = "Ristretto", orphan = true },
        ]
        browser = [
          { run = "${lib.getExe yaziOpenLibrewolf} %s", desc = "LibreWolf", orphan = true },
        ]

        [open]
        prepend_rules = [
          { url = "*/", use = "folder" },
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
