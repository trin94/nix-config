---
name: deliver-spec
description: "Implement the result of /to-spec and /to-tickets in code, review each ticket and the whole branch, and land a clean history."
disable-model-invocation: true
---

# Deliver spec

You have been provided a spec and its tickets, which describe how to implement the spec. If the spec has no tickets,
tell the user to run `/to-tickets`.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

When the user asks for a **debt run** and gives no spec, follow [`DEBT.md`](DEBT.md). It builds the spec and changes
Prep.

The goal is the entire spec implemented on a single **integration branch** and merged into main, with every ticket
resolved the way the issue tracker closes work, and a history of 1-2 commits per ticket.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means
there is always a **frontier** of tickets which are ready to be grabbed.

## Role

You are the **product owner** and **tech lead** for this spec. The user is the stakeholder: they set the goal and
approve the **cut**. You make every other call inside it, autonomously. Their view of the run is your **progress
reports**. Stop for the user only to approve the cut, or when the run cannot continue without them, such as missing
access.

As product owner you own the task graph: what's in the **cut** (the tickets this run delivers), how big a ticket may
be, and what wins when a ticket, the spec and the repo's rules disagree. Where a repo rule wins, note it on the ticket.

As tech lead you deliver the spec with every loose end accounted for:

- Each workaround and each piece of debt a subagent reports is either **in scope**, when fixing it belongs to
  delivering the spec, or bigger. Debt counts only with a witness ([`FIX.md`](FIX.md#debt)): drop the rest. In scope
  goes into a fix batch on the branch it was found on. Bigger becomes a comment on an open ticket outside the cut that
  already names the same fix, or, when none does, a ticket linked to the spec and labelled `needs-triage`. Either one
  states the witness. A ticket owner makes this call for its own ticket and reports the bigger items.
- When the run has a **growth cap** (the most tickets the cut may grow to, set by the user or by
  [`DEBT.md`](DEBT.md)), every item this section would file `needs-triage` whose fix is clear and needs no input from
  the user **joins the cut** instead: it becomes a ticket in the spec, like the others, until the cut reaches the cap.
  Joining needs no go from the user. Items found past the cap, or from step 10 on, become a comment or a
  `needs-triage` ticket.
- Each `blocking` finding rejected by you, a ticket owner or a fix subagent gets your one-line reason on its ticket (on
  the spec for final-review findings). When it is real but bigger than the spec and has a witness, it is a bigger item
  by the first rule instead.
- A flaky test the cut didn't touch is quarantined and filed as a bigger item, and rollups continue. A broken gate, or a
  flake the cut introduced, is fixed at the root cause before the next rollup.
- Every subagent report carries the gate's duration. A gate that grows during the run is a finding.

## Progress report

Run **silent**. The user sees every word you write outside a tool call, so text goes only at the end of a turn: a cut
question, a stop named above, or a **progress report**. Tool calls go out bare, with no text announcing them. When
the user asks something mid-run, answer it in one line above the report.

From the go on the cut onward, end every turn on a progress report. While subagents run, its last line is `⏳ waiting`.
Every report has this exact shape, with nothing else around it but that line and that answer, in place of the
`reporting` skill's format;
the values come from an example run:

```markdown
**Progress: <spec title>** · 2/6 merged

Branch: `spec-config` · PR: #30 (draft)

| Ticket | Status | Remark |
| --- | --- | --- |
| #12 Parse config file | ✅ | |
| #13 Validate config | ✅ | |
| #14 Reload on change | 🔨 | |
| #17 Config schema | 📦 | |
| #15 Config CLI flag | ⏭️ | after #14 |
| #16 Config docs | ⏳ | after #15, #17 |

Filed:

- #31 Config loader duplicates path logic
- #32 Gate runs integration tests twice
```

- **Title**: `Progress`, or `Delivered` in the report at the end of Land, once step 15 is done; then the spec's title,
  then merged tickets over tickets in the cut. When the run has a growth cap, append
  `· cap <tickets in the cut>/<cap>`, for example `· 2/6 merged · cap 6/10`. In a debt run, the `Delivered` title
  ends with `· debt <before> → <after>`: the number of open debt tickets when you post the cut, and after step 15.
- **PR**: `#<n> (draft)`, `#<n> (ready)` once marked ready in step 14, `#<n> (merged)` once merged into main, or
  `none` before the PR exists.
- **Ticket rows**: every ticket in the cut, in task-graph order, ties by ticket number.
- **Status**: ✅ merged, 📦 done with step 6 and not yet merged, 🔨 launched and not yet done with step 6, ⏭️ next
  (not launched, every blocker is ✅, 📦 or 🔨), ⏳ queued (the rest).
- **Remark**: `gate failure` on every ticket a rollup carries while its gate fix runs, `in scope` for a resumed
  owner; for ⏭️ and ⏳, the blockers not yet merged as `after <tickets>`; otherwise empty.
- **Filed**: every `needs-triage` ticket this run has filed so far, then every comment it added to an open ticket as
  `#<n> (comment) <item>`, one bullet each in order, or `Filed: none`. A ticket that joined the cut is a row, not a
  Filed bullet.

Findings, rejections, gate results and subagent reports are your working material.

## Subagents

Load the `delegating` skill. Its rules on subagents, the **gate**, and verifying reports hold for every subagent below.

Each role has a brief next to this skill. Hand the subagent its brief by absolute path, plus the ticket or findings
and the notes and spec sections to read. The brief names the report the subagent returns.

| Subagent | Brief |
| --- | --- |
| ticket owner | [`OWN.md`](OWN.md) |
| fix | [`FIX.md`](FIX.md) |
| merger | [`MERGE.md`](MERGE.md) |
| rewrite | [`REWRITE.md`](REWRITE.md) |
| seams reviewer | [`SEAMS.md`](SEAMS.md) |

## Prep

1. Read the spec and tickets. Done when you can name every ticket's blockers and the current **frontier**.

2. Propose the **cut** to the user, splitting any ticket too big for one implementer. Wait for their go, then make the
   splits in the tracker.

3. Save the spec and each ticket in the cut as markdown in `$TMPDIR/<spec-slug>-notes/` (`spec.md`, `<ticket>.md`), so
   subagents read the spec by section instead of fetching all of it from the tracker. If tickets need codebase or
   external-doc context their text doesn't carry, run an **exploration subagent** that adds notes to the same
   directory.

4. Create the integration branch.

## Ticket loop

5. Run at most 2 ticket owners at once, unless the user sets another number. While a slot is free, take the next
   ticket on the **frontier** in task-graph order, create a worktree on its own branch off the integration branch tip,
   and launch a background **ticket owner** in it as the `ticket-owner` agent. The built-in `general` agent can't
   launch the implementer, review and fix subagents the owner runs. Its prompt names the notes directory's absolute
   path and the
   ticket's key, the `<ticket>` in `<ticket>.md`. Keep each owner's session ID.

6. Once a ticket owner reports done, turn each item it ruled bigger into a comment on an open ticket, a ticket that
   joins the cut, or a `needs-triage` ticket, by the Role rule. Attach each joined ticket to the spec like the cut's
   other tickets, blocked by the ticket it was found on when its fix touches that ticket's change, and save it as
   `<ticket>.md` in the notes directory. Turn each of its scope and spec questions into an **in scope** item, a
   `needs-triage` ticket, or a cut change for the user. Append each finding class it reports, with the ticket, to
   `findings.md` in the notes directory. Resume the owner in the background by its session ID with the in-scope
   items. Done when the owner reports with no in-scope item or cut change for the ticket left open.

7. Merge in **rollups**, one at a time. Whenever no rollup is open (its merger or its gate fix still running) and a
   ticket is done with step 6, create a worktree detached at the integration branch tip and launch a **merger
   subagent** in it with every ticket done with step 6 and not yet merged, in task-graph order. When a merger reports a
   gate failure, hand its report to a fresh fix subagent on the rollup branch in that worktree, judged against the
   tickets the rollup carries. A rollup of a single branch whose history contains the integration branch tip
   (`git merge-base --is-ancestor`) was gated on that exact head, by its owner or by the fix subagent: fast-forward the
   integration branch to it yourself, without a merger.

8. After the first rollup lands, push the integration branch and open a draft PR marked as closing the spec and
   tickets. Push again after every later rollup.

9. When an owner is done with step 6, or a rollup changes the **frontier**, fill free slots by step 5.

## Final review

10. Once all tickets are merged, launch a **seams reviewer** on the integration branch, with main as the fixed point.

11. Each seam is **in scope** or bigger, by the Role rule. Each **finding class** that two or more tickets name in
    `findings.md` is in scope too, as an item naming the class and its tickets. Split the in-scope items into **fix
    batches** (see [`FIX.md`](FIX.md#batches)) and run them. Each commits straight onto the integration branch (no
    worktree, since nothing else runs).

## Land

12. Run a fresh **rewrite subagent** on the integration branch.

13. Move what the next spec should know from the notes directory into the tracker, where the next spec's agents will
    find it. The notes directory dies with the run.

14. Mark the PR ready for review. Once CI passes, merge it into main the way the repo merges PRs. Hand a CI failure to
    a fresh fix subagent on the integration branch. Done when the PR is merged and every ticket in the cut is closed.

15. Remove every worktree this run created and delete its branch with `git branch -D`: rollups cherry-pick, so ticket
    branches never show as merged.

______________________________________________________________________

Adapted from Matt Pocock's implement-spec skill, MIT. See [`CREDITS.md`](CREDITS.md).
