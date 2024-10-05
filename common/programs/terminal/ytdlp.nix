{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.ytdlp;
in
{

  options.myOS.terminal.ytdlp = with lib; {

    enable = mkEnableOption "ytdlp";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    ];

  };

}
