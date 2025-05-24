{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.delta;
in
{

  options.myOS.programs.delta = with lib; {

    enable = mkEnableOption "delta";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      delta
    ];

  };

}
