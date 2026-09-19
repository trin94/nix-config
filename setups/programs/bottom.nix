{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.bottom;
in
{

  options.myOS.programs.bottom = with lib; {

    enable = mkEnableOption "bottom";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      bottom
    ];

    programs.bottom = {
      enable = true;
      settings = {
        flags = {
          basic = true;
          disable_gpu = true;
          disable_click = true;
          default_widget_type = "proc";
          default_widget_count = 1;
        };
        processes = {
          default_memory_value = true;
          columns = [
            "PID"
            "Name"
            "CPU%"
            "Mem%"
            "User"
          ];
        };
      };
    };

  };

}
