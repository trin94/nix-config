{
  config,
  pkgs,
  pkgsStable,
  configVars,
  inputs,
  dirImport,
  ...
}:

{

  imports = dirImport {
    paths = [
      ../common/desktops
      ../common/programs
      ../common/fonts.nix
    ];
  };

  myOS = {

    desktop = {

      gnome = {
        configure = true;
        wallpaper = "${configVars.configLocation}/resources/wallpaper/space.jpg";
      };

    };

    terminal = {

      bat.enable = true;
      dtrx.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      ffmpeg.enable = true;

      fish = {
        enable = true;
        username = configVars.username;
        hostname = "fedora";
        configLocation = configVars.configLocation;
        addUpdateHostFunction = false;
      };

      git = {
        enable = true;
        name = "Elias Mueller";
        email = "elias.mr1@gmail.com";
        signCommits = false;
      };

      jq.enable = true;
      just.enable = true;
      nh.enable = true;
      nixfmt.enable = true;
      procs.enable = true;
      ripgrep.enable = true;
      ssh.enable = true;
      tokei.enable = true;
      vim.enable = true;
      yq.enable = true;

    };

    graphical = {

      # alacritty.enable = true;
      # amberol.enable = true;
      # dconf-editor.enable = true;
      # discord.enable = true;
      # eartag.enable = true;
      # hexchat.enable = true;
      jetbrains-toolbox.enable = true;
      # mpv.enable = true;
      # telegram-desktop.enable = true;

    };

  };

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";

    packages = with pkgs; [
      mediawriter # Tool to write images files to portable media
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

  nixpkgs.config.allowUnfree = true;

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
