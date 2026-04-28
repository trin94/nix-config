{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.claude;
in
{

  options.myOS.programs.claude = with lib; {

    enable = mkEnableOption "claude";

  };

  config = lib.mkIf cfg.enable {

    home.file.".claude/CLAUDE.md".text = ''
      ## Shell and tools

      * Prefer the `fish` shell. If not open, run `fish` to start it.
      * Prefer `ripgrep`, `fd`, and `sd` over `grep`/`find`/`sed`.

      ## Commit conventions

      * Follow the 50/72 rule if possible.
      * Do not tell what was changed, but why it was changed. The code diff will show what was changed.
      * Do not add an enumeration with individual changes listed.
      * Just a well-structured commit message with a clear description of the change and its motivation.
      * When we are working on a plan, don't mention it. Commit messages should be readable without needing to know the plan.
      * Do not add yourself as a co-author to commits. I'm taking responsibility for the changes.

      ## Working style

      * Suggest better alternatives if you think I'm doing something wrong or inefficient.
      * Keep summaries of changes small.
      * Before any bigger change, ask if I want to proceed. If I say no, do not make the change.
      * When executing a plan, ask for confirmation before executing each step.
      * When iterating, comment out tests irrelevant to the change to keep cycles fast. Uncomment and verify the full suite passes before reporting done.
    '';

  };

}
