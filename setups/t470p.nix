{
  config,
  pkgs,
  lib,
  pkgsStable,
  inputs,
  dirImport,
  ...
}:
let
  configLocation = "${homeDirectory}/.dotfiles";
  homeDirectory = "/home/${username}";
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
      dtrx.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      ffmpeg.enable = true;

      fish = {
        enable = true;
        configLocation = configLocation;
      };

      git = {
        enable = false;
        configure = true;
        name = "Elias Mueller";
        email = "elias.mr1@gmail.com";
      };

      jq.enable = true;
      just.enable = true;
      libwebp.enable = true;
      nh.enable = true;
      nixfmt.enable = true;
      nushell.enable = true;
      poetry.enable = true;
      procs.enable = true;
      ripgrep.enable = true;
      ssh.enable = true;
      tokei.enable = true;
      vim.enable = true;
      yq.enable = true;

      zed = {
        enable = false;
        configure = true;
      };

    };

  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin" # rust binaries
      "$HOME/go" # GOPATH
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  fonts.fontconfig.enable = true;
}
