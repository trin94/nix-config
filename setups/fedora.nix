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
  defaultLocale = "en_US.UTF-8";
  extraLocale = "de_DE.UTF-8";
  homeDirectory = "/home/${username}";
  keyboardLayout = "de+us";
  timezone = "Europe/Berlin";
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
      delta.enable = true;
      devenv.enable = true;
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

      hugo.enable = true;
      jq.enable = true;
      just.enable = true;
      libwebp.enable = true;

      mpv = {
        enable = false;
        configure = true;
      };

      nh.enable = true;
      nixfmt.enable = true;
      nushell.enable = true;
      poetry.enable = true;
      pre-commit.enable = true;
      procs.enable = true;
      ripgrep.enable = true;
      ssh.enable = true;
      tokei.enable = true;
      uv.enable = false;
      vim.enable = true;
      yq.enable = true;
      ytdlp.enable = true;

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
