{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.poetry;
in
{

  options.myOS.terminal.poetry = with lib; {

    enable = mkEnableOption "poetry";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      poetry # Python dependency management and packaging made easy

    ];

  };

}
