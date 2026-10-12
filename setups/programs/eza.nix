{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.eza;
in
{

  options.myOS.programs.eza = with lib; {

    enable = mkEnableOption "eza";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      eza # Modern, maintained replacement for ls
    ];

    programs.fish.shellAliases =
      let
        ezaArgs = "--group-directories-first --color=always --icons=never --hyperlink";
      in
      {
        "ls" = "eza ${ezaArgs} --long";
        "ll" = "eza ${ezaArgs} --long --all";
        "lt" = "eza ${ezaArgs} --long --tree";
        "la" = "ll";
      };

  };

}
