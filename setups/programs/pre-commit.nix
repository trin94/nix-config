{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.pre-commit;
in
{

  options.myOS.programs.pre-commit = with lib; {

    enable = mkEnableOption "pre-commit";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      pre-commit
    ];

  };

}
