{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.jetbrains-toolbox;
in
{

  options.myOS.graphical.jetbrains-toolbox = with lib; {

    enable = mkEnableOption "jetbrains-toolbox";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jetbrains-toolbox
    ];

  };

}
