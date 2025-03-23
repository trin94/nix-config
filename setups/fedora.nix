{
  config,
  pkgs,
  lib,
  pkgsStable,
  configVars,
  inputs,
  dirImport,
  ...
}:

{

  imports = dirImport {
    paths = [
      ../common/programs
      ../common/fonts.nix
      ../common/gnome.nix
    ];
  };

  myOS = {

    desktop = {

      gnome = {
        configure = true;
        terminalApp = "ptyxis -s";
        dockApps = [
          "org.gnome.Nautilus.desktop"
          "dev.zed.Zed.desktop"
          "org.mozilla.firefox.desktop"
          "jetbrains-toolbox.desktop"
          "jetbrains-idea.desktop"
          "jetbrains-pycharm.desktop"
          "org.telegram.desktop.desktop"
          "com.teamspeak.TeamSpeak3.desktop"
          "1password.desktop"
        ];
      };

    };

    programs = {

      bat.enable = true;
      biome.enable = true;
      delta.enable = true;
      dtrx.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      ffmpeg.enable = true;

      fish = {
        enable = true;
        configLocation = configVars.configLocation;
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
      jsonfmt.enable = true;
      libwebp.enable = true;
      mdformat.enable = true;
      nh.enable = true;
      nixfmt.enable = true;
      nushell.enable = true;
      poetry.enable = true;
      pre-commit.enable = true;
      procs.enable = true;
      ripgrep.enable = true;
      ruff.enable = true;
      ssh.enable = true;
      taplo.enable = true;
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
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";

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
