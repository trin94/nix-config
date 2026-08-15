{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ai;
in
{

  options.myOS.programs.ai = with lib; {

    claude.enable = mkEnableOption "Claude configuration";
    opencode.enable = mkEnableOption "OpenCode configuration";

  };

  config = lib.mkMerge [

    (lib.mkIf (cfg.claude.enable || cfg.opencode.enable) {

      home.file.".agents/AGENTS.md".source = ./agents/AGENTS.md;
      home.file.".agents/skills/ghostwriter".source = ./agents/skills/ghostwriter;
      home.file.".agents/skills/reporting".source = ./agents/skills/reporting;
      home.file.".agents/skills/commit-conventions".source = ./agents/skills/commit-conventions;

    })

    (lib.mkIf cfg.claude.enable {

      home.file.".claude/CLAUDE.md".source = ./agents/AGENTS.md;
      home.file.".claude/skills/ghostwriter".source = ./agents/skills/ghostwriter;
      home.file.".claude/skills/reporting".source = ./agents/skills/reporting;
      home.file.".claude/skills/commit-conventions".source = ./agents/skills/commit-conventions;

      home.file.".claude/statusline-git-diff.sh" = {
        source = ./agents/claude/statusline-git-diff.sh;
        executable = true;
      };

    })

    (lib.mkIf cfg.opencode.enable {

      home.sessionPath = [
        "$HOME/.opencode/bin"
      ];

      # OpenCode discovers the shared skills from ~/.agents.
      home.sessionVariables.OPENCODE_DISABLE_CLAUDE_CODE_SKILLS = "1";

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        instructions = [
          "${config.home.homeDirectory}/.agents/AGENTS.md"
        ];
        permission = {
          "*" = "ask";
          bash = "allow";
          edit = "allow";
          write = "allow";
          read = {
            "*" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
          };
          grep = "allow";
          glob = "allow";
          lsp = "deny";
          apply_patch = "allow";
          skill = "allow";
          todowrite = "allow";
          webfetch = "allow";
          websearch = "allow";
          question = "deny";
          directory = "allow";
          external_directory = {
            "~/.agents/**" = "allow";
            "~/.claude/**" = "allow";
            "~/.dotfiles/**" = "allow";
            "~/PycharmProjects/**" = "allow";
            "/tmp/opencode/**" = "allow";
          };
        };
      };

      xdg.configFile."opencode/tui.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/tui.json";
        keybinds.tool_details = "<leader>d";
      };

    })

  ];

}
