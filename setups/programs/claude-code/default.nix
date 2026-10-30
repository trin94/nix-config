{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.claude-code;

  # Claude Code mirrors the OpenCode setup, so it reads the rules and skills from there.
  opencode = ../opencode;
  repoSkills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir (opencode + "/skills"))
  );

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

    home.file = {
      ".claude/CLAUDE.md".source = opencode + "/AGENTS.md";

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
    // lib.listToAttrs (
      map (
        name: lib.nameValuePair ".claude/skills/${name}" { source = opencode + "/skills/${name}"; }
      ) repoSkills
    );

    # The npx-installed skills in ~/.agents/skills aren't managed by Nix, and ~/.claude/skills can't be
    # a link to that directory: Claude Code downloads claude.ai skills into ~/.claude/skills/synced.
    # Link each one by name instead; the repo's skills above win over npx copies of the same name.
    # Runs before the link check, so a stale link never collides with a skill the repo just took over.
    home.activation.claudeCodeSkills = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      agents="$HOME/.agents/skills"
      skills="$HOME/.claude/skills"
      isRepoSkill() {
        case " ${lib.concatStringsSep " " repoSkills} " in *" $1 "*) return 0 ;; esac
        return 1
      }

      run mkdir -p "$skills"
      for link in "$skills"/*; do
        [ -L "$link" ] || continue
        case "$(readlink "$link")" in "$agents"/*) ;; *) continue ;; esac
        name=$(basename "$link")
        if [ ! -e "$link" ] || isRepoSkill "$name"; then
          run rm "$link"
        fi
      done
      for dir in "$agents"/*/; do
        [ -d "$dir" ] || continue
        name=$(basename "$dir")
        isRepoSkill "$name" && continue
        [ -e "$skills/$name" ] || [ -L "$skills/$name" ] && continue
        run ln -s "$agents/$name" "$skills/$name"
      done
    '';

  };

}
