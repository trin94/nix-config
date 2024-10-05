{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.fd;
in
{

  options.myOS.terminal.fd = with lib; {

    enable = mkEnableOption "fd";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fd
    ];

  };

}
