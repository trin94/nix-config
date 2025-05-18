{
  description = "frupp.nix's nix configuration :)";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:

    let
      inherit (nixpkgs) lib;
      inherit (self) outputs;

      dirImport = (import ./common/lib/dirImport.nix { inherit (nixpkgs) lib; }).dirImport;

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        inherit
          inputs
          dirImport
          pkgs
          ;
      };
    in

    {

      homeConfigurations = {

        "elias@fedora" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/fedora.nix
          ];
        };

        "elias@container-nix-box" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            ./setups/container-nix-box.nix
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
            ./setups/t470p.nix
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
            ./setups/p16gen2.nix
          ];
        };

      };

    };
}
