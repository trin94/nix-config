{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.delta;
in
{

  options.myOS.terminal.delta = with lib; {

    enable = mkEnableOption "delta";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      delta
    ];

  };

}
