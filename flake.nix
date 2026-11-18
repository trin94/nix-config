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

    meridian = {
      url = "github:rynfar/meridian/meridian-v1.79.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      # 0.2.3 strips Pi's docs block whole; the 0.2.2 pin leaves a stray <docs> tag.
      inputs.meridian-plugin-pi-scrub.url = "github:rynfar/meridian-plugin-pi-scrub/09c4b53a0dc0194e037a0953a1d5ee321a6349c3";
    };

    mattpocock-skills = {
      url = "github:mattpocock/skills/v1.3.1";
      flake = false;
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      stylix,
      ...
    }:

    let
      dirImport = (import ./setups/lib/dirImport.nix { inherit (nixpkgs) lib; }).dirImport;
    in

    {

      # Consumers pass their own `inputs`, so the modules reach this flake's inputs as
      # `nixConfigInputs`. Module args can't feed `imports`, so input modules are imported here.
      homeModules.programs = {
        imports = [
          inputs.nixvim.homeModules.nixvim
          inputs.meridian.homeModules.default
        ]
        ++ dirImport { paths = [ ./setups/programs ]; };
        _module.args.nixConfigInputs = inputs;
      };

      homeConfigurations = {

        "elias@fedora" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            stylix.homeModules.stylix
            self.homeModules.programs
            ./setups/fedora.nix
          ];
        };

        "elias@t470p" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            stylix.homeModules.stylix
            self.homeModules.programs
            ./setups/t470p.nix
          ];
        };

        "elias@p16gen2" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };

          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          modules = [
            stylix.homeModules.stylix
            self.homeModules.programs
            ./setups/p16gen2.nix
          ];
        };

        "elias@mac" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            pkgs = import nixpkgs {
              system = "aarch64-darwin"; # or "x86_64-darwin" for Intel
            };
          };

          pkgs = nixpkgs.legacyPackages."aarch64-darwin";

          modules = [
            stylix.homeModules.stylix
            self.homeModules.programs
            ./setups/mac.nix
          ];
        };

      };

    };
}
