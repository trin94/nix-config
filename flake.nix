{
  description = "My flake"; # You can change this to whatever

  inputs = {

    stable = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs: # <- this `@inputs` will expose the block of code below, to the inputs that you set above.

    let
      system = "x86_64-linux";
      timezone = "Europe/Berlin";
      locale = "en_US.UTF-8";
    in

    {

      # This is the section of the `flake.nix` that is responsible for importing and configuring the `configuration.nix`
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # `inherit` is used to pass the variables set in the above "let" statement into our configuration.nix file below
            inherit inputs;
            inherit system;
            inherit timezone;
            inherit locale;
          };
          # Our main nixos configuration file
          # This is the file where we compartmentalize the changes we want to make on a system level
          modules = [ ./system/elias/configuration.nix ];
        };
      };

      # home-manager configuration entrypoint
      # Available through 'home-manager --flake .
      homeConfigurations = {

        "elias@nixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            # `inherit` is used to pass the variables set in the above "let" statement into our home.nix file below
            inherit inputs;
          };
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/elias/home.nix ];
        };

      };

    };
}
