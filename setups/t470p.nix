{
  pkgs,
  dirImport,
  ...
}:
let
  homeDirectory = "/var/home/${username}";
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

    bat.enable = true;
    bottom.enable = true;
    bun.enable = true;
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
    niri.enable = true;
    nixfmt.enable = true;
    nushell.enable = true;

    opencode = {
      enable = true;
      plugins = {
        my-agents-local.enable = true;
        my-loaded-skills.enable = true;
        my-vcs-status.enable = true;
        with-claude.enable = true;
      };
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
      nerd-fonts.caskaydia-cove
    ];

    sessionPath = [
      "$HOME/.local/bin"
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
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash.enable = true;

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  nix = {
    package = pkgs.nix;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home.enableNixpkgsReleaseCheck = false;

  fonts.fontconfig.enable = true;

  gtk.enable = true;

  dconf.settings = {
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };
  };
}
