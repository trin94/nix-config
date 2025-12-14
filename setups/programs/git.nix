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

    home.packages =
      if cfg.enable then
        with pkgs;
        [
          git
          lazygit
          difftastic
        ]
      else if cfg.configure then
        with pkgs;
        [
          lazygit
          difftastic
        ]
      else
        [ ];

    programs.git.enable = lib.mkIf cfg.enable true;

    programs.lazygit = lib.mkIf cfg.configure {
      enable = true;
      settings = {
        git.pagers = [
          {
            externalDiffCommand = "difft --color=always";
          }
        ];
        keybinding.universal = {
          undo = "u";
          redo = "U";
          nextBlock = "<c-n>";
          prevBlock = "<c-p>";
          prevBlock-alt = "<disabled>";
          nextBlock-alt = "<disabled>";
          scrollLeft = "<disabled>";
          scrollRight = "<disabled>";
          goInto = "l";
          return-alt1 = "h";
        };
      };
    };

    home.file = lib.mkIf cfg.configure {
      ".config/git/config".text = ''
        [core]
            autocrlf = input
            preloadindex = true
            whitespace = trailing-space,space-before-tab

        [credential]
            credentialStore = secretservice

        [credential "https://dev.azure.com"]
            credentialStore = secretservice

        [user]
            email = ${cfg.email}
            name = ${cfg.name}

        [init]
            defaultBranch = main

        [diff]
            external = difft

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
