{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.hexchat;
in
{

  options.myOS.graphical.hexchat = with lib; {

    enable = mkEnableOption "hexchat";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      hexchat
    ];

  };

}
