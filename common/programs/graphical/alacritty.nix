{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.alacritty;
in
{

  options.myOS.graphical.alacritty = with lib; {

    enable = mkEnableOption "alacritty";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      alacritty # A cross-platform, GPU-accelerated terminal emulator
    ];

    programs.alacritty = {
      enable = true;

      settings = {
        cursor = {
          style = {
            blinking = "On";
            shape = "Beam";
          };
        };

        selection = {
          save_to_clipboard = true;
        };

        terminal = {
          shell = {
            program = "fish";
          };
        };

        window = {
          padding = {
            x = 5;
            y = 5;
          };

          dimensions = {
            columns = 120;
            lines = 30;
          };
        };
      };
    };
  };

}
