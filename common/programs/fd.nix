{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.fd;
in
{

  options.myOS.programs.fd = with lib; {

    enable = mkEnableOption "fd";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fd
    ];

  };

}
