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
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      settings = {
        theme = "stylix";

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
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${lib.getExe pkgs.nixfmt-rfc-style}";
          }
        ];
      };
    };

  };

}
