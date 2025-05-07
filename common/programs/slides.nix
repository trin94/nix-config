{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.slides;
in
{

  options.myOS.programs.slides = with lib; {

    enable = mkEnableOption "slides";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      slides # Terminal based presentation tool
    ];

  };

}
