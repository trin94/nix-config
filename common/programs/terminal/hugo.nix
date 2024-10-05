{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.hugo;
in
{

  options.myOS.terminal.hugo = with lib; {

    enable = mkEnableOption "hugo";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      hugo
    ];

  };

}
