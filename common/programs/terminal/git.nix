{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.git;
in
{

  options.myOS.terminal.git = with lib; {

    enable = mkEnableOption "git";

    name = mkOption {
      type = types.str;
    };

    email = mkOption {
      type = types.str;
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      git # Distributed version control system
      git-credential-manager # Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services
    ];

    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;

      extraConfig = {

        credential = {
          helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        };

        init = {
          defaultBranch = "main";
        };

        core = {
          autocrlf = "input";
          pager = "delta";
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        delta = {
          navigate = true;
          dark = true;
          side-by-side = true;
          hyperlinks = true;
        };

        merge = {
          conflictstyle = "zdiff3";
        };

      };
    };
  };

}
