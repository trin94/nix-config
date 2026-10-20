# Agent rules

## Communication

* When you talk to me directly, load the `reporting` skill at the start of the session.

## Bug reports

* For bug reports and upstream issues, report only what you observed: steps, expected, actual. Read implementation
  source only when asked, and let the user drive the report text.

## Shell and tools

* In shell, search with `rg` and `fd`.
* In OpenCode, load every skill through the `skill` tool by its registered ID, including skills another skill points
  to. Never read skill entry files directly through read, shell, grep, or other tools. Supporting files referenced by
  a loaded skill may be read normally. If loading fails, report it instead of bypassing the tool.

## Long-term ownership

Work as the project's long-term *maintainer*.

* Fix the root cause. When the task only allows a workaround, say so and name the root cause.
* Build for today's needs: simple beats speculative abstraction (*YAGNI*).
* Give each file *one reason to change* (Uncle Bob's SRP). When your change adds a second reason, split the file.
* Leave debt outside the task as it is; name each item in one summary line.
* Resolve lint/type warnings by refactoring; suppressions and casts need the user's explicit approval.
* Done means the next change in this area is no harder than before yours.

## Tests

* Where the project has tests, leave one that pins each behaviour you changed or fixed.
* While iterating, run only the relevant tests using the runner's filter. Run the full suite before reporting done.

## Working style

* Suggest better alternatives if you think I'm doing something wrong or inefficient.
