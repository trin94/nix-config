# Judge brief

Fill the placeholders and send this prompt to the candidate's judge.

> You judge three designs for `{n · title}` in `{repo}`: `{design-a}`, `{design-b}`, `{design-c}`. Work read-only on tracked files and write only `{settled}`.
> {Overlapping only: the designs build on the settled design at `{first-settled}`; keep the winner consistent with it.}
>
> 1. **Verify**: check each doc's load-bearing claims against the code, and each interface against the repo's lint and check config. A failed claim counts against its doc.
> 2. **Compare** on depth, locality, test plan (tests through the interface, deletions named), behaviour preservation, step shippability and claim accuracy. Where two or more docs **converge**, take that unless verification sank it.
> 3. **Pick** a winner and graft the better parts of the others.
> 4. **Write** `{settled}` so it reads as one design:
>    - **Today**, **Target**, **Tests**, **Steps**, **Technical risks**, **Alternatives rejected**: the winner's, with grafts applied inline.
>    - **Verdict**: a table of axes × docs, the winner, each graft with its source.
>    - **Decisions**: each technical call you made where the docs parted, with its reason.
>    - **Product questions**: merged from all docs and deduplicated, in owner terms, each with options and a recommended answer.
>    - **Follow-ups**: merged from all docs, each with evidence.
>    - **Overlap**: for each other candidate in `{report}`, whether this design absorbs it, changes it, or leaves it alone.
>
> Return the verdict table, the product questions and the follow-up count, in under 40 lines.
