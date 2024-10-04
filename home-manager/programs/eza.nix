{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.eza;
in
{

  options.myOS.eza = with lib; {

    enable = mkEnableOption "eza";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      eza # Modern, maintained replacement for ls
    ];

  };

}
