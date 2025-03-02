{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.tokei;
in
{

  options.myOS.programs.tokei = with lib; {

    enable = mkEnableOption "tokei";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      tokei # A program that allows you to count your code, quickly
    ];

  };

}
