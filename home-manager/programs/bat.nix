{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.bat;
in
{

  options.myOS.bat = with lib; {

    enable = mkEnableOption "bat";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      bat # A cat(1) clone with syntax highlighting and Git integration
    ];

  };

}
