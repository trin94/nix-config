{
  description = "frupp.nix's nix configuration :)";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      stylix,
      nixos-hardware,
      ...
    }:

    let
      inherit (nixpkgs) lib;
      inherit (self) outputs;

      dirImport = (import ./setups/lib/dirImport.nix { inherit (nixpkgs) lib; }).dirImport;

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

      nixosConfigurations = {

        t470p = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs outputs;
          };

          modules = [
            # nixos-hardware has no t470p module. Do not substitute the t470s,
            # it is a different machine.
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            # The dGPU is present but unwanted, this blacklists and powers it down.
            nixos-hardware.nixosModules.common-gpu-nvidia-disable

            ./setups/t470p.os.nix
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
            stylix.homeModules.stylix
            ./setups/fedora.nix
          ];
        };

        "elias@t470p" = home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs pkgs;

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
            stylix.homeModules.stylix
            ./setups/p16gen2.nix
          ];
        };

        "elias@mac" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraSpecialArgs // {
            pkgs = import nixpkgs {
              system = "aarch64-darwin"; # or "x86_64-darwin" for Intel
            };
          };

          pkgs = nixpkgs.legacyPackages."aarch64-darwin";

          modules = [
            stylix.homeModules.stylix
            ./setups/mac.nix
          ];
        };

      };

    };
}
