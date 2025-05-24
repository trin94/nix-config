{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.libwebp;
in
{

  options.myOS.programs.libwebp = with lib; {

    enable = mkEnableOption "libwebp";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      libwebp
    ];

  };

}
