{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.git;
in
{

  options.myOS.git = with lib; {

    enable = mkEnableOption "git";

    name = mkOption {
      type = types.string;
    };

    email = mkOption {
      type = types.string;
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
        gpg = {
          format = "ssh";
        };

        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };

        commit = {
          gpgsign = true;
        };

        user = {
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHd9tRbMZVCnF7obsvrgq1LSSL4xBm8fpQnwu0SKNUdg";
        };
      };
    };
  };

}
