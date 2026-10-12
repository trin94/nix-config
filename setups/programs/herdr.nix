{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.herdr;
in
{
  options.myOS.programs.herdr.enable = lib.mkEnableOption "herdr";

  config = lib.mkIf cfg.enable {
    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        theme.name = "gruvbox-light";
        terminal.default_shell = lib.getExe pkgs.fish;
        ui.prompt_new_tab_name = false;
        ui.sound.enabled = false;
      };
    };
  };
}
