{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.jq;
in
{

  options.myOS.terminal.jq = with lib; {

    enable = mkEnableOption "jq";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jq
    ];

  };

}
