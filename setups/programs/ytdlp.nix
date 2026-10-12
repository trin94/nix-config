{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ytdlp;
in
{

  options.myOS.programs.ytdlp = with lib; {

    enable = mkEnableOption "ytdlp";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    ];

    programs.fish.functions = {
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
