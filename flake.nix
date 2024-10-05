{
  description = "frupp.nix's nix configuration :)";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgsStable = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };

    nixpkgsUnstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
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
          pkgsStable
          ;
      };

      extraSpecialArgs = {
        inherit
          inputs
          dirImport
          configVars
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

        "elias@nixos" = home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;

          pkgs = nixpkgs.legacyPackages."x86_64-linux"; # Home-manager requires 'pkgs' instance

          modules = [
            ./setups/nixos.user.nix
          ];
        };

      };

    };
}
