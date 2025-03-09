{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.biome;
in
{

  options.myOS.programs.biome = with lib; {

    enable = mkEnableOption "biome";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      biome
    ];

  };

}
