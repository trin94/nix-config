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
          disable_gpu = true;
          process_memory_as_value = true;
          disable_click = true;
          default_widget_type = "proc";
          default_widget_count = 1;
        };
        processes = {
          columns = [
            "PID"
            "Name"
            "CPU%"
            "Mem%"
            "User"
          ];
        };
        row = [
          {
            child = [
              {
                type = "proc";
                default = true;
              }
            ];
          }
        ];
      };
    };

  };

}
