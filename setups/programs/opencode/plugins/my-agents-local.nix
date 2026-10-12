{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
in
{

  options.myOS.programs.opencode.plugins.my-agents-local = with lib; {

    enable = mkEnableOption "the my-agents-local OpenCode plugin";

  };

  config = lib.mkIf (cfg.enable && cfg.plugins.my-agents-local.enable) {

    xdg.configFile."opencode/server-plugin/my-agents-local".source = ./my-agents-local;

  };

}
