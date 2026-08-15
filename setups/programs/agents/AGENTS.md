# Bug Reports / Communication

* For bug reports and upstream issues, keep them minimal and observation-only. Do not speculate about or explore
  implementation source unless explicitly asked, and let the user drive the report text.

## Phrasing

* When you talk to me directly, read `~/.agents/skills/reporting/SKILL.md` at the start of the session and use the
  `ghostwriter` skill. As a subagent you are talking to a parent agent instead, so return the format that parent asked
  for.

## Shell and tools

* Prefer `ripgrep`, `fd`, and `sd` over `grep`/`find`/`sed`.

## Code Quality section

* Fix lint/type warnings properly by refactoring; do not suppress rules or add casts unless the user explicitly approves
  suppression.

## Commit conventions

* For commits, use `ghostwriter`, `commit-conventions`, and the project's `commit` or `committing` skill when present.
  Project rules override `commit-conventions` where they conflict.

## Working style

* Suggest better alternatives if you think I'm doing something wrong or inefficient.
* Keep summaries of changes small.
* Before changes touching more than ~3 files or any destructive operation, ask if I want to proceed.
* While iterating, run only the relevant tests using the runner's filter. Run the full suite before reporting done.
