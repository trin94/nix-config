{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.fish;
in
{

  options.myOS.programs.fish = with lib; {

    enable = mkEnableOption "fish";

    shellInit = mkOption {
      type = types.lines;
      default = "";
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      fzf
    ];

    programs.starship = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        container = {
          symbol = "📦";
          style = "bold blue";
          format = "[$symbol \\[$name\\]]($style) ";
        };

        nix_shell = {
          format = "via [$symbol]($style) ";
        };
      };
    };

    programs.nix-your-shell = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = false;
    };

    programs.fish = {
      enable = true;

      plugins = [ ];

      interactiveShellInit = ''
        set fish_greeting
      '';

      shellInit = cfg.shellInit;

      shellAliases = {
        "cfg" = "cd ~/.dotfiles";
      };

      shellAbbrs = {
        "pre-commit" = "prek";
      };

      functions = {

        envpp = {
          description = "Pretty print environment variables";
          body = ''
            env | sort | sed 's/=/%/' | column \
                --table \
                --separator '%' \
                --output-width 150 \
                --table-noheadings \
                --table-columns C1,C2 \
                --table-wrap C2'';
        };

      };

    };
  };

}
