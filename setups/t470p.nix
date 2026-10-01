{
  pkgs,
  dirImport,
  ...
}:
let
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

    alacritty.enable = true;

    bat.enable = true;
    bottom.enable = true;
    bun.enable = true;
    ai.claude.enable = true;
    devenv.enable = true;
    dtrx.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    ffmpeg.enable = true;

    fish.enable = true;

    git = {
      enable = true;
      configure = true;
      name = "Elias Mueller";
      email = "mail@eliasmueller.online";
    };

    hugo.enable = false;
    jetbrains-toolbox.enable = true;
    jq.enable = true;
    just.enable = true;

    kitty = {
      enable = true;
      enableCsd = false;
      followNoctaliaTheme = true;
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
    uv.enable = true;
    vim.enable = true;
    yq.enable = true;
    yazi.enable = true;
    ytdlp.enable = true;

    zed = {
      enable = false;
      configure = false;
    };
  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # myOS.programs.kitty only writes the config. On fedora and p16gen2 the
      # binary comes from dnf; on NixOS it has to come from nix.
      kitty
      nerd-fonts.caskaydia-cove
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin" # rust binaries
      "$HOME/go" # GOPATH
    ];

    sessionVariables = {
      MPVQC_LIBMPV = "${pkgs.mpv-unwrapped}/lib/libmpv.so";
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

  programs.bash.enable = true;

  xdg.mime.enable = true;

  home.enableNixpkgsReleaseCheck = false;

  fonts.fontconfig.enable = true;
}
