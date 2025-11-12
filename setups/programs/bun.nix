{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.bun;
in
{

  options.myOS.programs.bun = with lib; {

    enable = mkEnableOption "bun";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      bun
    ];

    programs.bun = {
      enable = true;
    };

  };

}
