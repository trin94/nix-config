{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.procs;
in
{

  options.myOS.terminal.procs = with lib; {

    enable = mkEnableOption "procs";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      procs # A modern replacement for ps written in Rust
    ];

  };

}
