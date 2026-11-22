{
  pkgs,
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

  myOS.programs = {

    agents.enable = true;

    bat.enable = true;
    bottom.enable = true;

    chromium = {
      enable = false;
      configure = true;
    };

    claude-code = {
      enable = true;
      plugins.my-sidebar.enable = true;
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
      credentialHelper = "libsecret";
    };

    herdr.enable = true;
    hugo.enable = true;
    imgdiff.enable = true;
    jq.enable = true;
    just.enable = true;

    kitty = {
      enable = true;
      enableCsd = false;
      useMonoLisaFont = true;
      followSystemTheme = true;
    };

    libwebp.enable = true;
    meridian.enable = true;

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
        herdr.enable = true;
        my-agents-local.enable = true;
        my-loaded-skills.enable = true;
        my-subagent-context.enable = true;
        my-vcs-status.enable = true;
        with-claude.enable = true;
      };
      permissions = [
        {
          action = "read";
          resource = "*.env";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*.env.*";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*.env.example";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "~/.agents/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "~/git/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "/nix/store/**";
          effect = "allow";
        }
        {
          action = "read";
          resource = "SKILL.md";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*/SKILL.md";
          effect = "deny";
        }
      ];
    };

    pi = {
      enable = true;
      extensions.herdr.enable = true;
    };

    procs.enable = true;
    ripgrep.enable = true;
    sd.enable = true;
    ssh.enable = true;
    slides.enable = true;

    tokei.enable = true;

    umbriel = {
      enable = true;
      settings = {
        input.touchpad.enabled = false;

        # Output names must match exactly; wildcards are unsupported.
        output."DP-3" = {
          mode = "3840x2160@240.000";
          scale = 1.25;
          transform = "normal";
          position = [
            0
            0
          ];
          # HDR selects its own 10-bit format; do not force 10-bit SDR here.
          hdr = "on";
          vrr = "fullscreen";
        };
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

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      forgejo-cli
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
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    extraOptions = ''
      !include ${homeDirectory}/.config/nix/access-tokens.conf
    '';
  };

  home.enableNixpkgsReleaseCheck = false;

  # MonoLisa lives in ~/.local/share/fonts and Noto Color Emoji ships with Fedora.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "MonoLisaCode Variable" ];
      sansSerif = [ "MonoLisaText Variable" ];
      serif = [ "MonoLisaText Variable" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  gtk.enable = true;

  dconf.settings = {
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };
  };
}
