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

  imports = dirImport {
    paths = [
      ../programs
      ../gnome-config.nix
      ../fonts.nix
    ];
  };

  myOS = {

    eza.enable = true;

    fish = {
      enable = true;
      username = configVars.username;
      hostname = "nixos";
      configLocation = configVars.configLocation;
    };

  };

  home.username = configVars.username;
  home.homeDirectory = "/home/${configVars.username}";

  home.packages = with pkgs; [

    # Terminal programs without special configuration
    bat # A cat(1) clone with syntax highlighting and Git integration
    dtrx # Do The Right Extraction: A tool for taking the hassle out of extracting archives
    fd # A simple, fast and user-friendly alternative to find
    ffmpeg_7-full # Complete, cross-platform solution to record, convert and stream audio and video
    hugo # A fast and modern static website engine
    jdk # Open-source Java Development Kit / Latest LTS
    jq # A lightweight and flexible command-line JSON processor
    just # A handy way to save and run project-specific commands
    maven # Build automation tool (used primarily for Java projects)
    nh # Yet another nix cli helper
    nixfmt-rfc-style # Official formatter for Nix code
    poetry # Python dependency management and packaging made easy
    procs # A modern replacement for ps written in Rust
    python312 # A high-level dynamically-typed programming language
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    ruff # Extremely fast Python linter
    # teamspeak_client # TeamSpeak voice communication tool
    tokei # A program that allows you to count your code, quickly
    yq-go # Portable command-line YAML processor
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)

    kdePackages.qtsvg # Cross-platform application framework for C++
    python312Packages.mpv # Python interface to the mpv media player
    python312Packages.pyside6 # Python bindings for Qt
    python312Packages.shiboken6 # Generator for the pyside6 Qt bindings

    # Graphical programs without special configuration
    # _1password # 1Password command-line tool
    # _1password-gui # Multi-platform password manager
    amberol # A small and simple sound and music player
    discord # All-in-one cross-platform voice and text chat for gamers
    eartag # Simple music tag editor
    hexchat # A popular and easy to use graphical IRC (chat) client
    jetbrains-toolbox # Jetbrains Toolbox
    telegram-desktop # Telegram Desktop messaging app
    dconf-editor # GSettings editor for GNOME

    # python312Packages.pyside6

  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;
}
