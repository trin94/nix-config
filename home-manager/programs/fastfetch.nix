{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    fastfetch # Like neofetch, but much faster because written in C
  ];

  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      general = {
        multithreading = true;
      };

      display = {
        separator = "➜   ";
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
          key = " OS         ";
          keyColor = "green";
        }
        {
          type = "kernel";
          key = " Kernel     ";
          keyColor = "cyan";
        }
        {
          type = "uptime";
          key = "󰅐 Uptime     ";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = " Packages   ";
          keyColor = "green";
        }
        {
          type = "de";
          key = " Desktop    ";
          keyColor = "cyan";
        }
        {
          type = "shell";
          key = " Shell      ";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = " Terminal   ";
          keyColor = "green";
        }
        {
          key = " Font       ";
          keyColor = "cyan";
          type = "terminalfont";
        }
        {
          key = "󰻠 CPU        ";
          keyColor = "blue";
          type = "cpu";
        }
        {
          key = "󰍛 GPU        ";
          keyColor = "green";
          type = "gpu";
        }
        {
          key = "󰑭 Memory     ";
          keyColor = "cyan";
          type = "memory";
        }
        {
          key = "󰩟 Local IP   ";
          keyColor = "blue";
          type = "localip";
          compact = true;
        }

        "break"

        {
          type = "colors";
          symbol = "square";
        }
      ];
    };
  };

}
