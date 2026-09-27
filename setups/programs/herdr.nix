{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.herdr;
  opencode = config.myOS.programs.ai.opencode.enable;
  asset =
    name: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/herdrdev/herdr/v${pkgs.herdr.version}/src/integration/assets/opencode/${name}";
      inherit hash;
    };
  opencodePlugin = pkgs.runCommand "herdr-opencode-integration" { } ''
    mkdir -p "$out/plugins" "$out/herdr-opencode"
    cp ${asset "herdr-agent-state.js" "sha256-Gmrr9mMjJP7GPR3iJnN7n6azXz3bUc5odDnma2x8tHU="} "$out/plugins/herdr-agent-state.js"
    cp ${asset "herdr-tui-session.js" "sha256-+bXC2xabDww4p4vCyDQReGc7wNAOX3BXdlrqc93Ff5U="} "$out/herdr-tui-session.js"
    cp ${asset "tui.js" "sha256-lLjRB+GrW/+iMg47fxVNGEiiFniHhaKbhtc1urNa+eg="} "$out/herdr-opencode/tui.js"
  '';
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

    xdg.configFile = lib.mkIf opencode {
      "opencode/plugins/herdr-agent-state.js".source = "${opencodePlugin}/plugins/herdr-agent-state.js";
      "opencode/herdr-tui-session.js".source = "${opencodePlugin}/herdr-tui-session.js";
      "opencode/herdr-opencode/tui.js".source = "${opencodePlugin}/herdr-opencode/tui.js";
    };
  };
}
