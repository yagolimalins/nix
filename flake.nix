{
  description = "Multi-host NixOS flake (Snowfall Lib + Home Manager)";
  # Snowfall packages/ = custom derivations (flake outputs).
  # mine.packages = HM user package groups (modules/home/packages/).

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # Options/lib live under mine.* — not tied to a username.
      snowfall.namespace = "mine";

      # Prefer this over nixpkgs.config modules (conflicts with Snowfall's pkgs).
      channels-config.allowUnfree = true;

      overlays = [ inputs.rust-overlay.overlays.default ];

      systems.modules.nixos = [
        inputs.lanzaboote.nixosModules.lanzaboote
        ./systems/common.nix
      ];
      homes.modules = [ ./homes/common.nix ];

      # Replace Snowfall's default alejandra formatter.
      outputs-builder = channels: {
        formatter = inputs.treefmt-nix.lib.mkWrapper channels.nixpkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };
      };
    };
}
