{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.fish;

  hasHomeManagerPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  isYtDlpInstalled = hasHomeManagerPackage "yt-dlp";
  isEzaInstalled = hasHomeManagerPackage "eza";
  isRipgrepInstalled = hasHomeManagerPackage "ripgrep";
  isDeltaInstalled = hasHomeManagerPackage "delta";
in
{

  options.myOS.programs.fish = with lib; {

    enable = mkEnableOption "fish";

    configLocation = mkOption {
      type = types.str;
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

        nup = {
          description = "Update user packages";
          body = "just -f ${cfg.configLocation}/Justfile update";
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
