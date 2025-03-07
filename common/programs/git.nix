{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.git;
in
{

  options.myOS.programs.git = with lib; {

    enable = mkEnableOption "git";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

    name = mkOption {
      type = types.str;
    };

    email = mkOption {
      type = types.str;
    };

  };

  config = {

    home.packages = lib.mkIf cfg.enable (
      with pkgs;
      [
        git # Distributed version control system
        git-credential-manager # Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services
      ]
    );

    programs.git.enable = lib.mkIf cfg.enable true;

    home.file = lib.mkIf cfg.configure {
      ".config/git/config".text = ''
        [core]
            autocrlf = "input"
            pager = "delta"

        [credential]
            helper = "git-credential-libsecret"

        [delta]
            dark = true
            hyperlinks = true
            navigate = true
            side-by-side = true

        [init]
            defaultBranch = "main"

        [interactive]
            diffFilter = "delta --color-only"

        [merge]
            conflictstyle = "zdiff3"

        [user]
            email = "${cfg.email}"
            name = "${cfg.name}"

      '';
    };
  };

}
