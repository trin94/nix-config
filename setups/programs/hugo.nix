{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.hugo;
in
{

  options.myOS.programs.hugo = with lib; {

    enable = mkEnableOption "hugo";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      hugo
    ];

  };

}
