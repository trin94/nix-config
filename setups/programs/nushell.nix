{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.nushell;
in
{

  options.myOS.programs.nushell = with lib; {

    enable = mkEnableOption "nushell";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      nushell
    ];

    programs.nushell = {
      enable = true;
      loadSessionVariables = true;

      plugins = with pkgs; [
        nushellPlugins.polars
      ];
    };

  };

}
