{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.helix;
in
{

  options.myOS.programs.helix = with lib; {

    enable = mkEnableOption "helix";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      helix
      wl-clipboard
      yaml-language-server
      pyright
      ruff
      gopls
      bash-language-server
      typescript-language-server
      typescript
      lua-language-server
      nil
      marksman
      taplo
      just-lsp
      kdePackages.qtdeclarative
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      settings = {
        theme = "catppuccin_mocha";

        editor = {
          line-number = "absolute";
          cursorline = true;
          mouse = true;
          scrolloff = 5;
          bufferline = "multiple";
          color-modes = true;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            render = true;
            character = "╎";
          };

          file-picker = {
            hidden = false;
          };

          lsp = {
            display-messages = true;
          };

          soft-wrap = {
            enable = true;
          };
        };

        keys.normal = {
          "C-c" = "normal_mode";
          "up" = "no_op";
          "down" = "no_op";
          "left" = "no_op";
          "right" = "no_op";
          "C-S-A-l" = ":format";
          "C-/" = [
            "toggle_comments"
            "move_line_down"
          ];
          "C-S-/" = "toggle_block_comments";
          "A-j" = [
            "search_selection"
            "extend_search_next"
          ];
          "A-J" = "remove_primary_selection";
        };

        keys.insert = {
          "C-c" = "normal_mode";
          "up" = "no_op";
          "down" = "no_op";
          "left" = "no_op";
          "right" = "no_op";
        };

        keys.select = {
          "C-c" = "normal_mode";
        };
      };

      languages = {
        language-server = {
          yaml-language-server = {
            command = "yaml-language-server";
            args = [ "--stdio" ];
          };
          pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
          };
          gopls = {
            command = "gopls";
          };
          bash-language-server = {
            command = "bash-language-server";
            args = [ "start" ];
          };
          typescript-language-server = {
            command = "typescript-language-server";
            args = [ "--stdio" ];
          };
          lua-language-server = {
            command = "lua-language-server";
          };
          nil = {
            command = "nil";
          };
          marksman = {
            command = "marksman";
            args = [ "server" ];
          };
          taplo = {
            command = "taplo";
            args = [
              "lsp"
              "stdio"
            ];
          };
          just-lsp = {
            command = "just-lsp";
          };
          qmlls = {
            command = "qmlls";
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${lib.getExe pkgs.nixfmt-rfc-style}";
            language-servers = [ "nil" ];
          }
          {
            name = "yaml";
            auto-format = true;
            language-servers = [ "yaml-language-server" ];
          }
          {
            name = "python";
            auto-format = true;
            language-servers = [ "pyright" ];
            formatter = {
              command = "ruff";
              args = [
                "format"
                "-"
              ];
            };
          }
          {
            name = "go";
            auto-format = true;
            language-servers = [ "gopls" ];
          }
          {
            name = "bash";
            language-servers = [ "bash-language-server" ];
          }
          {
            name = "typescript";
            auto-format = true;
            language-servers = [ "typescript-language-server" ];
          }
          {
            name = "lua";
            auto-format = true;
            language-servers = [ "lua-language-server" ];
          }
          {
            name = "markdown";
            language-servers = [ "marksman" ];
          }
          {
            name = "toml";
            auto-format = true;
            language-servers = [ "taplo" ];
          }
          {
            name = "just";
            auto-format = true;
            language-servers = [ "just-lsp" ];
          }
          {
            name = "qml";
            auto-format = true;
            language-servers = [ "qmlls" ];
          }
        ];
      };
    };

  };

}
