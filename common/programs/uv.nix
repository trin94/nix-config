{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.uv;
in
{

  options.myOS.programs.uv = with lib; {

    enable = mkEnableOption "uv";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      uv # Extremely fast Python package installer and resolver, written in Rust
    ];

  };

}
