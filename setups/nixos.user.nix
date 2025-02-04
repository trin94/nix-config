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
      ../common/stylix.nix
    ];
  };

  myOS = {

    stylix = {
      configure = true;
      wallpaper = "${configVars.configLocation}/resources/wallpaper/space.jpg";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      dark-theme = false;
    };

    desktop = {

      gnome = {
        configure = true;
        terminalApp = "ghostty";
        dockApps = [
          "org.gnome.Nautilus.desktop"
          "dev.zed.Zed.desktop"
          "firefox.desktop"
          "jetbrains-toolbox.desktop"
          "org.telegram.desktop.desktop"
          "com.teamspeak.TeamSpeak3.desktop"
          "1password.desktop"
        ];
      };

      hyprland = {
        configure = false;
      };

    };

    terminal = {

      bat.enable = true;
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
        enable = true;
        name = "Elias Mueller";
        email = "elias.mr1@gmail.com";
        signCommits = true;
      };

      hugo.enable = true;
      java.enable = true;
      jq.enable = true;
      just.enable = true;
      libwebp.enable = true;
      nh.enable = true;
      treefmt.enable = true;
      nushell.enable = true;
      poetry.enable = true;
      procs.enable = true;
      python.enable = true;
      ripgrep.enable = true;
      ruff.enable = true;
      ssh.enable = true;
      tokei.enable = true;
      vim.enable = true;
      yq.enable = true;
      ytdlp.enable = true;

    };

    graphical = {

      alacritty.enable = false;
      ghostty.enable = true;
      amberol.enable = true;
      dconf-editor.enable = true;
      discord.enable = true;
      eartag.enable = true;
      hexchat.enable = true;
      jetbrains-toolbox.enable = true;
      mpv.enable = true;
      telegram-desktop.enable = true;
      zed.enable = true;

    };

  };

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";

    packages = with pkgs; [
      efibootmgr # A Linux user-space application to modify the Intel Extensible Firmware Interface (EFI) Boot Manager
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
