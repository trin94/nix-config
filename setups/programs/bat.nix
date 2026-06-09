{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.bat;
in
{

  options.myOS.programs.bat = with lib; {

    enable = mkEnableOption "bat";

  };

  config = lib.mkIf cfg.enable {

    # A cat(1) clone with syntax highlighting and Git integration
    programs.bat = {
      enable = true;

      config = {
        italic-text = "always";
        tabs = "4";
        map-syntax = [ "Justfile:Makefile" ];
      };

      extraPackages = with pkgs.bat-extras; [
        batman # Read man pages with bat as the formatter
      ];
    };

  };

}
