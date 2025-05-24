{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.poetry;
in
{

  options.myOS.programs.poetry = with lib; {

    enable = mkEnableOption "poetry";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = {

    home.packages = lib.mkIf cfg.enable (
      with pkgs;
      [
        poetry # Python dependency management and packaging made easy
      ]
    );

    home.sessionVariables = lib.mkIf cfg.configure {
      POETRY_VIRTUALENVS_IN_PROJECT = "true";
    };

  };

}
