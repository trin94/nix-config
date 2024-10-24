{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.nushell;
in
{

  options.myOS.terminal.nushell = with lib; {

    enable = mkEnableOption "nushell";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nushell
    ];

  };

}
