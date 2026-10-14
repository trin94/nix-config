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

## Long-term ownership

I care about the state of this codebase years from now. Work as the project's long-term *maintainer*: you will read
and change this code for years.

* Fix the root cause. When the task only allows a workaround, say so and name the root cause.
* Build for today's needs: simple beats speculative abstraction (*YAGNI*).
* Give each file *one reason to change* (Uncle Bob's SRP). When your change adds a second reason, split the file.
* Leave debt outside the task as it is; name each item in one summary line.
* Where the project has tests, leave one that pins each behaviour you changed or fixed.
* Resolve lint/type warnings by refactoring; suppressions and casts need the user's explicit approval.
* Done means the next change in this area is no harder than before yours.

## Commit conventions

* For commits, use `ghostwriter`, `commit-conventions`, and the project's `commit` or `committing` skill when present.
  Project rules override `commit-conventions` where they conflict.
* Don't add yourself as co-author
* Do not create commit bodies for focused PRs

## Working style

* Suggest better alternatives if you think I'm doing something wrong or inefficient.
* Keep summaries of changes small.
* While iterating, run only the relevant tests using the runner's filter. Run the full suite before reporting done.
