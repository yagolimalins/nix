#
# nh.nix — nh (Yet Another Nix Helper)
#
# Friendlier front-end for nixos-rebuild/home-manager (`nh os switch`,
# `nh home switch`, `nh search`, …) plus a weekly GC timer that trims old
# generations. `flake` is pinned to this repo — derived from whichever
# Snowfall-declared user owns it, not hardcoded — so `nh os switch` works
# from anywhere without needing `--flake`.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.nh;
  primaryUser = lib.head (lib.attrNames config.snowfallorg.users);
in
{
  options.${namespace}.nh = {
    enable = lib.mkEnableOption "nh (Nix Helper) CLI + weekly GC timer";

    flake = lib.mkOption {
      type = lib.types.str;
      # Trailing slash is deliberate: nh rejects any `flake` value ending in
      # ".nix" (a heuristic to catch passing a file instead of a directory),
      # and this repo's checkout directory happens to be named `.nix`.
      default = "/home/${primaryUser}/.nix/";
      description = "Path nh defaults to (NH_FLAKE) when no --flake is given.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = cfg.flake;

      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 3";
      };
    };

    # nh's own cleaner supersedes nix.nix's `nix.gc.automatic` (it also
    # prunes old nh/home-manager generations, not just the store) — nh
    # itself warns if both are left on.
    nix.gc.automatic = lib.mkForce false;
  };
}
