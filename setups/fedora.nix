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

  myOS.programs = {

    bat.enable = true;
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

    helix.enable = true;
    hugo.enable = true;
    jq.enable = true;
    just.enable = true;

    kitty = {
      enable = true;
      enableCsd = false;
    };

    libwebp.enable = true;

    mpv = {
      enable = false;
      configure = true;
    };

    nh.enable = true;
    nixfmt.enable = true;
    nushell.enable = true;

    poetry = {
      enable = false;
      configure = true;
    };

    procs.enable = true;
    ripgrep.enable = true;
    sd.enable = true;
    ssh.enable = true;
    slides.enable = true;

    tokei.enable = true;
    vim.enable = false;
    yq.enable = true;
    yazi.enable = true;
    ytdlp.enable = true;

    zed = {
      enable = false;
      configure = true;
    };
  };

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    targets = {
      fish.enable = true;
      helix.enable = true;
      k9s.enable = true;
      kitty.enable = true;
      nixvim.enable = true;
      starship.enable = true;
      tofi.enable = true;
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

    sessionVariables = {
      # SKIP = "sqlfluff-fix";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Make Home Manager work better on GNU/Linux distributions other than NixOS.
  targets.genericLinux.enable = true;
  # xdg.mime.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home.enableNixpkgsReleaseCheck = false;

  # Allow fontconfig to discover fonts and configurations installed through home.packages and nix-env.
  fonts.fontconfig.enable = true;
}
