{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
  asset =
    name: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/herdrdev/herdr/v${pkgs.herdr.version}/src/integration/assets/opencode/${name}";
      inherit hash;
    };
  opencodePlugin = pkgs.runCommand "herdr-opencode-integration" { } ''
    mkdir -p "$out/plugins" "$out/herdr-opencode"
    cp ${asset "herdr-agent-state.js" "sha256-9wp9IZP0qUCYOLB4rO5aNfcvCSWvCPY8FC7Jy/C6X80="} "$out/plugins/herdr-agent-state.js"
    cp ${asset "herdr-tui-session.js" "sha256-UGWdR9s89OfeMCjlbyZmplbvqt3CRxG3L1trqp+ZxdM="} "$out/herdr-tui-session.js"
    cp ${asset "tui.js" "sha256-pwqdneaNJOkuaM62WOU1tZrFXt2+9xGIjgLCdzwPnM4="} "$out/herdr-opencode/tui.js"
  '';
in
{

  options.myOS.programs.opencode.plugins.herdr = with lib; {

    enable = mkEnableOption "the herdr OpenCode plugin";

  };

  config = lib.mkIf (cfg.enable && cfg.plugins.herdr.enable) {

    assertions = [
      {
        assertion = config.myOS.programs.herdr.enable;
        message = "myOS.programs.opencode.plugins.herdr.enable requires myOS.programs.herdr.enable.";
      }
    ];

    xdg.configFile = {
      "opencode/plugins/herdr-agent-state.js".source = "${opencodePlugin}/plugins/herdr-agent-state.js";
      "opencode/herdr-tui-session.js".source = "${opencodePlugin}/herdr-tui-session.js";
      "opencode/herdr-opencode/tui.js".source = "${opencodePlugin}/herdr-opencode/tui.js";
    };

  };

}
