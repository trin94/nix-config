{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.fuzzel;
in
{

  options.myOS.programs.fuzzel = with lib; {

    enable = mkEnableOption "fuzzel";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fuzzel
    ];

    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          font = "MonoLisaCode Variable:size=14";
          # A bit more breathing room around the whole launcher.
          "vertical-pad" = 18;
          "inner-pad" = 12;
          # Fewer entries, with more space between each.
          lines = 10;
          "line-height" = 32;
        };

        border = {
          width = 5;
          radius = 0;
        };

        colors = {
          background = "1e1e2eff";
          border = "7fc8ffff";
          counter = "f5e0dcff";
          input = "cdd6f4ff";
          match = "f9e2afff";
          placeholder = "6c7086ff";
          prompt = "cdd6f4ff";
          selection = "45475aff";
          "selection-match" = "f9e2afff";
          "selection-text" = "cdd6f4ff";
          text = "cdd6f4ff";
        };
      };
    };

  };

}
