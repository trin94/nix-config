{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.tokei;
in
{

  options.myOS.terminal.tokei = with lib; {

    enable = mkEnableOption "tokei";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      tokei # A program that allows you to count your code, quickly
    ];

  };

}
