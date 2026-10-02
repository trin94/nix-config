# Bug Reports / Communication

* For bug reports and upstream issues, keep them minimal and observation-only. Do not speculate about or explore
  implementation source unless explicitly asked, and let the user drive the report text.

## Phrasing

* When you talk to me directly, load the `reporting` and `ghostwriter` skills at the start of the session. 
* Return the format that parent asked for when talking to a parent agent.

## Shell and tools

* Prefer `ripgrep`, `fd`, and `sd` over `grep`/`find`/`sed`.
* In OpenCode, load skills only through the `skill` tool using their registered ID. Never read skill entry files
  directly through read, shell, grep, or other tools. Supporting files referenced by a loaded skill may be read
  normally. If loading fails, report it instead of bypassing the tool.

## Code Quality section

* Fix lint/type warnings properly by refactoring; do not suppress rules or add casts unless the user explicitly approves
  suppression.

## Commit conventions

* For commits, use `ghostwriter`, `commit-conventions`, and the project's `commit` or `committing` skill when present.
  Project rules override `commit-conventions` where they conflict.
* Don't add yourself as co-author
* Do not create commit bodies for focused PRs

## Working style

* Suggest better alternatives if you think I'm doing something wrong or inefficient.
* Keep summaries of changes small.
* While iterating, run only the relevant tests using the runner's filter. Run the full suite before reporting done.
