{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.nh;
in
{

  options.myOS.programs.nh = with lib; {

    enable = mkEnableOption "nh";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nh # Yet another nix cli helper
    ];

  };

}
