{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.nixfmt;
in
{

  options.myOS.terminal.nixfmt = with lib; {

    enable = mkEnableOption "nixfmt";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nixfmt-rfc-style # Official formatter for Nix code
    ];

  };

}
