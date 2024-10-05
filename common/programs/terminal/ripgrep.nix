{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.ripgrep;
in
{

  options.myOS.terminal.ripgrep = with lib; {

    enable = mkEnableOption "ripgrep";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    ];

  };

}
