# Username inferred from directory name. Shared modules: homes/common.nix.
{ ... }:

{
  imports = [ ./package-groups.nix ];

  # Optional: mine.user.wallpaper = ./wall.png;
}
