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
  isBatmanInstalled = hasHomeManagerPackage "batman";
  isRipgrepInstalled = hasHomeManagerPackage "ripgrep";
  isDeltaInstalled = hasHomeManagerPackage "delta";
  isDiffSoFancyInstalled = hasHomeManagerPackage "diff-so-fancy";
in
{

  options.myOS.programs.fish = with lib; {

    enable = mkEnableOption "fish";

    configLocation = mkOption {
      type = types.str;
    };

    shellInit = mkOption {
      type = types.lines;
      default = "";
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fish # Smart and user-friendly command line shell
      starship # A minimal, blazing fast, and extremely customizable prompt for any shell
      fzf
    ];

    programs.starship = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        container = {
          symbol = "📦";
          style = "bold blue";
          format = "[$symbol \\[$name\\]]($style) ";
        };
      };
    };

    programs.fish = {
      enable = true;

      plugins = [
        {
          name = "fzf-fish"; # Augment your fish command line with fzf key bindings
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];

      interactiveShellInit = ''
        set fish_greeting

        fzf_configure_bindings --variables=

        printf '\e[36mfzf:\e[0m  \e[2mC-r\e[0m history   \e[2mC-A-f\e[0m dir   \e[2mC-A-l\e[0m log   \e[2mC-A-s\e[0m status   \e[2mC-A-p\e[0m ps\n'

        set fzf_fd_opts --hidden
        set fzf_git_log_format '%C(bold blue)%h%C(reset) %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %s  %C(dim normal)[%an]%C(reset)'
        set fzf_history_time_format "%Y-%m-%d %H:%M"
      ''
      + lib.optionalString isEzaInstalled ''

        set fzf_preview_dir_cmd eza --all --color=always --group-directories-first --icons=never
      ''
      + lib.optionalString isDiffSoFancyInstalled ''

        set fzf_diff_highlighter diff-so-fancy
      '';

      shellInit = cfg.shellInit;

      shellAliases =
        let
          ezaArgs = "--group-directories-first --color=always --icons=never --hyperlink";
        in
        {
          "ls" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long";
          "ll" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long --all";
          "lt" = lib.mkIf isEzaInstalled "eza ${ezaArgs} --long --tree";
          "la" = "ll";

          "man" = lib.mkIf isBatmanInstalled "batman";

          "k" = "kubectl";
          "kctx" = "kubectx";
          "kns" = "kubens";
          "qmltestrunner" = "qmltestrunner-qt6";
          "pre-commit" = "prek";
        };

      functions = {

        as-branchname = {
          description = "Transform a string into a branch name";
          body = ''
            set s (string join " " -- $argv)
            set s (string replace -ra '[^[:alnum:]]+' '-' -- $s)
            set s (string trim -c '-' -- $s)   # removes leading/trailing dashes
            string lower -- $s
          '';
        };

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
