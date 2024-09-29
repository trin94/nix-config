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

      configVars = import ./vars { inherit inputs lib; };

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
            ./hosts/nixos
          ];
        };

      };

      homeConfigurations = {

        "elias@nixos" = home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;

          pkgs = nixpkgs.legacyPackages."x86_64-linux"; # Home-manager requires 'pkgs' instance

          modules = [
            ./home-manager/${configVars.username}/home.nix
          ];
        };

      };

    };
}
