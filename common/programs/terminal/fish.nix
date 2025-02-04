{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.fish;

  hasHomeManagerPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  isYtDlpInstalled = hasHomeManagerPackage "yt-dlp";
  isEzaInstalled = hasHomeManagerPackage "eza";
  isRipgrepInstalled = hasHomeManagerPackage "ripgrep";
  isDeltaInstalled = hasHomeManagerPackage "delta";
in
{

  options.myOS.terminal.fish = with lib; {

    enable = mkEnableOption "fish";

    configLocation = mkOption {
      type = types.str;
    };

    addUpdateHostFunction = mkOption {
      type = types.bool;
      default = true;
    };

    addUpdateHomeFunction = mkOption {
      type = types.bool;
      default = true;
    };

  };

  config = lib.mkIf cfg.enable {

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

      shellAliases =
        let
          ezaArgs = "--group-directories-first --color=always --icons=never --no-filesize";
        in
        {
          "ls" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long";
          "ll" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long --all";
          "lt" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long --tree";
          "la" = "ll";

          "k" = "kubectl";
          "kctx" = "kubectx";
          "kns" = "kubens";
          "qmltestrunner" = "qmltestrunner-qt6";
        };

      functions = {

        nup = lib.mkIf (cfg.addUpdateHostFunction || cfg.addUpdateHomeFunction) {
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

        nup-user = lib.mkIf cfg.addUpdateHomeFunction {
          description = "Update user packages";
          body = "just -f ${cfg.configLocation}/Justfile update-user";
        };

        nup-system = lib.mkIf cfg.addUpdateHostFunction {
          description = "Update system packages";
          body = "just -f ${cfg.configLocation}/Justfile update-system";
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

        ytd = lib.mkIf isYtDlpInstalled {
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
