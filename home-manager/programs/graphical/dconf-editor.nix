{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.dconf-editor;
in
{

  options.myOS.graphical.dconf-editor = with lib; {

    enable = mkEnableOption "dconf-editor";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      dconf-editor
    ];

  };

}
