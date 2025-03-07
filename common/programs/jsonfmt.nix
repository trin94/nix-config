{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.jsonfmt;
in
{

  options.myOS.programs.jsonfmt = with lib; {

    enable = mkEnableOption "jsonfmt";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jsonfmt
    ];

  };

}
