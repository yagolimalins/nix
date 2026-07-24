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
    };
}
