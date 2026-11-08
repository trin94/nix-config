# Seams review

You review the integration branch for what crosses tickets. Your prompt names the branch and where it's checked out,
the fixed point, and the notes directory with `spec.md` and one `<ticket>.md` per ticket.

Per-ticket review already ran on every ticket against its own text and the repo's standards. You look only between
tickets. A **seam** is one of:

- a helper, type or fixture that two tickets each wrote their own version of
- a later ticket's commit that invalidates an earlier ticket's test, fixture or doc
- one concept under two names across tickets

Read `git log --oneline <fixed point>..HEAD` to map commits to tickets, then diff across the ticket boundaries.

You're done when every pair of tickets that touch the same files is checked.

## Report

Return only one line per seam: the tickets involved, the files, and what one fix would look like. No severity.
`No seams` when there are none.
