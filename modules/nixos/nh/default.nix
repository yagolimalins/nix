#
# nh.nix — nh (Yet Another Nix Helper)
#
# Friendlier front-end for nixos-rebuild/home-manager (`nh os switch`,
# `nh home switch`, `nh search`, …) plus a weekly GC timer that trims old
# generations.
#
# NH_FLAKE is *not* set here — it is per logged-in user via HM mine.nh
# (`$HOME/.nix/`). A system-wide path cannot follow the active session.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.nh;
in
{
  options.${namespace}.nh.enable =
    lib.mkEnableOption "nh (Nix Helper) CLI + weekly GC timer";

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;

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
