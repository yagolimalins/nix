{
  description = "Yago's multi-host NixOS flake";

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

      snowfall.namespace = "yago";

      # Passed straight to nixpkgs when Snowfall Lib instantiates `pkgs` —
      # do this here instead of a `nixpkgs.config` module (that option
      # conflicts with the already-instantiated `pkgs` Snowfall provides).
      channels-config.allowUnfree = true;
    };
}
