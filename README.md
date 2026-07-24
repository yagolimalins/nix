# ❄️ NixOS Multi-Host Configuration

A clean, modular, and reproducible **NixOS setup** built with **flakes**, **[Snowfall Lib](https://snowfall.org)**, and **Home Manager as a NixOS module**.

This repository demonstrates a real-world multi-machine NixOS configuration, focused on **reusability, clarity, and reproducibility** — the same ideas used in infrastructure-as-code environments.

---

## 📸 Screenshots

![Desktop](screenshots/desktop.png)
![Fastfetch](screenshots/fastfetch.png)
![Btop](screenshots/btop.png)

---

## 🚀 Why this setup?

- Declarative system configuration
- One codebase, multiple machines
- Minimal duplication between hosts
- Clear separation of concerns
- Easy to extend and maintain

---

## ✨ Features

- ❄️ Flakes-first workflow, wired up by **Snowfall Lib**
- 🖥️ Multi-host support (desktop, laptop, etc.) — hosts are auto-discovered from the filesystem
- 🏠 Home Manager integrated as a NixOS module, homes auto-discovered the same way
- 🧩 Modular system design — every feature is its own `mine.<module>.enable` toggle
- 🔁 Reproducible builds

---

## 🗂️ Repository Structure

    .
    ├── flake.nix                        # Entry point — a thin snowfall-lib.mkFlake call
    ├── flake.lock
    ├── .githooks/
    │   └── pre-commit                   # Formats staged .nix files before commit
    ├── install.sh                       # Interactive installer (hardware config, flakes, rebuild)
    ├── lib/
    │   └── default.nix                  # Shared helper, merged into lib.mine.*
    ├── systems/
    │   ├── common.nix                   # Module toggles shared by every host (wired via systems.modules.nixos)
    │   └── x86_64-linux/                # <arch>-<format>, per Snowfall Lib's system targets
    │       ├── thinkpad/
    │       │   ├── default.nix              # Host entry point: hostname + host-specific imports
    │       │   ├── hardware-configuration.nix
    │       │   └── thinkpad.nix              # i915, TLP thresholds, thinkfan, …
    │       ├── laptop/
    │       │   ├── default.nix
    │       │   ├── hardware-configuration.nix
    │       │   └── gpu.nix                   # amdgpu
    │       └── desktop/
    │           ├── default.nix
    │           └── hardware-configuration.nix
    ├── homes/
    │   ├── common.nix                   # Module toggles + XDG basics shared by every user (homes.modules)
    │   └── x86_64-linux/
    │       └── <user>/                  # e.g. "yago" — one dir per person; username inferred from this name
    │           └── default.nix          # Thin Home Manager entry point (user-specific overrides only)
    └── modules/
        ├── nixos/                       # NixOS (system-level) modules — one `mine.<name>.enable` toggle each
        │   ├── nix/                     #   Nix daemon, GC, stateVersion
        │   ├── boot/                    #   Bootloader, kernel, tmpfs, sysctls, firmware
        │   ├── logging/                 #   journald limits
        │   ├── networking/              #   NetworkManager
        │   ├── nh/                      #   nh CLI (nixos-rebuild/home-manager front-end) + weekly GC
        │   ├── dns/                     #   AdGuard Home + systemd-resolved
        │   ├── locale/                  #   Timezone, locale, console keymap
        │   ├── fonts/                   #   System fonts
        │   ├── input-method/            #   fcitx5 (Chinese + Japanese)
        │   ├── audio/                   #   PipeWire, WirePlumber, realtime limits
        │   ├── bluetooth/               #   Bluetooth hardware + Blueman
        │   ├── printing/                #   CUPS
        │   ├── power/                   #   CPU governor + toggle script
        │   ├── display/                 #   Hyprland, greetd, logind, XDG portal
        │   ├── desktop/                 #   Thunar, keyring, dconf, file services
        │   ├── programs/                #   Firefox, JDK, nix-ld
        │   ├── virtualisation/          #   Docker + Ollama
        │   ├── postgresql/              #   Postgres dev container
        │   ├── input-remapper/          #   Key/button remapping
        │   ├── tailscale/               #   WireGuard mesh VPN
        │   └── users/                   #   User account + session env
        └── home/                        # Home Manager (user-level) modules — one `mine.<name>.enable` toggle each
            ├── packages/                #   User packages + direnv
            ├── theme/                   #   GTK theme, icons, cursor (WhiteSur)
            ├── hyprland/                #   Hyprland WM settings + keybinds
            ├── waybar/                  #   Status bar config + CSS
            ├── launchers/               #   Wofi launcher + CSS
            ├── kitty/                   #   Kitty terminal
            ├── shell/                   #   Bash prompt
            ├── notifications/           #   Mako
            ├── lockscreen/              #   Hyprlock + Hypridle
            ├── nightshift/              #   Hyprsunset timers
            ├── mail/                    #   Proton Mail Bridge
            ├── thunar/                  #   Thunar file manager
            ├── input-remapper/          #   Per-user remap profiles
            └── spotify/                 #   spotify-player + theme

Every `.nix` file lives at `<module>/default.nix`, which is the layout [Snowfall Lib](https://snowfall.org) expects.

---

## 🧠 Design Overview

- **`flake.nix`** — thin `snowfall-lib.mkFlake` call; Snowfall auto-discovers `systems/`, `homes/`, `modules/`, and `lib/`. Custom options live under `mine.*` (`snowfall.namespace`).
- **Opt-in modules** — each `modules/{nixos,home}/*` is gated by `mine.<name>.enable`; nothing applies unless a system or home turns it on.
- **`systems/common.nix` / `homes/common.nix`** — shared `enable-modules` lists (plus home XDG basics), applied via `systems.modules.nixos` / `homes.modules` in `flake.nix`.
- **Per-host / per-user entry points** — thin: host = hostname + hardware; user = overrides only. Username comes from the directory name; modules read users from `config.snowfallorg.users`.
- **`lib.mine.enable-modules`** — turns a name list into `{ <name>.enable = true; }` for those toggle blocks.
- **Host-specific UI** — things like Hyprland monitors use Snowfall's `host` arg (see `modules/home/hyprland`).

`./install.sh` scaffolds a new host under `systems/` and the installing user under `homes/` if missing.

---

## 🎨 Formatting

[`treefmt`](https://github.com/numtide/treefmt) (via [`treefmt-nix`](https://github.com/numtide/treefmt-nix)) wraps [`nixfmt`](https://github.com/NixOS/nixfmt) (RFC 166). Config lives inline in `flake.nix`'s `outputs-builder`; run it repo-wide with:

    nix fmt

A tracked pre-commit hook in `.githooks/` formats any staged `.nix` files the same way. `./install.sh` enables it for the clone automatically (`git config core.hooksPath .githooks`); to do it by hand:

    git config core.hooksPath .githooks

---

## 🧪 Installation (NixOS Minimal)

This setup is designed to be applied on top of a **minimal NixOS installation**.

Run the interactive installer on the target machine:

    ./install.sh

It will walk you through five steps:

1. **Generate hardware configuration** — writes `systems/x86_64-linux/<host>/hardware-configuration.nix` and scaffolds a host `default.nix` if missing
2. **Scaffold Home Manager user** — creates `homes/x86_64-linux/<user>/default.nix` for the user running the script if missing (shared modules come from `homes/common.nix`)
3. **Enable flakes** — adds `nix-command` and `flakes` to `~/.config/nix/nix.conf`
4. **Enable git hooks** — sets `core.hooksPath` to `.githooks` so pre-commit runs `nix fmt`
5. **Apply the system** — runs `sudo nixos-rebuild switch --flake .#<host>`

---

## ⚡ Quick Start (TL;DR)

    ./install.sh

---

## 📌 Notes

- Hardware-specific state is isolated per host
- Shared logic lives in clean, reusable modules
- Suitable for personal setups or as a foundation for larger NixOS deployments

---

## 📄 License

Use it, learn from it, break it, improve it.
That’s the whole point 🙂
