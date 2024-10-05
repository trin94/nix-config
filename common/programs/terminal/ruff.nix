{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.ruff;
in
{

  options.myOS.terminal.ruff = with lib; {

    enable = mkEnableOption "ruff";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ruff # Extremely fast Python linter

    ];

  };

}
