{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.nh;
in
{

  options.myOS.terminal.nh = with lib; {

    enable = mkEnableOption "nh";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nh # Yet another nix cli helper
    ];

  };

}
