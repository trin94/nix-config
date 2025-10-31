{
  config,
  pkgs,
  lib,
  inputs,
  dirImport,
  ...
}:

let
  configLocation = "${homeDirectory}/.dotfiles";
  homeDirectory = "/Users/${username}";
  username = "elias";
in
{
  imports = dirImport {
    paths = [
      ./programs
    ];
  };

  myOS = {
    programs = {
      bat.enable = true;
    };
  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # Add user packages here
    ];

    sessionPath = [
      # "$HOME/.local/bin"
      # "$HOME/.cargo/bin"
      # "$HOME/go/bin"
    ];

    sessionVariables = { };

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
