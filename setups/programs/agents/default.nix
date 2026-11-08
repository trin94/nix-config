{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.agents;

  skills = lib.mapAttrs (name: _: ./skills + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills)
  );

  # These share a name with an npx-installed skill in ~/.agents/skills, so each client links them into a
  # skill directory it ranks above that one. The rest go to ~/.agents/skills directly.
  overrideNames = [
    "code-review"
    "tdd"
    "to-tickets"
  ];
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
      default = skills;
      description = "Every skill in this repo, by name.";
    };

    skillOverrides = mkOption {
      type = types.attrsOf types.path;
      readOnly = true;
      default = lib.getAttrs overrideNames skills;
      description = "Skills that replace npx-installed copies in ~/.agents/skills.";
    };

  };

  config = lib.mkIf cfg.enable {

    home.file = {
      ".agents/AGENTS.md".source = cfg.rules;
    }
    // lib.mapAttrs' (name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }) (
      removeAttrs skills overrideNames
    );

  };

}
