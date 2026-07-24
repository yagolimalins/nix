{
  description = "Multi-host NixOS flake, built with Snowfall Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Auto-discovers systems/, homes/, modules/ and wires everything
    # together — see https://snowfall.org for the expected layout.
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs"; # keep home-manager on the same nixpkgs
    };

    # Wraps treefmt around per-language formatters (nixfmt here) so
    # `nix fmt` can grow beyond Nix without changing the flake wiring.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # Prefix for every custom option this flake declares (config.mine.*,
      # lib.mine.*, …) — deliberately not tied to any specific username, so
      # this repo stays easy to fork: add your own systems/<host> and
      # homes/<user>, and everything under modules/ just works.
      snowfall.namespace = "mine";

      # Passed straight to nixpkgs when Snowfall Lib instantiates `pkgs` —
      # do this here instead of a `nixpkgs.config` module (that option
      # conflicts with the already-instantiated `pkgs` Snowfall provides).
      channels-config.allowUnfree = true;

      # Applied to every NixOS host automatically, so systems/x86_64-linux/*
      # don't each have to repeat the same enable-modules list.
      systems.modules.nixos = [ ./systems/common.nix ];

      # Snowfall Lib defaults `formatter` to alejandra — replace it with a
      # treefmt wrapper that runs nixfmt (RFC 166). Enables `nix fmt`
      # (and the pre-commit hook in .githooks/).
      outputs-builder = channels: {
        formatter = inputs.treefmt-nix.lib.mkWrapper channels.nixpkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };
      };
    };
}
