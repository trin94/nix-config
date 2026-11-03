---
name: fruppi-deepen-codebase
description: Find deepening opportunities, design the owner's pick three times over, and settle it with the owner, ready for to-spec.
disable-model-invocation: true
---

# Deepen Codebase

Surface architectural friction, propose **deepening opportunities** (refactors that turn shallow modules into deep ones), and carry the owner's pick to a **settled doc**: one design that `to-spec` turns into a spec without further questions. The aim is testability and AI-navigability.

This skill is _informed_ by the project's domain model and built on a shared design vocabulary:

- Call the Skill tool with "codebase-design" for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles (the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real"). Use these terms exactly in every suggestion, and don't drift into "component," "service," "API," or "boundary."
- The domain language in `GLOSSARY.md` gives names to good seams; ADRs in `docs/adr/` record decisions this skill should not re-litigate.
- Call the Skill tool with "delegating" for briefing, running and verifying subagents.

## Process

### 1. Explore

**Re-entry:** if the user names a candidate from an existing report in `.scratch/` (the one they name, else the newest), skip to step 3. If its `.scratch/<slug>/` already exists, resume at the first step whose "Done when" isn't met.

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log --oneline`) to find the codebase's hot spots, the files and areas that keep coming up, and let those paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read the project's domain glossary (`GLOSSARY.md`) and any ADRs in the area you're touching first.

Then spawn a sub-agent to walk the codebase. Don't follow rigid heuristics; explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

A module is **good enough** when a typical change lands in it alone and its tests run through its interface. Leave good-enough modules out of the report, however they could be shaped better.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to `.scratch/architecture-review-<YYYYMMDD-HHMM>.html` in the repo root, so later sessions can pick up its candidates. If `git check-ignore -q .scratch/` fails, add `.scratch/` to `.git/info/exclude`. Open it for the user (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and **Mermaid via CDN** for every diagram. Number each candidate (`1 · <title>`) so the user can name it. Each candidate gets a **before/after visualisation**.

For each candidate, render a card with:

- **Files**: which files/modules are involved
- **Problem**: why the current architecture is causing friction
- **Solution**: plain English description of what would change
- **Benefits**: explained in terms of locality and leverage, and how tests would improve
- **Cost**: what the refactor touches: call sites, tests rewritten, risky paths
- **Before / After diagram**: side-by-side, illustrating the shallowness and the deepening
- **Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge; `Strong` only when the benefits clearly outweigh the cost

End the report with a **Top recommendation** section: which `Strong` candidate you'd tackle first and why. With no `Strong` candidate, it says no refactor is worth doing now.

**Use GLOSSARY.md vocabulary for the domain, and the `/codebase-design` vocabulary for the architecture.** If `GLOSSARY.md` defines "Order," talk about "the Order intake module," not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (e.g. a warning callout: _"contradicts ADR-0007, but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, theme, and diagram patterns.

The report names problems and directions; interfaces come from the design agents in step 4. After the file is written, ask the user: "Which one or two would you like to explore?" With no top recommendation, tell the user and stop instead.

### 3. Check overlap

With two picks, compare their files and the modules whose interface each would change:

- **Independent**: no shared module, and neither design is likely to reshape the other. Each pick is its own candidate.
- **Overlapping**: merge both into one candidate, so the owner settles them together.

Give each candidate a slug, `<n>-<kebab-case title>` (merged: `<n>+<m>-<kebab-case title>`), and create `.scratch/<slug>/`. Fill every path placeholder in the briefs with an absolute path.

Done when each candidate has its slug directory, and two picks have a verdict.

### 4. Design three times

Per candidate, launch three general-purpose subagents in the background, each with the same prompt from [DESIGN-BRIEF.md](DESIGN-BRIEF.md) and its own output, `.scratch/<slug>/design-{a,b,c}.md`. Give them no angles: the designs **converge** on their own, and the judge decides where they part. With two candidates, launch all six at once.

Done when all three docs exist.

### 5. Judge

Per candidate, launch one general-purpose judge subagent with the prompt from [JUDGE-BRIEF.md](JUDGE-BRIEF.md). It writes `.scratch/<slug>/settled.md` and returns the verdict, product questions and follow-up count.

With two candidates, show both verdict tables side by side and name the one to settle first, with why.

Done when every `settled.md` exists and you have seen every claim you relay.

### 6. Grill on product questions

Steps 6 to 9 run for one candidate at a time, starting with the one named in step 5.

Call the Skill tool with "grilling". Ask **product questions** only: what the owner sees, hears or taps, phrased in those terms. Decide technical questions yourself and log each with its reason under Decisions in `settled.md`; put them to the owner only when they ask for that. With no product questions, skip the grilling and say so.

Refactor steps are **behaviour-preserving**. An answer that changes behaviour becomes its own step in `settled.md`, pinned by a test first, when it shrinks the design; otherwise add it under Follow-ups in `settled.md`.

Write each answer under Decisions in `settled.md` as it lands. Side effects happen inline; call the Skill tool with "domain-modeling" to keep the domain model current as you go:

- **Naming a deepened module after a concept not in `GLOSSARY.md`?** Add the term to `GLOSSARY.md`. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `GLOSSARY.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing; skip ephemeral reasons ("not worth it right now") and self-evident ones.

Done when every product question in `settled.md` has the owner's answer and the owner confirms the shared understanding. A rejected candidate is done too: record the reason in `settled.md`; steps 7 to 9 still run.

### 7. File follow-ups

**Follow-ups** are likely bugs, standalone features and debt from `settled.md`. Read `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md`, then file each with the `needs-triage` role as a self-contained issue: what, today, evidence, and the candidate it surfaced in. Record each number in `settled.md`. Without those docs, keep the follow-ups in `settled.md` and say so.

Done when every follow-up has an issue number or the note.

### 8. Close

Report:

- the `settled.md` path, or the rejection reason
- which remaining report candidates it absorbs, changes or leaves alone
- filed follow-ups

End with: run `to-spec`, then `to-tickets`, on the `settled.md`.

### 9. Hand off

With another candidate left, stop here and print the line that resumes it in a fresh session, absolute paths filled in:

```sh
opencode <repo> --prompt '@fruppi-deepen-codebase <n · title> from <report>'
```

The owner says "continue" or pastes the line. Either way, resume that candidate at its first step whose "Done when" isn't met.

Done when the owner is back, or no candidate is left.

______________________________________________________________________

Copied from Matt Pocock's improve-codebase-architecture skill, MIT. See [`CREDITS.md`](CREDITS.md).
