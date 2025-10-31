{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.sd;
in
{

  options.myOS.programs.sd = with lib; {

    enable = mkEnableOption "sd";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      sd
    ];

  };

}
