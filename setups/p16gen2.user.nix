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
      ../common/desktops
      ../common/programs
      ../common/fonts.nix
    ];
  };

  myOS = {

    desktop = {

      gnome = {
        configure = true;
        terminalApp = "ptyxis -x fish";
        dockApps = [
          "org.gnome.Nautilus.desktop"
          "dev.zed.Zed.desktop"
          "firefox.desktop"
          "jetbrains-toolbox.desktop"
          "jetbrains-idea.desktop"
          "jetbrains-pycharm.desktop"
          "com.slack.Slack.desktop"
          "1password.desktop"
        ];
      };

    };

    terminal = {

      bat.enable = true;
      delta.enable = true;
      dtrx.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      # ffmpeg.enable = true;

      fish = {
        enable = true;
        configLocation = configVars.configLocation;
      };

      git = {
        enable = true;
        name = "Elias Mueller";
        email = builtins.getEnv "EMAIL";
        signCommits = false;
      };

      # hugo.enable = true;
      jq.enable = true;
      just.enable = true;
      # libwebp.enable = true;
      nh.enable = true;
      treefmt.enable = true;
      nushell.enable = true;

      poetry = {
        enable = false;
        configure = true;
      };

      procs.enable = true;
      ripgrep.enable = true;
      ruff.enable = true;
      # ssh.enable = true;
      tokei.enable = true;
      # uv.enable = true;
      vim.enable = true;
      yq.enable = true;
      # ytdlp.enable = true;

    };

    graphical = {

      ghostty.enable = false;
      # amberol.enable = true;
      # dconf-editor.enable = true;
      # discord.enable = true;
      # eartag.enable = true;
      # hexchat.enable = true;
      # jetbrains-toolbox.enable = true;
      # mpv.enable = true;
      # telegram-desktop.enable = true;
      zed.enable = true;
    };

  };

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";

    packages = with pkgs; [
      azure-storage-azcopy
      nixd
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
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
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  targets.genericLinux.enable = true;
  # xdg.mime.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  fonts.fontconfig.enable = true;
}
