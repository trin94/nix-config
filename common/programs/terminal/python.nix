{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.python;
in
{

  # Actually using Python like in this module is not recommended. Will fix, when I have more time
  # https://wiki.nixos.org/wiki/Python

  options.myOS.terminal.python = with lib; {

    enable = mkEnableOption "python";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      python312 # A high-level dynamically-typed programming language
    ];

  };

}
