{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
  pluginPath = kind: name: "file://${config.xdg.configHome}/opencode/${kind}-plugin/${name}";

  # Both plugin lists are built here in a fixed order. Plugin modules don't add themselves.
  serverPlugins = [
    "opencode-with-claude"
  ]
  ++ lib.optional cfg.plugins.my-agents-local.enable (pluginPath "server" "my-agents-local");

  # V2 appends sidebar contributions in plugin order. Keep Git next to the footer.
  tuiPlugins =
    lib.optional cfg.plugins.my-loaded-skills.enable (pluginPath "tui" "my-loaded-skills")
    ++ lib.optional cfg.plugins.my-vcs-status.enable (pluginPath "tui" "my-vcs-status")
    ++ lib.optionals config.myOS.programs.herdr.enable [ "./herdr-opencode" ];
in
{

  options.myOS.programs.opencode = with lib; {

    enable = mkEnableOption "OpenCode configuration";

  };

  config = lib.mkIf cfg.enable {

    home.file.".agents/AGENTS.md".source = ./AGENTS.md;
    home.file.".agents/skills/ghostwriter".source = ./skills/ghostwriter;
    home.file.".agents/skills/reporting".source = ./skills/reporting;
    home.file.".agents/skills/commit-conventions".source = ./skills/commit-conventions;

    home.sessionPath = [
      "$HOME/.opencode/bin"
    ];

    # OpenCode discovers the shared skills from ~/.agents.
    home.sessionVariables.OPENCODE_DISABLE_CLAUDE_CODE_SKILLS = "1";

    xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      share = "disabled";
      plugins = serverPlugins;
      providers = {
        anthropic = {
          settings = {
            baseURL = "http://127.0.0.1:3456/v1";
            apiKey = "dummy";
          };
        };
      };
      # Last matching rule wins; keep exceptions after their broad rules.
      permissions = [
        {
          action = "*";
          resource = "*";
          effect = "ask";
        }
        {
          action = "shell";
          resource = "*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "*.env";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*.env.*";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*.env.example";
          effect = "allow";
        }
        {
          action = "grep";
          resource = "*";
          effect = "allow";
        }
        {
          action = "glob";
          resource = "*";
          effect = "allow";
        }
        {
          action = "skill";
          resource = "*";
          effect = "allow";
        }
        {
          action = "webfetch";
          resource = "*";
          effect = "allow";
        }
        {
          action = "websearch";
          resource = "*";
          effect = "allow";
        }
        {
          action = "question";
          resource = "*";
          effect = "deny";
        }
        {
          action = "external_directory";
          resource = "~/.agents/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "~/.dotfiles/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "~/PycharmProjects/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "/tmp/opencode/**";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "/nix/store/**";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/nix/store/**";
          effect = "allow";
        }
        {
          action = "read";
          resource = "SKILL.md";
          effect = "deny";
        }
        {
          action = "read";
          resource = "*/SKILL.md";
          effect = "deny";
        }
      ];
    };

    xdg.configFile."opencode/cli.json" = {
      force = true;
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/v2/cli.json";
        theme.name = "catppuccin";
        diffs.wrap = "word";
        prompt.paste = "full";
        session = {
          sidebar = "auto";
          scrollbar = false;
          thinking = "hide";
          grouping = "auto";
          verbosity = "low";
          permissions = "prompt";
        };
        tabs = {
          layout = "horizontal";
          indicators = "status";
        };
        attention.sound = false;
        animations = true;
        plugins = tuiPlugins;
      };
    };

  };

}
