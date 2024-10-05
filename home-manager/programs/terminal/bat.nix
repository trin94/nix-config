{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.bat;
in
{

  options.myOS.terminal.bat = with lib; {

    enable = mkEnableOption "bat";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      bat # A cat(1) clone with syntax highlighting and Git integration
    ];

  };

}
