{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.nixfmt;
in
{

  options.myOS.programs.nixfmt = with lib; {

    enable = mkEnableOption "nixfmt";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nixfmt-rfc-style
    ];

  };

}
