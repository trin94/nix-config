{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.opencode;
  jsonFormat = pkgs.formats.json { };
  pluginPath = kind: name: "file://${config.xdg.configHome}/opencode/${kind}-plugin/${name}";

  # Both plugin lists are built here in a fixed order. Plugin modules don't add themselves.
  serverPlugins =
    lib.optional cfg.plugins.with-claude.enable "opencode-with-claude"
    ++ lib.optional cfg.plugins.my-agents-local.enable (pluginPath "server" "my-agents-local");

  # opencode-with-claude starts the proxy and rewrites the base URL at runtime. The block
  # still has to exist, so the URL is only a placeholder.
  pluginProviders = lib.optionalAttrs cfg.plugins.with-claude.enable {
    anthropic = {
      settings = {
        baseURL = "http://127.0.0.1:3456/v1";
        apiKey = "dummy";
      };
    };
  };

  providers = lib.recursiveUpdate pluginProviders cfg.overrideProviders;

  mcp = lib.recursiveUpdate { } cfg.overrideMcp;

  # Personal rule: always last, so no host list can override it.
  permissions = cfg.permissions ++ [
    {
      action = "question";
      resource = "*";
      effect = "deny";
    }
  ];

  # V2 appends sidebar contributions in plugin order. Keep Git next to the footer.
  tuiPlugins =
    lib.optional cfg.plugins.my-loaded-skills.enable (pluginPath "tui" "my-loaded-skills")
    ++ lib.optional cfg.plugins.my-vcs-status.enable (pluginPath "tui" "my-vcs-status")
    ++ lib.optional cfg.plugins.herdr.enable "./herdr-opencode";
in
{

  options.myOS.programs.opencode = with lib; {

    enable = mkEnableOption "OpenCode configuration";

    overrideProviders = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      description = "Host-specific providers deep-merged over the providers the plugins bring.";
    };

    overrideMcp = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      description = "Host-specific `mcp` config (servers under `servers`, timeouts), deep-merged like `overrideProviders`.";
    };

    permissions = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            action = mkOption { type = types.str; };
            resource = mkOption { type = types.str; };
            effect = mkOption {
              type = types.enum [
                "allow"
                "ask"
                "deny"
              ];
            };
          };
        }
      );
      default = importJSON ./permissions.json;
      description = "Permission rules on top of OpenCode's built-in base policy; the last matching rule wins. Setting this replaces the defaults from `permissions.json` completely.";
    };

  };

  config = lib.mkIf cfg.enable {

    home.file.".agents/AGENTS.md".source = ./AGENTS.md;
    home.file.".agents/skills/ghostwriter".source = ./skills/ghostwriter;
    home.file.".agents/skills/reporting".source = ./skills/reporting;
    home.file.".agents/skills/commit-conventions".source = ./skills/commit-conventions;
    home.file.".agents/skills/deliver-spec".source = ./skills/deliver-spec;

    home.sessionPath = [
      "$HOME/.opencode/bin"
    ];

    # OpenCode discovers the shared skills from ~/.agents.
    home.sessionVariables.OPENCODE_DISABLE_CLAUDE_CODE_SKILLS = "1";

    xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON (
      {
        "$schema" = "https://opencode.ai/config.json";
        share = "disabled";
        plugins = serverPlugins;
      }
      // lib.optionalAttrs (providers != { }) { inherit providers; }
      // lib.optionalAttrs (mcp != { }) { inherit mcp; }
      // {
        inherit permissions;
      }
    );

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
