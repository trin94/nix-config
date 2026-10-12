{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
in
{

  options.myOS.programs.opencode.plugins.my-loaded-skills = with lib; {

    enable = mkEnableOption "the my-loaded-skills OpenCode plugin";

  };

  config = lib.mkIf (cfg.enable && cfg.plugins.my-loaded-skills.enable) {

    xdg.configFile."opencode/tui-plugin/my-loaded-skills".source = ./my-loaded-skills;

  };

}
