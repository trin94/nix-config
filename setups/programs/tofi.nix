{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.tofi;
in
{

  options.myOS.programs.tofi = with lib; {

    enable = mkEnableOption "tofi";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

    width = mkOption {
      type = types.str;
      default = "50%";
      description = "Window width";
    };

    height = mkOption {
      type = types.str;
      default = "40%";
      description = "Window height";
    };

    font = mkOption {
      type = types.str;
      default = "monospace";
      description = "Font family";
    };

    fontSize = mkOption {
      type = types.int;
      default = 20;
      description = "Font size";
    };

  };

  config = lib.mkIf cfg.configure {

    home.packages = [ pkgs.tofi ];

    xdg.configFile."tofi/config".text = ''
      font = ${cfg.font}
      font-size = ${toString cfg.fontSize}
      hint-font = false
      width = ${cfg.width}
      height = ${cfg.height}
      anchor = top-left
      margin-left = 25%
      margin-top = 30%
      result-spacing = 25
      num-results = 10
      background-color = #1e1e2e
      text-color = #f5f5f5
      prompt-color = #cba6f7
      selection-color = #f38ba8
      input-color = #f5f5f5
      border-width = 3
      border-color = #7fc8ff
      outline-width = 0
      padding-left = 20
      padding-right = 20
      padding-top = 20
      padding-bottom = 20
      corner-radius = 6
    '';

  };

}
