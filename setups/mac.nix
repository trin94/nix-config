{
  pkgs,
  dirImport,
  ...
}:

let
  configLocation = "${homeDirectory}/.dotfiles";
  homeDirectory = "/Users/${username}";
  username = builtins.getEnv "USER";
in
{
  imports = dirImport {
    paths = [
      ./programs
    ];
  };

  myOS = {

    programs = {

      alacritty = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        fontSize = 16;
      };

      bat.enable = true;
      devenv.enable = false;
      dtrx.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fd.enable = true;

      git = {
        enable = false;
        configure = true;
        name = "Elias Mueller";
        email = builtins.getEnv "EMAIL";
      };

      fish = {
        enable = true;
        configLocation = configLocation;
        shellInit = ''
          fish_add_path ~/.nix-profile/bin
          fish_add_path /nix/var/nix/profiles/default/bin
          fish_add_path ~/Library/Application Support/JetBrains/Toolbox/scripts
        '';
      };

      helix.enable = true;
      jq.enable = true;
      just.enable = true;

      kubernetes.enable = true;
      nh.enable = true;
      nixfmt.enable = true;
      nushell.enable = true;

      procs.enable = true;
      ripgrep.enable = true;
      sd.enable = true;
      tokei.enable = true;

      yazi.enable = true;
      yq.enable = true;

      zed = {
        enable = false;
        configure = true;
      };
    };
  };

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    targets = {
      fish.enable = true;
      k9s.enable = true;
      starship.enable = true;
    };
  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # Add user packages here
    ];

    sessionPath = [
      # "$HOME/.local/bin"
      # "$HOME/.cargo/bin"
      # "$HOME/go/bin"
    ];

    sessionVariables = { };

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
