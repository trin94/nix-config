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

Communication to and from subagents should be sparse. Hand subagents **context pointers** (to the spec, tickets, the
notes directory, and previous commits) and let them read the material themselves.

## Prep

1. Read the spec and tickets. Done when you can name every ticket's blockers and the current **frontier**.

2. (optional) If tickets need codebase or external-doc context their text doesn't carry, run an **exploration subagent**
   that saves markdown notes to `$TMPDIR/<spec-slug>-notes/`. Pass that path to every later subagent. This lets
   **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch.

## Ticket loop

4. For each ticket on the **frontier**, launch a background **implementer subagent** in its own worktree on its own
   branch. Each implementer subagent:
   - confirms its worktree is based on the integration branch before starting, and resets onto it if not;
   - loads the `tdd` skill to build the ticket;
   - rebases its branch onto the integration branch tip before reporting done

5. Once an **implementer subagent** completes, load the `code-review` skill from the ticket's worktree, with the
   integration branch as the fixed point and the ticket as the spec. Continue the same implementer session with the
   Standards and Spec findings. It fixes each finding or rejects it with a one-line reason, and is done when every
   finding is accounted for and the full test suite passes.

   Then run a **merger subagent**, one at a time: start it only once the previous merger has reported done. It rebases
   the ticket branch onto the integration branch tip, resolves any conflicts, and is done when the full test suite
   passes on the rebased branch and the integration branch is fast-forwarded to it.

   After the first merge, if the issue tracker closes work through PRs or the user asked for one, push the integration
   branch and open a draft PR marked as closing the spec and tickets. Push again after every later merge.

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new
   tickets.

## Final review

7. Once all tickets are merged, load the `code-review` skill on the integration branch, with main as the fixed point and
   the whole spec as the spec. This pass catches what crosses tickets: duplication, inconsistent naming, seams between
   tickets.

8. Drop findings you reject, telling the user why in one line each. Split the rest into **fix batches** of at most 3.
   Group findings that touch the same file or concern; within that, worst first. Run one fresh **fix subagent** per
   batch, one after another: launch the next only once the previous has reported done. Each fix subagent gets only its
   batch, commits straight onto the integration branch (no worktree, since nothing else runs), and is done when every
   finding in its batch is fixed and the full test suite passes.

## Land

9. Run a fresh **rewrite subagent** on the integration branch, pointed at this skill's [`REWRITE.md`](REWRITE.md) by its
   absolute path.

10. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes
    work, and report the integration branch.

11. Remove all **implementer subagent** worktrees and delete their ticket branches.
