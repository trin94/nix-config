---
name: deliver-spec
description: "Implement the result of /to-spec and /to-tickets in code, review each ticket and the whole branch, and land a clean history."
disable-model-invocation: true
---

# Deliver spec

You have been provided a spec and its tickets, which describe how to implement the spec. If the spec has no tickets,
tell the user to run `/to-tickets`.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue
tracker closes work, and a history of 1-2 commits per ticket.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means
there is always a **frontier** of tickets which are ready to be grabbed.

## Role

You are the **product owner** and **tech lead** for this spec. The user is the stakeholder: they set the goal, you make
the calls inside it, and you bring them only what changes scope or a recorded decision.

As product owner you own the task graph: what's in the **cut** (the tickets this run delivers), how big a ticket may
be, and what wins when a ticket, the spec and the repo's rules disagree. Where a repo rule wins, note it on the ticket.

As tech lead you leave the codebase better than the spec found it:

- Each finding rejected by you or a fix subagent, each workaround, and each piece of debt a subagent reports either
  gets your one-line reason to drop it, or becomes a ticket linked to the spec.
- A flaky or broken gate blocks every subagent. It gets fixed at the root cause before the next merge.
- Every report carries the gate's duration. A gate that grows during the run is a finding.

## Subagents

Every subagent is **single-use**: one prompt, one report. Work that follows a report goes to a fresh subagent, pointed
at the branch and that report.

Each role has a brief next to this skill. Hand the subagent its brief by absolute path, plus **context pointers** for
what the brief can't know: the ticket or findings, the worktree and branches, the notes and spec sections to read, and
what parallel tickets touch. The brief names the report the subagent returns.

| Subagent | Brief |
| --- | --- |
| implementer | [`IMPLEMENT.md`](IMPLEMENT.md) |
| fix | [`FIX.md`](FIX.md) |
| merger | [`MERGE.md`](MERGE.md) |
| rewrite | [`REWRITE.md`](REWRITE.md) |

The **gate** is the command the repo's AGENTS.md names for "done". Without one, it is the full test suite. Every
subagent prompt names the gate and says: run each command under a time limit, and run the gate in the foreground until
it finishes.

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

5. For each ticket on the **frontier**, launch a background **implementer subagent** in its own worktree, on its own
   branch off the integration branch tip.

6. Once an implementer reports done, load the `code-review` skill from the ticket's worktree, with the integration
   branch as the fixed point and the ticket as the spec. Hand the Standards and Spec findings to a fresh **fix
   subagent** in the same worktree. Then run the Standards review again on `<reviewed-sha>..HEAD`, so code added while
   fixing gets reviewed too. Its findings, if any, go to one more fresh fix subagent, and the ticket's review ends
   there.

7. Run a **merger subagent** for the ticket, one at a time: start it only once the previous merger has reported done.
   When a merger reports a gate failure, pause merging and hand its report to a fresh fix subagent: on the ticket's
   branch when the ticket's code fails, otherwise on a new branch off the integration branch tip in its own worktree.
   Land the fix with a fresh merger, then resume.

8. After the first merge, if the issue tracker closes work through PRs or the user asked for one, push the integration
   branch and open a draft PR marked as closing the spec and tickets. Push again after every later merge.

9. If a merge changes the **frontier**, launch implementers for the new tickets.

## Final review

10. Once all tickets are merged, load the `code-review` skill on the integration branch, with main as the fixed point
    and the whole spec as the spec. This pass catches what crosses tickets: duplication, inconsistent naming, seams
    between tickets.

11. Drop findings you reject, telling the user why in one line each. Split the rest into **fix batches** of at most 3.
    Group findings that touch the same file or concern; within that, worst first. Run one fresh fix subagent per
    batch, one after another: launch the next only once the previous has reported done. Each commits straight onto
    the integration branch (no worktree, since nothing else runs).

## Land

12. Run a fresh **rewrite subagent** on the integration branch.

13. Move what the next spec should know from the notes directory into the tracker, where the next spec's agents will
    find it. The notes directory dies with the run.

14. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes
    work, and report the integration branch.

15. Remove every worktree this run created and delete its branch.
