{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.treefmt;
in
{

  options.myOS.terminal.treefmt = with lib; {

    enable = mkEnableOption "treefmt";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      treefmt2
      nixfmt-rfc-style # Official formatter for Nix code
    ];

  };

}
