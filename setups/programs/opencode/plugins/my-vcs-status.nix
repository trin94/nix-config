{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
in
{

  options.myOS.programs.opencode.plugins.my-vcs-status = with lib; {

    enable = mkEnableOption "the my-vcs-status OpenCode plugin";

  };

  config = lib.mkIf (cfg.enable && cfg.plugins.my-vcs-status.enable) {

    # One directory, so the entrypoint can import its sibling. Per-file entries land in
    # separate store paths and the relative import breaks.
    xdg.configFile."opencode/tui-plugin/my-vcs-status".source = ./my-vcs-status;

  };

}
