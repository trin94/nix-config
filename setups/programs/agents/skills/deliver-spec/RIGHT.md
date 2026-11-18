# Make it right

You give one ticket's working branch its second draft. Your prompt names the ticket, the worktree and its branch, the
integration branch, the gate, and the notes and spec sections to read.

The branch already **makes it work**: its gate passes, which meets the first of the Four Rules of Simple Design. You
**make it right**: read the ticket's diff cold, as its next maintainer, and judge whether the solution is **good
enough** wherever it should live, in the ticket's modules or beyond, such as an existing module that should own the
behaviour. Good enough is a full, successful outcome, and a file you leave as it is reaches it. A rewrite serves one
of the other three rules: reveals intention, no duplication, fewest elements.

1. Read the notes, the ticket and the spec sections your prompt names, then `git diff <integration branch>...HEAD`.
   The files in that diff are the ones you account for.
2. Judge each file `good enough`, or rewrite it and commit the rewrite on top of the branch. Tests change shape
   freely: they move, merge, or follow a reshaped interface, while every behaviour a test pinned before stays pinned.
   Each better solution and each piece of debt ([`FIX.md`](FIX.md#debt)) you find is **in scope** or **bigger**
   ([`OWN.md`](OWN.md#scope)). In scope goes into your rewrite. When an in-scope solution belongs in a module or needs
   an interface the ticket's design doesn't name, that is a **design gap**: stop there, reset the worktree to the head
   you started on, and report it. Bigger stays off the branch, and the ticket lands without it: report it as debt
   with its witness.
3. When you rewrote anything, run the **red proof** ([`IMPLEMENT.md`](IMPLEMENT.md#red-proof)) on the tests your
   commits add or rewrite, with `git merge-base <integration branch> HEAD` as the base: its step 1 covers every
   production file the ticket's diff changes or adds. Then run the gate.

You're done when every file in the diff is `good enough` or `rewritten`, every acceptance criterion names the test
that pins it or `no test` with the reason, and either your head is the one you started on or the red proof is done and
the gate passes on your head; or when you have reported a design gap.

## Report

Return only this:

- the design gap, when you stopped on one: what the design names, the module or interface the better solution needs,
  and the code that shows it; nothing else below
- the branch and its head SHA
- the gate's result line and duration, or `no rewrites`
- each file in the diff: `good enough`, or `rewritten` with the rule it serves and a one-line why
- each acceptance criterion with the test that pins it, or `no test` and why
- each test your commits add or rewrite, with its failure line from the red proof or its reason for passing
- each piece of debt you ruled bigger, one line each with its witness
