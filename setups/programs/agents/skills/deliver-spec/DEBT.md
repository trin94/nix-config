# Debt run

A debt run has no spec. You build one from the tracker's open debt tickets, then deliver it like any other spec.
These steps replace Prep steps 1 and 2. The user's prompt overrides any default below.

| Setting | Default |
| --- | --- |
| Cut size | 5 tickets |
| Growth cap | 10 tickets |

## Cut

1. Read every open debt ticket. A ticket qualifies when it names a witness ([`FIX.md`](FIX.md#debt)) that still
   holds, you can write its fix and its design (SKILL.md Prep step 1) in one line each, and it needs no input from
   the user: no decision, no measurement on their machine, no product call. Pick up to the cut size, most valuable
   first. Name the run `Debt sweep <n>`, with `<n>` one past the highest debt sweep on the tracker. Done when every
   open debt ticket is either picked or has a one-line reason for being left out.

2. Post the cut in exactly this shape and wait for the user's go. If nothing qualifies, or the benefit isn't worth a
   run, post the header and the left-out table with one line saying why, and stop. The values come from an example run:

   ```markdown
   **Cut: Debt sweep 3** · 3 tickets · cap 10 · 2 at once

   | Ticket | Fix | Design | Blocked by |
   | --- | --- | --- | --- |
   | #247 Main region copied | Use `mainRegion()` in the 4 named spots | extends page layout; interface unchanged | |
   | #234 Traces slow e2e | Drop `trace: "retain-on-failure"` | extends e2e config; interface unchanged | |
   | #248 E2e near timeout | Per-test timeout of 60 s | extends e2e config; interface unchanged | #234 |

   Left out:

   | Ticket | Why |
   | --- | --- |
   | #232 Helper names across layers | needs your naming decision |

   Reply `go`, or name tickets to swap.
   ```

3. After the go, create the spec: a spec issue and milestone titled with the run's name, prefixed the way the tracker
   names its other specs. Attach the tickets, add their designs, link their blockers, and label them the way the
   tracker marks work ready for agents. The integration branch is `spec-debt-sweep-<n>`. Continue with Prep step 3
   in SKILL.md.
