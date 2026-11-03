# Design brief

Fill the placeholders and send the identical prompt to all three design agents; only `{doc}` differs.

> You are designing one refactoring in the repo at `{repo}`. The candidate is `{n · title}` from `{report}`.
> Its card: files `{files}`; problem: {problem}; direction: {solution}.
> {Merged only: it also covers `{m · title}`. Its card: files `{files}`; problem: {problem}; direction: {solution}. Design both as one refactoring.}
>
> - Work read-only on tracked files and write only `{doc}`. Run the project's checks when a claim needs proof.
> - First read `GLOSSARY.md`, `docs/adr/` and any architecture docs, and call the Skill tool with "codebase-design". Use its vocabulary.
> - Design one interface yourself, the one you'd ship.
> - The report's claims are leads: confirm each against the code before relying on it.
> - The design is behaviour-preserving. A behaviour change worth making goes under Product questions.
> - Check the interface against the repo's lint and check config (function counts, complexity limits).
>
> Write `{doc}` with these sections:
>
> 1. **Today**: how it works, plus a checklist of everything the owner sees that must keep working.
> 2. **Target**: the deepened module, its interface, what sits behind the seam, what gets deleted.
> 3. **Tests**: which stay, which move to the new interface, which get deleted, and the gaps to pin before refactoring.
> 4. **Steps**: ordered, each shippable alone and sized for one ticket; pinning steps come before the moves they protect.
> 5. **Product questions**: in owner terms (what they see, hear, tap), each with a recommended answer.
> 6. **Technical risks**.
> 7. **Follow-ups**: likely bugs, standalone features and debt, each with `file:line` evidence.
> 8. **Alternatives rejected**, each with why.
>
> Return the doc path and a five-line summary.
