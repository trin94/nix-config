{
  pkgs,
  dirImport,
  ...
}:
let
  homeDirectory = "/home/${username}";
  username = "elias";

  # kdePackages.breeze drags in a 1.8 GiB Qt closure; the source tarball ships the cursors prebuilt.
  breezeCursors = pkgs.runCommand "breeze-cursors-${pkgs.kdePackages.breeze.version}" { } ''
    tar xf ${pkgs.kdePackages.breeze.src} --wildcards '*/cursors/Breeze/Breeze'
    mkdir -p $out/share/icons
    cp -r */cursors/Breeze/Breeze $out/share/icons/breeze_cursors
  '';
in
{

  imports = dirImport {
    paths = [
      ./programs
    ];
  };

  myOS.programs = {

    alacritty.enable = true;

    ai = {
      claude.enable = true;
      opencode.enable = true;
      pi.enable = true;
    };

    bat.enable = true;
    bottom.enable = true;

    chromium = {
      enable = false;
      configure = true;
    };

    cosign.enable = true;
    devenv.enable = true;
    dtrx.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    ffmpeg.enable = true;

    fish.enable = true;

    git = {
      enable = false;
      configure = true;
      name = "Elias Mueller";
      email = "mail@eliasmueller.online";
    };

    helix.enable = false;
    herdr.enable = true;
    hugo.enable = true;
    jq.enable = true;
    just.enable = true;

    kitty = {
      enable = true;
      enableCsd = false;
      useMonoLisaFont = true;
      followSystemTheme = true;
    };

    libwebp.enable = true;

    mpv = {
      enable = false;
      configure = true;
    };

    nh.enable = true;
    niri.enable = true;
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

    umbriel = {
      enable = false;
      configure = true;
      settings = (import ./umbriel/outputs.nix) // {
        # The session service starts Noctalia; avoid launching a second instance.
        general.autostart = [ ];
      };
    };

    vim.enable = true;
    yq.enable = true;
    yazi.enable = true;
    ytdlp.enable = true;

    zed = {
      enable = false;
      configure = false;
    };
  };

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    targets = {
      fontconfig.enable = true;

      bat.enable = true;
      k9s.enable = true;
      lazygit.enable = true;
      nixvim.enable = true;
      starship.enable = true;
      yazi.enable = true;
    };

    fonts = {
      monospace.name = "MonoLisaCode Variable";
      sansSerif.name = "MonoLisaText Variable";
      serif.name = "MonoLisaText Variable";
    };

  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      gh
      nodejs
      bun
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.bun/bin"
      "$HOME/.cargo/bin" # rust binaries
      "$HOME/go" # GOPATH
    ];

    pointerCursor = {
      enable = true;
      package = breezeCursors;
      name = "breeze_cursors";
      size = 22;
      gtk.enable = true;
    };

    sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
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

  fonts.fontconfig.enable = true;

  gtk.enable = true;
}
