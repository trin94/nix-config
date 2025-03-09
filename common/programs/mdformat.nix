{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.mdformat;
in
{

  options.myOS.programs.mdformat = with lib; {

    enable = mkEnableOption "mdformat";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      mdformat
    ];

  };

}
