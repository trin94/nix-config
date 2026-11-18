{
  config,
  lib,
  nixConfigInputs,
  ...
}:
let
  cfg = config.myOS.programs.agents;

  repoSkills = lib.mapAttrs (name: _: ./skills + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills)
  );

  # Matt Pocock's skills used as they are, by the category folder each sits in upstream.
  upstream = category: name: "${nixConfigInputs.mattpocock-skills}/skills/${category}/${name}";
  upstreamSkills = lib.concatMapAttrs (category: names: lib.genAttrs names (upstream category)) {
    engineering = [
      "codebase-design"
      "diagnosing-bugs"
      "grill-with-docs"
      "implement"
      "improve-codebase-architecture"
      "pr"
      "prototype"
      "research"
      "retro"
      "setup-matt-pocock-skills"
      "to-spec"
      "triage"
      "wayfinder"
      "wizard"
    ];
    productivity = [
      "grill-me"
      "handoff"
      "teach"
      "writing-for-agents"
    ];
  };

  clashes = lib.attrNames (lib.intersectAttrs repoSkills upstreamSkills);
  missing = lib.attrNames (
    lib.filterAttrs (_: dir: !builtins.pathExists "${dir}/SKILL.md") upstreamSkills
  );
in
{

  options.myOS.programs.agents = with lib; {

    enable = mkEnableOption "Elias's global agent rules and skills";

    rules = mkOption {
      type = types.path;
      readOnly = true;
      default = ./AGENTS.md;
      description = "Global agent rules. Each client links them where it reads global instructions.";
    };

    skills = mkOption {
      type = types.attrsOf types.path;
      readOnly = true;
      default = upstreamSkills // repoSkills;
      description = "Every skill, the repo's own and the upstream ones, by name.";
    };

    ticketOwner = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = {
        description = "Owns one deliver-spec ticket: implementation, review and fixes. Launch only from deliver-spec.";
        prompt = ''
          You own one deliver-spec ticket. Your prompt names the brief to follow and the notes to read. Launch the
          subagents the brief asks for yourself.
        '';
      };
      description = "deliver-spec's `ticket-owner` agent. Each client defines it with the subagent rights it needs.";
    };

  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = clashes == [ ];
        message = "Skills both in the repo and upstream: ${lib.concatStringsSep ", " clashes}. Drop them from upstreamSkills.";
      }
      {
        assertion = missing == [ ];
        message = "Skills not upstream under the category given: ${lib.concatStringsSep ", " missing}.";
      }
    ];

    home.file = {
      ".agents/AGENTS.md".source = cfg.rules;
    }
    // lib.mapAttrs' (
      name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }
    ) cfg.skills;

  };

}
