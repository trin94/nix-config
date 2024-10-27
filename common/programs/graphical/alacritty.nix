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
        colors = {
          primary = {
            background = "0x2e3440";
            foreground = "0xd8dee9";
            dim_foreground = "0xa5abb6";
          };

          cursor = {
            text = "0x2e3440";
            cursor = "0xd8dee9";
          };

          vi_mode_cursor = {
            text = "0x2e3440";
            cursor = "0xd8dee9";
          };

          selection = {
            text = "CellForeground";
            background = "0x4c566a";
          };

          search = {
            matches = {
              foreground = "CellBackground";
              background = "0x88c0d0";
            };
          };

          footer_bar = {
            background = "0x434c5e";
            foreground = "0xd8dee9";
          };

          normal = {
            black = "0x3b4252";
            red = "0xbf616a";
            green = "0xa3be8c";
            yellow = "0xebcb8b";
            blue = "0x81a1c1";
            magenta = "0xb48ead";
            cyan = "0x88c0d0";
            white = "0xe5e9f0";
          };

          bright = {
            black = "0x4c566a";
            red = "0xbf616a";
            green = "0xa3be8c";
            yellow = "0xebcb8b";
            blue = "0x81a1c1";
            magenta = "0xb48ead";
            cyan = "0x8fbcbb";
            white = "0xeceff4";
          };

          dim = {
            black = "0x373e4d";
            red = "0x94545d";
            green = "0x809575";
            yellow = "0xb29e75";
            blue = "0x68809a";
            magenta = "0x8c738c";
            cyan = "0x6d96a5";
            white = "0xaeb3bb";
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
