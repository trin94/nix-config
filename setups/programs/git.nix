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
      type = types.nullOr types.str;
      default = null;
    };

    credentialHelper = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    githubCli = mkOption {
      type = types.bool;
      default = true;
      description = "Install gh and use it as credential helper for github.com";
    };

  };

  config = {

    home.packages =
      lib.optional cfg.enable pkgs.git
      ++ lib.optional cfg.configure pkgs.lazygit
      ++ lib.optional (cfg.configure && cfg.githubCli) pkgs.gh;

    programs.lazygit = lib.mkIf cfg.configure {
      enable = true;
      settings = {
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
      ".config/git/ignore".text = ''
        **/.claude/settings.local.json
        /.scratch/
        *.local.md
      '';

      ".config/git/config".text = ''
        [core]
            autocrlf = input
            preloadindex = true
            whitespace = trailing-space,space-before-tab

        [credential]
            credentialStore = secretservice
            ${lib.optionalString (cfg.credentialHelper != null) "helper = ${cfg.credentialHelper}"}

        [credential "https://dev.azure.com"]
            credentialStore = secretservice

        ${lib.optionalString cfg.githubCli ''
          [credential "https://github.com"]
              helper =
              helper = !gh auth git-credential

          [credential "https://gist.github.com"]
              helper =
              helper = !gh auth git-credential
        ''}
        [user]
            ${lib.optionalString (cfg.email != null) "email = ${cfg.email}"}
            name = ${cfg.name}
            useConfigOnly = true

        [init]
            defaultBranch = main

        [commit]
            verbose = true

        [rerere]
            enabled = true

        [diff]
            algorithm = histogram

        [merge]
            conflictstyle = zdiff3

        [rebase]
            autoStash = true
            autoSquash = true
            missingCommitsCheck = warn

        [fetch]
            prune = true

        [pull]
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

        [include]
            path = "~/.config/git/private.conf"

      '';
    };
  };

}
