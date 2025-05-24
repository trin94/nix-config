{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.dtrx;
in
{

  options.myOS.programs.dtrx = with lib; {

    enable = mkEnableOption "dtrx";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      dtrx
    ];

  };

}
