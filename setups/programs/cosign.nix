{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.cosign;
in
{

  options.myOS.programs.cosign = with lib; {

    enable = mkEnableOption "cosign";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      cosign
    ];

  };

}
