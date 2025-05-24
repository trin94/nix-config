{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.just;
in
{

  options.myOS.programs.just = with lib; {

    enable = mkEnableOption "just";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      just
    ];

  };

}
