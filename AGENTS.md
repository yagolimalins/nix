# Agent instructions

Personal NixOS flake on Snowfall Lib with Home Manager. Namespace `mine`, NixOS 26.05,
hosts `thinkpad` / `laptop` / `desktop`. One rebuild applies system and user config together.

Read the **Layout** and **Conventions** sections of [README.md](README.md) first — they are the
structural reference and are kept current. This file covers only what is easy to get wrong.

## Hard invariants

- Do not rename `mine.*` options, module directory names, package group names, or host names.
  Directory name = option name = flake attribute; renaming one breaks the others.
- Do not touch `flake.lock` or `inputs` unless explicitly asked.
- A refactor adds and removes nothing. Behavior-preserving only.
- Keep the diff minimal. `nix fmt` formats the whole tree, so if it reformats files outside your
  task that is pre-existing drift — leave it out of an unrelated change.
- `git add` new files. Flakes ignore untracked paths, so a new module is invisible to
  `nix flake check` until it is staged. This is why [install.sh](install.sh) stages what it scaffolds.
- Preserve comments that document a real constraint (upstream bugs, link flags, schema paths,
  ordering requirements). Find them with:

```bash
rg -n -g '*.nix' '#3756|1732114|WebKitGTK|lxdo|loaders\.cache|thunar\.xml|hiPrio|freeformType|lockstep'
```

## Where code goes

Helpers under `lib/` are merged into `lib.mine.*` automatically by [lib/default.nix](lib/default.nix).
Put a new helper in the file matching its concern; no manual wiring is needed.

| Concern | File |
| --- | --- |
| Module enable batching | [lib/modules.nix](lib/modules.nix) |
| Package group names, `packageGroupOn` | [lib/packages.nix](lib/packages.nix) |
| Terminal / Thunar / Yazi launch commands | [lib/apps.nix](lib/apps.nix) |
| Palette and hex converters | [lib/theme.nix](lib/theme.nix) |
| Monitor layout, Hyprland portal | [lib/host.nix](lib/host.nix) |

Everything else:

- **New module** — `modules/nixos/<name>/` or `modules/home/<name>/`, then enable it in
  [systems/common.nix](systems/common.nix) or [homes/common.nix](homes/common.nix).
- **New package in an existing group** — `modules/home/packages/groups/<group>.nix`.
- **New package group** — add the name and description to `packageGroups` in
  [lib/packages.nix](lib/packages.nix); the option is generated from that attrset.
- **Custom derivation** — top-level `packages/`. This is a flake output and is unrelated to
  `mine.packages`, which is the Home Manager user package groups.

## Module skeleton

```nix
{ config, lib, namespace, ... }:
let
  cfg = config.${namespace}.<name>;
in
{
  options.${namespace}.<name>.enable = lib.mkEnableOption "…";

  config = lib.mkIf cfg.enable { … };
}
```

Gate package groups with the shared helper, partially applied — never hand-rolled:

```nix
on = lib.${namespace}.packageGroupOn config.${namespace}.packages;   # then: on "rust"
```

Split a large module with the orchestrator pattern used by
[modules/home/theme/default.nix](modules/home/theme/default.nix): `default.nix` holds `imports`
plus the options declaration, and each submodule owns one concern and repeats the same gate.

## Verifying a change

Agents finish with:

```bash
nix fmt && nix flake check
```

Do **not** run host toplevel builds unless the user asks. The user rebuilds locally when ready.

When you want a full build (e.g. before switching, or to compare closures after a refactor):

```bash
for h in thinkpad laptop desktop; do
  nix build --no-link --print-out-paths ".#nixosConfigurations.$h.config.system.build.toplevel"
done
```

**The toplevel store hash changes on every edit, including whitespace and comments.** `self` is
pinned into `nix.registry` and `nixos-version`, so the repo tree is part of the system closure.
Comparing toplevel paths therefore proves nothing.

To prove a refactor is a no-op, compare the closure *with hashes* while filtering the
self-referential paths — `source`, `etc`, `etc-nix-registry.json`, `nixos-version`,
`nixos-system-*`, `system-path`, `system-units`, `user-units`, `dbus-1`, `unit-*.service`,
`X-Restart-Triggers-*`:

```bash
nix-store -qR <toplevel> | grep -vE -- '-(source|etc|nixos-version|system-path)$' | sort
```

Every Home Manager dotfile is its own content-addressed `hm_*` path in that closure, so any
change to a generated config file shows up immediately.

## Known footguns

Documented so they are not "fixed" blindly — each is deliberate or out of scope.

- [install.sh](install.sh) carries a hardcoded fallback package-group list duplicating
  [lib/packages.nix](lib/packages.nix). No drift today (32 names each), but it can drift.
- [modules/home/packages/default.nix](modules/home/packages/default.nix) builds its options with
  `//`, so a package group named `enable` would silently clobber the orchestrator toggle.
- Reordering `home.packages` changes the `home-manager-path` derivation hash without changing its
  contents, because `buildEnv` takes `paths` in order.
- `modules/home/cli/` is the one module with no `options` block; the `cli` package group gates it.
