{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.fastfetch;
in
{

  options.myOS.programs.fastfetch = with lib; {

    enable = mkEnableOption "fastfetch";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fastfetch # Like neofetch, but much faster because written in C
    ];

    programs.fastfetch = {
      enable = true;

      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

        display = {
          separator = " → ";
        };

        logo = {
          type = "none";
        };

        modules = [
          "break"
          {
            type = "title";
            format = "{6}{7}{8}";
          }
          "break"
          {
            type = "os";
            key = "● OS";
            keyColor = "blue";
          }
          {
            type = "kernel";
            key = "● Kernel";
            keyColor = "blue";
          }
          {
            type = "uptime";
            key = "● Uptime";
            keyColor = "cyan";
          }
          {
            type = "shell";
            key = "● Shell";
            keyColor = "cyan";
          }
          {
            type = "terminal";
            key = "● Term";
            keyColor = "green";
          }
          {
            type = "cpu";
            key = "● CPU";
            keyColor = "green";
          }
          {
            type = "gpu";
            key = "● GPU";
            keyColor = "green";
          }
          {
            type = "memory";
            key = "● Mem";
            keyColor = "yellow";
          }
          "break"
          {
            type = "colors";
            symbol = "circle";
          }
        ];
      };
    };
  };

}
