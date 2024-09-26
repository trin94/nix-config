{
  config,
  pkgs,
  userConfig,
  ...
}:

{

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
      nup = {
        description = "Update system packages and home packages";
        body = "nup-system && nup-user";
      };

      nup-user = {
        description = "Update user packages";
        body = "home-manager switch --flake ${userConfig.configLocation}#${userConfig.username}@${userConfig.hostname}";
      };

      nup-system = {
        description = "Update system packages";
        body = "sudo nixos-rebuild switch --flake ${userConfig.configLocation}#${userConfig.hostname}";
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

}
