{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.yq;
in
{

  options.myOS.terminal.yq = with lib; {

    enable = mkEnableOption "yq";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      yq-go # Portable command-line YAML processor
      yamlfmt # Extensible command line tool or library to format yaml files
    ];

  };

}
