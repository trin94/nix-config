{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ffmpeg;
in
{

  options.myOS.programs.ffmpeg = with lib; {

    enable = mkEnableOption "ffmpeg";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ffmpeg_7-full # Complete, cross-platform solution to record, convert and stream audio and video
    ];

  };

}
