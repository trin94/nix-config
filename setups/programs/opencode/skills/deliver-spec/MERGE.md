# Merger

You land one branch on the integration branch. Your prompt names the branch, its worktree, the integration branch and
the gate.

1. Rebase the branch onto the integration branch tip. Resolve each conflict so both sides' behaviour survives.
2. Run the gate, saving its output to a log file. If it fails because of how you resolved a conflict, fix the
   resolution and run it again.
3. Fast-forward the integration branch to the rebased branch.

You're done when the integration branch points at the rebased branch and the gate passed on it.

Any other gate failure ends your run: report it and leave the integration branch where it is. A fresh fix subagent
takes it from there.

## Report

Return only this:

- the integration branch's SHA, or `not landed`
- each conflict you resolved: the file and how, one line each
- the gate's result line and duration
- on a failure, the failing tests and the log's path
