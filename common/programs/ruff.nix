{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ruff;
in
{

  options.myOS.programs.ruff = with lib; {

    enable = mkEnableOption "ruff";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ruff # Extremely fast Python linter

    ];

  };

}
