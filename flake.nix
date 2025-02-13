{
  description = "frupp.nix's nix configuration :)";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgsUnstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgsStable = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgsStable,
      home-manager,
      ...
    }:

    let
      inherit (nixpkgs) lib;
      inherit (self) outputs;

      configVars = import ./common/vars.nix { inherit inputs lib; };
      dirImport = (import ./common/lib/dirImport.nix { inherit (nixpkgs) lib; }).dirImport;

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      pkgsStable = import nixpkgsStable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      specialArgs = {
        inherit
          inputs
          outputs
          configVars
          nixpkgs
          pkgs
          pkgsStable
          ;
      };

      extraSpecialArgs = {
        inherit
          inputs
          dirImport
          configVars
          pkgs
          pkgsStable
          ;
      };
    in

    {

      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            ./setups/nixos.system.nix
          ];
        };

      };

      homeConfigurations = {

        "elias@fedora" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/fedora.user.nix
          ];
        };

        "elias@t470p" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/t470p.user.nix
          ];
        };

        "elias@p16gen2" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/p16gen2.user.nix
          ];
        };

        "elias@nixos" = home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/nixos.user.nix
          ];
        };

      };

    };
}
