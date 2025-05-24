{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.devenv;
in
{

  options.myOS.programs.devenv = with lib; {

    enable = mkEnableOption "devenv";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      devenv
      direnv
    ];

    programs.direnv = {
      enable = true;
      config = {
        global = {
          hide_env_diff = true;
        };
      };
    };

  };

}
