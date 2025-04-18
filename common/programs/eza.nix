{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.eza;
in
{

  options.myOS.programs.eza = with lib; {

    enable = mkEnableOption "eza";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      eza # Modern, maintained replacement for ls
    ];

  };

}
