{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.duckdb;
in
{

  options.myOS.programs.duckdb = with lib; {

    enable = mkEnableOption "duckdb";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      duckdb
    ];

  };

}
