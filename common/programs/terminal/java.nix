{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.java;
in
{

  options.myOS.terminal.java = with lib; {

    enable = mkEnableOption "java";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jdk # Open-source Java Development Kit / Latest LTS
      maven # Build automation tool (used primarily for Java projects)
      gradle # Enterprise-grade build system
    ];

    programs = {

      java = {
        enable = true;
      };

      gradle = {
        enable = true;
      };

    };

  };

}