{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.taplo;
in
{

  options.myOS.programs.taplo = with lib; {

    enable = mkEnableOption "taplo";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      taplo
    ];

  };

}
