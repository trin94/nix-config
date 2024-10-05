{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.telegram-desktop;
in
{

  options.myOS.graphical.telegram-desktop = with lib; {

    enable = mkEnableOption "telegram-desktop";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      telegram-desktop
    ];

  };

}
