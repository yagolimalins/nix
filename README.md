# ❄ NixOS Multi-Host Configuration

Flakes + [Snowfall Lib](https://snowfall.org) + Home Manager as a NixOS module. Namespace: `mine`.

## Screenshots

Hyprland + Waybar (NixOS 26.05):

![Desktop](screenshots/desktop.png)
![fastfetch](screenshots/fastfetch.png)
![btop](screenshots/btop.png)

## Layout

```
flake.nix                 # inputs + Snowfall wiring
install.sh                # bootstrap a new machine
lib/                      # lib.mine.* (enable-modules, palette, helpers)
systems/
  common.nix              # shared NixOS mine.*.enable
  x86_64-linux/<host>/    # hostname, hardware, mine.host facts
homes/
  common.nix              # shared HM mine.*.enable (+ stateVersion)
  x86_64-linux/<user>/    # username = directory name
modules/
  nixos/<name>/           # → mine.<name>.enable
  home/<name>/            # → mine.<name>.enable
  home/theme/             # mine.theme — gtk, editors, vscode-profiles, monitoring, …
  home/packages/groups/   # mine.packages.* leaves
```

Snowfall expects these directory names (`systems/`, `homes/`, `modules/`, `lib/`).

## Mental model

- **Opt-in:** nothing applies unless `mine.<module>.enable` (batched via `lib.mine.enable-modules` in `*/common.nix`).
- **Facts over conditionals:** hosts set `mine.host` / hostname; modules read `osConfig` — no `if host ==`.
- **Same generation:** HM ships with `nixos-rebuild` / `nh os switch` — no separate home-manager switch.
- **Pairs:** `display` (greetd/portals) ↔ `hyprland` (WM); `desktop` = keyring/Thunar/upower, not the WM; `mine.packages` is HM groups, not a Snowfall `packages/` output.
- **Shared UI:** `lib.mine.palette`; theme helpers in `lib.mine.*`; GTK/Qt via `mine.theme`; XDG/mime via `mine.xdg`.

## Rebuild

```bash
nh os switch              # uses programs.nh.flake (~/.nix/)
nh os switch -H laptop
sudo nixos-rebuild switch --flake ~/.nix#thinkpad
```

Flake attribute = `systems/x86_64-linux/<host>` directory name.

## Recipes

### Host

`systems/x86_64-linux/<host>/default.nix`:

```nix
{ lib, namespace, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "myhost";
  # ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-1";
}
```

Then `nh os switch -H myhost`. Shared modules come from `systems/common.nix`.

### User

`homes/x86_64-linux/<username>/default.nix` (name must match the Unix user). Optional overrides only; shared modules from `homes/common.nix`. Use `user@host` only for host-specific homes.

### Module

1. `modules/nixos/<name>/default.nix` or `modules/home/<name>/default.nix`
2. `options.${namespace}.<name>.enable` + `lib.mkIf cfg.enable`
3. Enable in `systems/common.nix` or `homes/common.nix` (or per host/user)

Folder name = option name. In `homes/common.nix` use literal `mine` (HM freeformType cycle with `${namespace}`).

`mine.packages.enable` is required for any package group. Toggle groups in `homes/x86_64-linux/<user>/package-groups.nix`.

## Conventions

| | |
|--|--|
| Namespace | `mine` |
| Enable | `mine.<module>.enable` / `lib.mine.enable-modules` |
| Host / user facts | `mine.host.*` / `mine.user.*` |
| Comments | Architecture, workarounds, Nix limits only |
| Format | `nix fmt` (treefmt + nixfmt); `.githooks/pre-commit` |
| stateVersion | Keep aligned with nixpkgs channel (`26.05`) |

Principles: Snowfall layout is source of truth; opt-in modules; facts over conditionals; behaviour-preserving refactors; forkable (no hardcoded username).

## Secure Boot

`mine.boot.secureBoot` (default `true`) → Lanzaboote; keys in `/var/lib/sbctl`. Bail out: `mine.boot.secureBoot = false`. No ESP: `mine.boot.efi = false` (GRUB). Enrollment: Setup Mode → `sudo sbctl enroll-keys -m` → enable Secure Boot in firmware.

## Bootstrap

From a minimal NixOS install: `./install.sh` — detects EFI/BIOS, generates hardware config, scaffolds host/user if missing, optional Lanzaboote keys, then `nixos-rebuild switch`.
