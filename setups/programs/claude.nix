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

      * Prefer `ripgrep`, `fd`, and `sd` over `grep`/`find`/`sed`.

      ## Commit conventions

      * Use a sub agent to generate commit messages based on the diff alone.
      * Follow the 50/72 rule if possible.
      * The body should explain why the change was made, not what changed. The code diff will show what was changed.
      * Do not add an enumeration with individual changes listed.
      * Write in plain, everyday English: clear and short, no fancy or uncommon words. Match the casual tone typical of open source commit logs.
      * When we are working on a plan, don't mention it. Commit messages should be readable without needing to know the plan.
      * Do not add yourself as a co-author to commits. I'm taking responsibility for the changes.

      ## Working style

      * Suggest better alternatives if you think I'm doing something wrong or inefficient.
      * Keep summaries of changes small.
      * Before changes touching more than ~3 files or any destructive operation, ask if I want to proceed.
      * When executing a plan, ask for confirmation before executing each step.
      * While iterating, run only the relevant tests using the runner's filter; run the full suite before reporting done.
    '';

  };

}
