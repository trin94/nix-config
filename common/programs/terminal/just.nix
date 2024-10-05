{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.just;
in
{

  options.myOS.terminal.just = with lib; {

    enable = mkEnableOption "just";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      just
    ];

  };

}
