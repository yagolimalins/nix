{
  description = "Yago's multi-host NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:

    let
      sudo_user = builtins.getEnv "SUDO_USER";
      user = builtins.getEnv "USER";
      username = if sudo_user != "" then sudo_user else user;
      system = "x86_64-linux";

      hostDirs = builtins.attrNames (builtins.readDir ./hosts);

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit username hostName;
          };

          modules = [
            { nixpkgs.config.allowUnfree = true; }
            ./configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.${username} = import ./home.nix;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = null;
              home-manager.extraSpecialArgs = {
                inherit username hostName;
              };

            }
          ];
        };

    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (hostName: {
          name = hostName;
          value = mkHost hostName;
        }) hostDirs
      );
    };
}
