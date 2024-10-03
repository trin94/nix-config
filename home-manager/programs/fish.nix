{
  config,
  pkgs,
  lib,
  configVars,
  ...
}:
let
  cfg = config.customizeFish;
in
with pkgs.lib;
{

  options.customizeFish = {

    addUpdateHostFunction = mkOption {
      default = true;
      type = with types; bool;
    };

    addUpdateHomeFunction = mkOption {
      default = true;
      type = with types; bool;
    };

    configLocation = mkOption {
      type = with types; string;
    };

    username = mkOption {
      type = with types; string;
    };

    hostname = mkOption {
      type = with types; string;
    };

  };

  config = {

    home.packages = with pkgs; [
      fish # Smart and user-friendly command line shell
      starship # A minimal, blazing fast, and extremely customizable prompt for any shell
    ];

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting
      '';

      shellAliases = {
        "shutdown" = "sudo shutdown now";
        "restart" = "sudo restart now";

        "dnf" = "dnf -C";
        "k" = "kubectl";
        "kctx" = "kubectx";
        "kns" = "kubens";
        "qmltestrunner" = "qmltestrunner-qt6";

        "ll" = "lsd -alA";
        "ls" = "lsd -l";
        "lt" = "lsd --tree";
      };

      functions = {

        nup = mkIf (cfg.addUpdateHostFunction || cfg.addUpdateHomeFunction) {
          description =
            if (cfg.addUpdateHostFunction && cfg.addUpdateHomeFunction) then
              "Update system packages and home packages"
            else if cfg.addUpdateHostFunction then
              "Update system packages"
            else
              "Update home packages";
          body =
            if (cfg.addUpdateHostFunction && cfg.addUpdateHomeFunction) then
              "nup-system && nup-user"
            else if cfg.addUpdateHostFunction then
              "nup-system"
            else
              "nup-user";
        };

        nup-user = mkIf cfg.addUpdateHomeFunction {
          description = "Update user packages";
          body = "nh home switch --update --configuration ${cfg.username}@${cfg.hostname} ${cfg.configLocation}";
        };

        nup-system = mkIf cfg.addUpdateHostFunction {
          description = "Update system packages";
          body = "nh os switch --update --hostname ${cfg.hostname} ${cfg.configLocation}";
        };

        envpp = {
          description = "Pretty print environment variables";
          body = ''
            env | sort | sed 's/=/%/' | column \
                --table \
                --separator '%' \
                --output-width 150 \
                --table-noheadings \
                --table-columns C1,C2 \
                --table-wrap C2'';
        };

        ytd = {
          description = "Download YT videos";
          body = ''
            yt-dlp \
                --format bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best \
                --output '%(upload_date)s - %(channel)s - %(id)s - %(title)s.%(ext)s' \
                --sponsorblock-remove "all" \
                --geo-bypass \
                --sub-langs 'all' \
                --embed-subs \
                --embed-metadata \
                --convert-subs 'srt' \
                -- $argv
          '';
        };

      };

    };
  };

}
