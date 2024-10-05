{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.eartag;
in
{

  options.myOS.graphical.eartag = with lib; {

    enable = mkEnableOption "eartag";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      eartag
    ];

  };

}
