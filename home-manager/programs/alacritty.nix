{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.alacritty;
in
{

  options.myOS.alacritty = with lib; {

    enable = mkEnableOption "alacritty";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      alacritty # A cross-platform, GPU-accelerated terminal emulator
    ];

    programs.alacritty = {
      enable = true;

      settings = {
        colors = {
          primary = {
            background = "0x282c34";
            foreground = "0xbbc2cf";
          };

          normal = {
            black = "0x1c1f24";
            red = "0xff6c6b";
            green = "0x98be65";
            yellow = "0xda8548";
            blue = "0x51afef";
            magenta = "0xc678dd";
            cyan = "0x5699af";
            white = "0xabb2bf";
          };

          bright = {
            black = "0x5b6268";
            red = "0xda8548";
            green = "0x4db5bd";
            yellow = "0xecbe7b";
            blue = "0x3071db";
            magenta = "0xa9a1e1";
            cyan = "0x46d9ff";
            white = "0xdfdfdf";
          };

        };

        cursor = {
          style = {
            blinking = "On";
            shape = "Beam";
          };
        };

        font = {
          size = 15.0;

          normal = {
            family = "CaskaydiaCove Nerd Font";
            style = "bold";
          };
        };

        selection = {
          save_to_clipboard = true;
        };

        shell = {
          program = "fish";
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
