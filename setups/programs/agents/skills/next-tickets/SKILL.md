---
name: next-tickets
description: Propose the next 3-5 tickets for the current project.
disable-model-invocation: true
---

# Next tickets

Propose what to build next. Read and rank only; filing the tickets stays with Elias.

## Steps

1. **Survey.** Read the project's own record of intent and state: open issues, specs, roadmap or TODO files,
   `TODO`/`FIXME` markers, recent commits, and failing or skipped checks. Done when every source the repo actually
   has is read, and each candidate ticket traces to one of them.
2. **Rank.** Order candidates by what unblocks the most, then by user-visible value, then by cost. Prefer thin
   vertical slices a single agent can finish in one session. Done when the top 3-5 are picked and each is independent
   of the ones ranked below it.
3. **Report.** One table, highest priority first:

   | # | Ticket | Why now | Done when | Evidence |
   | --- | --- | --- | --- | --- |

   *Done when* is a checkable acceptance criterion. *Evidence* is the file, issue, or commit the ticket traces to.
   Follow the table with one line per runner-up you cut and why.
