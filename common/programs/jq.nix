{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.jq;
in
{

  options.myOS.programs.jq = with lib; {

    enable = mkEnableOption "jq";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jq
    ];

  };

}
