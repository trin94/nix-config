{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.dtrx;
in
{

  options.myOS.terminal.dtrx = with lib; {

    enable = mkEnableOption "dtrx";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      dtrx
    ];

  };

}
