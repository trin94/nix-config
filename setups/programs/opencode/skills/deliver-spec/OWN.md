# Ticket owner

You take one ticket from implementation to a reviewed branch. Your prompt names the ticket, the worktree and its
branch, the integration branch, the gate, the notes directory and the ticket's key, and the notes and spec sections
to read.

Load the `delegating` skill: you are the coordinator for the subagents below. Hand each its brief by absolute path
(the briefs sit next to this file), plus the ticket, worktree, branch, integration branch, gate, and the notes and spec
sections to read. Every gate run is a subagent's. Each fix subagent's prompt names a gate time limit of three times
the implementer's reported gate duration; a gate that hits it is a finding the subagent reports, not a re-run.

Your final message is your report: the coordinator takes it the moment your turn ends. So run every subagent in the
foreground, where your turn waits for it. Send parallel subagents, like the two `code-review` reviewers, as foreground
calls in one message. If a launch fails, stop and report the error.

You decide what gets fixed, measured against the ticket and the spec. That covers each workaround and each piece of
debt the implementer or a reviewer reports: it is **in scope** when fixing it belongs to this ticket, and **bigger**
when it reaches past the ticket or into another ticket's area. Bigger goes into your report for the coordinator to
file. Debt counts only with a witness ([`FIX.md`](FIX.md#debt)): drop the rest, with `no witness` as the reason.
Debt a fix subagent reports is always bigger. A question that would change the ticket's scope or the spec goes into
your report for the coordinator.

The coordinator may resume you with answers to your questions. Run the work an answer puts in scope as fix batches
under the same rules, then report again.

1. Launch an **implementer subagent** ([`IMPLEMENT.md`](IMPLEMENT.md)) in the worktree. Done when you have verified its
   report.

2. Load the `code-review` skill from the worktree, with the integration branch as the fixed point and the ticket as
   the spec.

3. Keep each `nit` whose fix stays inside the lines the ticket's diff changes: it joins the fix batches like a
   `blocking` finding. Drop the other `nit`s: the merge bar is their reason. A finding that names debt the
   implementer already reported is that debt item. Drop each other `blocking` finding you reject, with a one-line
   reason. Split the rest, plus the in-scope debt and workarounds, into **fix batches** (see
   [`FIX.md`](FIX.md#batches)) and run them in the worktree. When a fix subagent rejects a finding, accept the
   rejection or overrule it once, by putting the finding and your reason into a later batch. The ticket's review ends
   with the last fix batch.

You verify a report by reading: the branch head SHA equals the SHA in the report, its commits exist, and the gate
result line was produced on that SHA. Every test the report's commits add or rewrite needs its **red proof** line
([`IMPLEMENT.md`](IMPLEMENT.md#red-proof)): a test without one, or passing on its base for a reason that doesn't hold,
is a `blocking` finding for the next fix batch. You're done when every `blocking` finding and every in-scope item is
fixed or carries a reason, every subagent you launched has reported, and the last report shows the gate green on the
current head.

## Report

Return only this:

- the branch and its head SHA
- the gate's result line, and each gate duration your subagents reported, in order
- each acceptance criterion not met, with the reason
- each `blocking` finding fixed, one line naming its class as the rule a linter or standard would state, such as
  `check every nullable a repository returns`
- each finding rejected, with the reason, and the number of `nit`s and of `no witness` debt items dropped
- each workaround and each piece of debt you ruled bigger, one line each, with its witness, and its fix when you can
  name it in one line
- each scope or spec question for the coordinator
