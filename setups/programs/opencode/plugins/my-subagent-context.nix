{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
in
{

  options.myOS.programs.opencode.plugins.my-subagent-context = with lib; {

    enable = mkEnableOption "the my-subagent-context OpenCode plugin";

  };

  config = lib.mkIf (cfg.enable && cfg.plugins.my-subagent-context.enable) {

    xdg.configFile."opencode/tui-plugin/my-subagent-context".source = ./my-subagent-context;

  };

}
