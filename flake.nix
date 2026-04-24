{
  description = "Yago's multi-host NixOS flake";

  # ── Inputs ──────────────────────────────────────────────────────────────────
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # keep home-manager on the same nixpkgs
    };
  };

  # ── Outputs ─────────────────────────────────────────────────────────────────
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Resolve the real user even when the flake is built via sudo
      username =
        let sudo_user = builtins.getEnv "SUDO_USER";
        in if sudo_user != "" then sudo_user else builtins.getEnv "USER";

      # Every subdirectory under ./hosts is treated as a separate host
      hostNames = builtins.attrNames (builtins.readDir ./hosts);

      # Collect all .nix files in a host's directory, excluding
      # hardware-configuration.nix (loaded explicitly below so the
      # auto-generated file is never shadowed by host customisations).
      hostModules = hostName:
        let
          dir   = ./hosts/${hostName};
          files = builtins.attrNames (builtins.readDir dir);
        in
        map (f: dir + "/${f}") (
          builtins.filter
            (f: f != "hardware-configuration.nix" && nixpkgs.lib.hasSuffix ".nix" f)
            files
        );

      # Assemble a full NixOS configuration for a given host
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username hostName; };

        modules =
          # ── Shared base ───────────────────────────────────────────────────
          [ { nixpkgs.config.allowUnfree = true; }
            ./configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
          ]
          # ── Host-specific modules (all other .nix files in the host dir) ─
          ++ hostModules hostName
          # ── Home Manager ──────────────────────────────────────────────────
          ++ [ home-manager.nixosModules.home-manager
               { home-manager.users.${username}  = import ./home.nix;
                 home-manager.useUserPackages     = true;
                 home-manager.backupFileExtension = null;
                 home-manager.extraSpecialArgs    = { inherit username hostName; };
               }
             ];
      };

    in
    {
      # Build one NixOS configuration per host directory
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames mkHost;
    };
}
