{
  config,
  pkgs,
  lib,
  ...
}:

{

  home.packages = with pkgs; [
    git # Distributed version control system
    git-credential-manager # Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services
  ];

  programs.git = {
    enable = true;
    userName = "Elias Mueller";
    userEmail = "elias.mr1@gmail.com";

    extraConfig = {
      credential = {
        helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      };
      init = {
        defaultBranch = "main";
      };
      core = {
        autocrlf = "input";
      };
    };
  };

}
