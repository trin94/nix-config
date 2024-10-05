{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.amberol;
in
{

  options.myOS.graphical.amberol = with lib; {

    enable = mkEnableOption "amberol";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      amberol
    ];

  };

}
