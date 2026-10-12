{
  lib,
  ...
}:
{

  # npm plugin, nothing to deploy. The core module registers it and adds its provider.
  options.myOS.programs.opencode.plugins.with-claude = with lib; {

    enable = mkEnableOption "the opencode-with-claude OpenCode plugin";

  };

}
