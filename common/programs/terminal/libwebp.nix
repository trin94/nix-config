{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.libwebp;
in
{

  options.myOS.terminal.libwebp = with lib; {

    enable = mkEnableOption "libwebp";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      libwebp
    ];

  };

}
