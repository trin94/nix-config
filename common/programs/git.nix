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
            autocrlf = input
            pager = delta
            preloadindex = true
            whitespace = trailing-space,space-before-tab

        [credential]
            helper = git-credential-libsecret

        [user]
            email = ${cfg.email}
            name = ${cfg.name}

        [init]
            defaultBranch = main

        [delta]
            dark = true
            hyperlinks = true
            navigate = true
            side-by-side = true

        [interactive]
            diffFilter = delta --color-only

        [merge]
            conflictstyle = zdiff3

        [rebase]
            autoStash = true
            missingCommitsCheck = warn

        [pull]
            default = current
            rebase = true
            ff = only

        [push]
            default = current
            autoSetupRemote = true
            followTags = true

        [status]
            short = true
            branch = true
            showStash = true
            showUntrackedFiles = all

        [branch]
            sort = -committerdate

        [tag]
            sort = -taggerdate

        [log]
            abbrevCommit = true
            graphColors = blue,yellow,cyan,magenta,green,red

        [alias]
            lg = log --all --graph --pretty=format:'%C(auto)%h%C(reset) %C(blue)%an%C(reset) %C(dim white)%ar%C(reset) %C(yellow)%d%C(reset)%n%s%n'

        [pager]
            branch = false
            tag = false

        [color "decorate"]
            HEAD = red
            branch = blue
            tag = yellow
            remoteBranch = magenta

        [color "branch"]
            current  = magenta
            local    = default
            remote   = yellow
            upstream = green
            plain    = blue

      '';
    };
  };

}
