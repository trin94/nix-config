{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.claude-code;

  agents = config.myOS.programs.agents;

  # The same paths OpenCode reaches through external_directory and its edit rule.
  externalDirectories = [
    "~/.agents"
    "~/.dotfiles"
    "~/git"
    "~/PycharmProjects"
  ];

  # Loaded from the store through CLAUDE_CODE_PLUGIN_DIRS; no marketplace install.
  pluginDirs = lib.optional cfg.plugins.my-sidebar.enable ./plugins/my-sidebar;
in
{

  options.myOS.programs.claude-code = with lib; {

    enable = mkEnableOption "Claude Code configuration (the binary stays with the native installer in ~/.local/bin)";

    plugins.my-sidebar.enable = mkEnableOption "the my-sidebar Claude Code plugin, which replaces the status line";

  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = agents.enable;
        message = "myOS.programs.claude-code.enable requires myOS.programs.agents.enable.";
      }
    ];

    home.file = {
      ".claude/CLAUDE.md".source = agents.rules;

      ".claude/agents/ticket-owner.md".text = ''
        ---
        name: ticket-owner
        description: ${builtins.toJSON agents.ticketOwner.description}
        tools: Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, Read, SendMessage, Skill, TaskStop, TodoWrite, ToolSearch, WebFetch, WebSearch, Write
        ---

        ${agents.ticketOwner.prompt}'';

      # Claude Code rewrites this file from /config and /model. Those changes now last one session; the
      # file it wrote before held only `theme`, which is carried over here.
      ".claude/settings.json" = {
        force = true;
        text = builtins.toJSON (
          {
            "$schema" = "https://json.schemastore.org/claude-code-settings.json";
            # Follows the terminal palette, so the sidebar matches the other TUIs.
            theme = "dark-ansi";
            showThinkingSummaries = false;
            # Personal rule: no auto memory.
            autoMemoryEnabled = false;
            autoDreamEnabled = false;

            # Lean context: features that list tools, skills or instructions every turn stay off.
            # commit-conventions and pr cover git.
            includeGitInstructions = false;
            disableBundledSkills = true;
            enableArtifact = false;
            disableWorkflows = true;
            disableClaudeAiConnectors = true;
            # Not in the public schema (2.1.326); the CLI may rename these without notice.
            syncClaudeAiPlugins = false;
            syncClaudeAiSkills = false;

            # Model behaviour.
            language = "english";
            respondToBashCommands = false;
            # Compact by hand with /compact.
            autoCompactEnabled = false;
            idleCompaction = false;
            # Pause rather than continue on another model without asking.
            switchModelsOnFlag = false;

            # Quiet UI.
            viewMode = "focus";
            verbose = false;
            prefersReducedMotion = false;
            spinnerTipsEnabled = false;
            spinnerVerbs = {
              mode = "replace";
              verbs = [ "Working" ];
            };
            showTurnDuration = false;
            awaySummaryEnabled = false;
            feedbackSurveyRate = 0;
            emojiCompletionEnabled = false;
            promptSuggestionEnabled = false;
            responseComparisonEnabled = false;

            # Nothing outside the terminal: no phone control, IDE plugin installs or claude-cli:// handler.
            disableRemoteControl = true;
            autoInstallIdeExtension = false;
            disableDeepLinkRegistration = "disable";

            useAutoModeDuringPlan = true;
            showClearContextOnPlanAccept = true;
            # commit-conventions: the user is the sole author.
            attribution = {
              commit = "";
              pr = "";
              sessionUrl = false;
            };
            env = {
              DISABLE_TELEMETRY = "1";
              DISABLE_ERROR_REPORTING = "1";
              CLAUDE_CODE_DISABLE_CRON = "1";
              # Plugins load from the store through CLAUDE_CODE_PLUGIN_DIRS.
              CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL = "1";
              # deliver-spec: the main session -> ticket owner -> its workers, like OpenCode's subagent_depth.
              CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH = "2";
            }
            // lib.optionalAttrs (pluginDirs != [ ]) {
              CLAUDE_CODE_PLUGIN_DIRS = lib.concatMapStringsSep ":" (dir: "${dir}") pluginDirs;
            };
            # Deny beats ask beats allow here, whatever the order. Only a `!` deny pattern carves an
            # exception out of the deny patterns before it.
            permissions = {
              defaultMode = "auto";
              allow = [
                "Bash"
                "Edit(./**)"
                "Skill"
                "WebFetch"
                "WebSearch"
                "Read(//nix/store/**)"
              ]
              ++ lib.concatMap (dir: [
                "Read(${dir}/**)"
                "Edit(${dir}/**)"
              ]) externalDirectories;
              deny = [
                "Read(*.env)"
                "Read(*.env.*)"
                "Read(!*.env.example)"
                # Skills load through the Skill tool. A Read deny also blocks edits, so the repo sources stay open.
                "Read(~/.claude/skills/**/SKILL.md)"
                "Read(~/.agents/skills/**/SKILL.md)"
                "Read(**/.claude/skills/**/SKILL.md)"
                # Personal rule, as in OpenCode.
                "AskUserQuestion"
              ];
            };
          }
          # my-sidebar shows the status line's context, Git and skills, and only the alt-screen renderer docks it.
          // (
            if cfg.plugins.my-sidebar.enable then
              { tui = "fullscreen"; }
            else
              {
                statusLine = {
                  type = "command";
                  command = "${lib.getExe pkgs.nushell} --stdin ${./statusline.nu}";
                  # Background subagents change Git while the main session idles; my-vcs-status polls every 5 s too.
                  refreshInterval = 5;
                };
              }
          )
        );
      };
    }
    // lib.mapAttrs' (
      name: source: lib.nameValuePair ".claude/skills/${name}" { inherit source; }
    ) agents.skills;

  };

}
