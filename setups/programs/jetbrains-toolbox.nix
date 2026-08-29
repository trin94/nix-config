{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.jetbrains-toolbox;
in
{

  options.myOS.programs.jetbrains-toolbox = with lib; {

    enable = mkEnableOption "jetbrains-toolbox";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jetbrains-toolbox
    ];

  };

}
