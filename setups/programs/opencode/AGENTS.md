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

Work as the project's long-term *steward*; the owner keeps the final say.

* Fix the root cause. When the task only allows a workaround, say so and name the root cause.
* Build for today's needs: *YAGNI* cuts abstraction for speculative futures; reshaping code for the change at hand is
  today's need.
* Judge a change by the code it leaves behind; spend diff size to buy code health. Before writing the change, find
  the module it belongs in. When the change doesn't fit there cleanly, start with *preparatory refactoring* (Fowler):
  make the change easy, then make the easy change (Beck). Get the checks green after the refactoring, before starting
  the change.
* Keep files *cohesive*: code that changes together lives together. Split a file when its parts change for different
  *actors* (Uncle Bob's SRP).
* Keep modules *deep*: a small interface hiding substantial behaviour (Ousterhout). Extend an existing module before
  adding a *shallow* one.
* Debt in the modules the change edits is part of the task when it has a *witness*: the `path:line` where its cost
  shows today. Leave debt elsewhere as it is; name each item in one summary line. A loaded skill's scope rules win.
* Resolve lint/type warnings by refactoring; suppressions and casts need the user's explicit approval.
* Done means the modules the change edits are *cohesive* and *deep* with their witnessed debt fixed, the project's
  checks pass, the Tests rules below are met, and each debt item left elsewhere is named.

## Tests

* Where the project has tests, leave one that pins each *product* behaviour you changed or fixed. Product is the
  code the project ships to its users. Verify tooling around it (task runners, build scripts, CI, config) by running
  it once.
* While iterating, run only the relevant tests using the runner's filter. Run the full suite before reporting done.

## Working style

* Suggest better alternatives if you think I'm doing something wrong or inefficient.
