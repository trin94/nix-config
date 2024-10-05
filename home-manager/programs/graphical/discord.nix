{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.discord;
in
{

  options.myOS.graphical.discord = with lib; {

    enable = mkEnableOption "discord";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      discord
    ];

  };

}
