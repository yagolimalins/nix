# NixOS Multi-Host Configuration

Declarative multi-machine NixOS setup using **flakes**, **[Snowfall Lib](https://snowfall.org)**, and **Home Manager as a NixOS module**. Focus: reuse, clear module boundaries, and reproducible hosts.

## Structure

```
.
├── flake.nix                 # Snowfall entry — inputs + shared module wiring
├── flake.lock
├── install.sh                # Interactive bootstrap for a new machine
├── .githooks/pre-commit      # Runs `nix fmt` on staged .nix files
├── lib/                      # lib.mine.* helpers (enable-modules, host layout, portal)
├── systems/                  # NixOS hosts (Snowfall: systems/, not hosts/)
│   ├── common.nix            # Shared mine.*.enable toggles for every host
│   └── x86_64-linux/
│       ├── desktop/
│       ├── laptop/
│       └── thinkpad/
├── homes/                    # Home Manager users (Snowfall: homes/, not users/)
│   ├── common.nix            # Shared HM toggles + XDG dirs
│   └── x86_64-linux/<user>/
└── modules/
    ├── nixos/                # System modules → mine.<name>.enable
    └── home/                 # HM modules → mine.<name>.enable
        └── packages/groups/  # Package groups by category
```

| Path | Role |
|------|------|
| `systems/` | Hosts: hardware, hostname, `mine.host.*` facts |
| `homes/` | Users: HM entry points; username = directory name |
| `modules/nixos/` | Opt-in NixOS features (boot, audio, display, …) |
| `modules/home/` | Opt-in HM features (hyprland, shell, packages, …) |
| `lib/` | Shared Nix functions under `lib.mine` |
| `overlays/` | *(unused)* — add Snowfall overlays here if needed |
| `packages/` | *(unused)* — Snowfall custom packages output, not HM package lists |

Snowfall **requires** the directory names `systems/`, `homes/`, `modules/`, and `lib/`. Renaming them to `hosts/` or `users/` breaks discovery unless you reconfigure Snowfall’s root layout.

## Organization

### Hosts (`systems/`)

Each host is `systems/x86_64-linux/<name>/`:

- `default.nix` — hostname, imports, `mine.host` facts
- `hardware-configuration.nix` — generated
- optional host files (`thinkpad.nix`, `gpu.nix`)

Shared toggles live in `systems/common.nix`.

### Users (`homes/`)

Each user is `homes/x86_64-linux/<username>/default.nix`.  
A home **without** `@host` applies on every machine. Use `user@host` only when you need host-specific homes.

### Modules

- **NixOS:** boot, networking, locale, display, desktop, audio, bluetooth, printing, users, virtualisation, security-related (lanzaboote via boot), services (dns, postgresql, tailscale, …).
- **Home:** shell, terminal (kitty), desktop (hyprland, waybar, theme, …), development (`packages` groups), services (mail, nightshift, …).

Facts modules (`mine.host`, `mine.user`) are options-only and always imported.

### Packages

HM module `mine.packages` — not a Snowfall `packages/` flake output.

- `mine.packages.enable` → direnv + all groups default on
- Groups live under `modules/home/packages/groups/` (`system`, `desktop`, `dev`, `apps`, `media`)
- Opt out: `mine.packages.ides.enable = false`

### Home Manager

Integrated by Snowfall as a NixOS module (same generation as the system). Homes read host facts via `osConfig.mine.host`.

### Lib

`lib.mine.enable-modules` — batch-enable modules  
`lib.mine.mkDualMonitorHost` — shared HDMI+eDP Hyprland layout  
`lib.mine.mkGtkHyprlandPortal` — GTK portal stub for Hyprland (`UseIn=gnome` workaround)

## Adding a new host

1. Create `systems/x86_64-linux/<host>/`.
2. Add `hardware-configuration.nix` (`nixos-generate-config` or `./install.sh`).
3. Add `default.nix`:

```nix
{ lib, namespace, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "myhost";

  # Optional layout facts for Hyprland:
  # ${namespace}.host = lib.${namespace}.mkDualMonitorHost "HDMI-A-1";
}
```

4. Rebuild: `sudo nixos-rebuild switch --flake .#myhost` (or `nh os switch`).

`systems/common.nix` already enables the shared module set.

## Adding a new user

1. Create `homes/x86_64-linux/<username>/default.nix`:

```nix
{ ... }:

{
  # Optional overrides, e.g.:
  # mine.packages.creator.enable = false;
  # mine.user.wallpaper = ./wall.png;
}
```

2. Directory name **must** match the Unix username.
3. Rebuild the system (HM is applied as part of the NixOS generation).

Shared modules come from `homes/common.nix`.

## Adding a module

1. Create `modules/nixos/<name>/default.nix` or `modules/home/<name>/default.nix`.
2. Expose `options.${namespace}.<name>.enable` (unless options-only facts).
3. Gate config with `lib.mkIf cfg.enable`.
4. Enable it in `systems/common.nix` or `homes/common.nix` (or per host/user).

Folder name = option name (`modules/nixos/audio` → `mine.audio`).

## Rebuilding the system

```bash
# Flake attribute = systems/ directory name
sudo nixos-rebuild switch --flake ~/.nix#thinkpad

# From the repo (nh uses NH_FLAKE / programs.nh.flake)
nh os switch

# Explicit host
nh os switch -H laptop
```

Home Manager is included in that switch (Snowfall + HM-as-NixOS-module). There is no separate `home-manager switch` required for normal use.

Bootstrap a **new** machine from minimal NixOS:

```bash
./install.sh
```

That generates hardware config, scaffolds host/user, creates Secure Boot keys if needed, rebuilds, and guides UEFI enrollment.

## Development

- One concern per module; prefer `mine.*.enable` over giant files.
- Host-specific values → `mine.host` / host files under `systems/`, not `if host ==` in UI modules.
- User-specific values → `mine.user` or `homes/<user>/default.nix`.
- Deduplicate via `lib/mine` helpers.
- Format with `nix fmt` (treefmt + nixfmt); `.githooks` runs it on commit.
- Keep `system.stateVersion` / `home.stateVersion` aligned with the nixpkgs channel (`26.05`).

## Conventions

| Convention | Detail |
|------------|--------|
| Namespace | `mine` (`snowfall.namespace`) |
| Enable pattern | `mine.<module>.enable` |
| Batch enable | `lib.mine.enable-modules [ ... ]` |
| Host facts | `mine.host.monitors` / `workspaces` |
| User facts | `mine.user.wallpaper` |
| HM namespace in `homes/common.nix` | Literal `mine` (HM freeformType cycle) |
| Comments | Only architecture, workarounds, Nix limitations |
| Attribute order | options → config; boot/hardware/networking/services/… as applicable |
| Lists | Trailing commas where it helps diffs |

## Principles

1. **Snowfall layout is the source of truth** — don’t invent parallel `hosts/` / `users/` trees.
2. **Opt-in modules** — nothing applies unless enabled.
3. **Facts over conditionals** — hosts declare data; modules consume `osConfig` / `config`.
4. **Behaviour-preserving refactors** — structure and clarity first; no silent feature drops.
5. **Forkability** — namespace and paths are not tied to one username.

## Secure Boot

`mine.boot.secureBoot` (default `true`) uses Lanzaboote. Keys live in `/var/lib/sbctl`. `./install.sh` creates keys before the first switch; firmware enrollment (`sbctl enroll-keys -m` in Setup Mode) remains a one-time manual step. Disable with `mine.boot.secureBoot = false` if needed.
