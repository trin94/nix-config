{ config, pkgs, ... }:
let
  username = "elias";
in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  imports = [
    # Import gnome configuration
    ../gnome-config.nix

    ../fonts.nix

    # Programs
    ../programs/1password.nix
    ../programs/alacritty.nix
    ../programs/bat.nix
    ../programs/dtrx.nix
    ../programs/fastfetch.nix
    ../programs/fd.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/hugo.nix
    ../programs/jq.nix
    ../programs/just.nix
    ../programs/lsd.nix
    ../programs/mpv.nix
    ../programs/procs.nix
    ../programs/ripgrep.nix
    ../programs/tokei.nix
    # ../programs/vim.nix
    ../programs/yq.nix
    ../programs/yt-dlp.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    nixfmt-rfc-style # Official formatter for Nix code

    # amberol # --FLATPAK-- # A small and simple sound and music player
    # discord # All-in-one cross-platform voice and text chat for gamers
    # eartag # Simple music tag editor
    # google-chrome # Freeware web browser developed by Google
    # teamspeak_client # --FLATPAK-- # The TeamSpeak voice communication tool
    # hexchat # A popular and easy to use graphical IRC (chat) client
    # loupe # --FLATPAK-- # A simple image viewer application written with GTK4 and Rust
    # gnome-text-editor # --FLATPAK-- # A Text Editor for GNOME
    # snapshot --FLATPAK-- # Take pictures and videos on your computer, tablet, or phone
    # baobab # --DNF-- Graphical application to analyse disk usage in any GNOME environment
    # firefox-unwrapped # A web browser built from Firefox source tree
    # _1password # 1Password command-line tool
    # _1password-gui # Multi-platform password manager

    # python312 # A high-level dynamically-typed programming language
    # python312Packages.pyside6
    jetbrains-toolbox
    # poetry
    # ffmpeg_7-full
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
