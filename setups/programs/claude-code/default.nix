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
in
{

  options.myOS.programs.claude-code = with lib; {

    enable = mkEnableOption "Claude Code configuration (the binary stays with the native installer in ~/.local/bin)";

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

      ".claude/agents/deliver-spec-ticket-owner.md".text = ''
        ---
        name: deliver-spec-ticket-owner
        description: "Owns one deliver-spec ticket: implementation, review and fixes. Launch only from deliver-spec."
        tools: Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, Read, SendMessage, Skill, TaskStop, TodoWrite, ToolSearch, WebFetch, WebSearch, Write
        ---

        You own one deliver-spec ticket. Your prompt names the brief to follow and the notes to read. Launch the
        subagents the brief asks for yourself.
      '';

      # Claude Code rewrites this file from /config and /model. Those changes now last one session; the
      # file it wrote before held only `theme`, which is carried over here.
      ".claude/settings.json" = {
        force = true;
        text = builtins.toJSON {
          "$schema" = "https://json.schemastore.org/claude-code-settings.json";
          theme = "dark";
          showThinkingSummaries = false;
          # commit-conventions: the user is the sole author.
          attribution = {
            commit = "";
            pr = "";
            sessionUrl = false;
          };
          env = {
            DISABLE_TELEMETRY = "1";
            # deliver-spec: the main session -> ticket owner -> its workers, like OpenCode's subagent_depth.
            CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH = "2";
          };
          # Deny beats ask beats allow here, whatever the order. Only a `!` deny pattern carves an
          # exception out of the deny patterns before it.
          permissions = {
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
          statusLine = {
            type = "command";
            command = "${lib.getExe pkgs.nushell} --stdin ${./statusline.nu}";
            # Background subagents change Git while the main session idles; my-vcs-status polls every 5 s too.
            refreshInterval = 5;
          };
        };
      };
    }
    // lib.mapAttrs' (
      name: source: lib.nameValuePair ".claude/skills/${name}" { inherit source; }
    ) agents.skills;

  };

}
