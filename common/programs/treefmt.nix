{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.treefmt;
in
{

  options.myOS.programs.treefmt = with lib; {

    enable = mkEnableOption "treefmt";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      treefmt2
      nixfmt-rfc-style # Official formatter for Nix code
    ];

  };

}
