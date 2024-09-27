{
  description = "My flake"; # You can change this to whatever

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }:

    let
      commonConfig = {
        configLocation = "/home/elias/.dotfiles";
        username = "elias";
        timezone = "Europe/Berlin";
        defaultLocale = "en_US.UTF-8";
        extraLocale = "de_DE.UTF-8";
        keyboardLayout = "de+us";
      };
    in

    {

      # This is the section of the `flake.nix` that is responsible for importing and configuring the `configuration.nix`
      nixosConfigurations = {
        nixos =
          let
            systemConfig = {
              hostname = "nixos";
            };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              # `inherit` is used to pass the variables set in the above "let" statement into our configuration.nix file below
              inherit inputs;
              userConfig = nixpkgs.lib.recursiveUpdate commonConfig systemConfig;
              pkgs-stable = import nixpkgs-stable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            # Our main nixos configuration file
            # This is the file where we compartmentalize the changes we want to make on a system level
            modules = [ ./system/nixos/configuration.nix ];
          };
      };

      # home-manager configuration entrypoint
      # Available through 'home-manager --flake .
      homeConfigurations = {

        "elias@nixos" =
          let
            systemConfig = {
              hostname = "nixos"; # required
              wallpaperPathLight = "${commonConfig.configLocation}/data/wallpaper/space.jpg"; # optional
              wallpaperPathDark = "${commonConfig.configLocation}/data/wallpaper/space.jpg"; # optional
            };
          in
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages."x86_64-linux"; # Home-manager requires 'pkgs' instance
            extraSpecialArgs = {
              # `inherit` is used to pass the variables set in the above "let" statement into our home.nix file below
              inherit inputs;
              userConfig = nixpkgs.lib.recursiveUpdate commonConfig systemConfig;
              pkgs-stable = import nixpkgs-stable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            # > Our main home-manager configuration file <
            modules = [ ./home-manager/${commonConfig.username}/home.nix ];
          };

      };

    };
}
