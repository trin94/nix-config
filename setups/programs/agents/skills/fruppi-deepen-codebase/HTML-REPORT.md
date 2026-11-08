# HTML Report Format

The architectural review is rendered as a single self-contained HTML file in `.scratch/`. Tailwind and Mermaid both come from CDNs. Mermaid draws every diagram: flowcharts for dependencies and call flow, sequence diagrams for round-trips.

## Scaffold

```html
<!doctype html>
<html lang="en" class="dark">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script>
      window.light = matchMedia("(prefers-color-scheme: light)").matches;
      if (window.light) document.documentElement.classList.remove("dark");
    </script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            fontFamily: {
              sans: ["system-ui", "sans-serif"],
              mono: ["ui-monospace", "monospace"],
            },
          },
        },
      };
    </script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: window.light ? "default" : "dark", securityLevel: "loose" });
    </script>
  </head>
  <body class="bg-zinc-50 text-zinc-900 dark:bg-zinc-950 dark:text-zinc-100 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

The page is dark unless the system asks for light. Give every colour class a `dark:` pair.

## Header

Repo name, date, and a compact legend: solid box = module, dashed line = seam, red arrow = leakage, thick-bordered box = deep module. No introduction paragraph. Straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the glossary terms (from the `/codebase-design` skill) without ceremony.

Each candidate is one `<article>`:

- **Title**: numbered, short, names the deepening (e.g. "1 · Collapse the Order intake pipeline").
- **Badge row**: recommendation strength (`Strong` = emerald, `Worth exploring` = amber, `Speculative` = zinc), plus a tag for the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files**: monospaced list, `font-mono text-sm`.
- **Before / After diagram**: the centrepiece. Two columns, side by side, one Mermaid diagram each. See below.
- **Problem**: one sentence. What hurts.
- **Solution**: one sentence. What changes.
- **Wins**: bullets, ≤6 words each. e.g. "Tests hit one interface", "Pricing logic stops leaking", "Delete 4 shallow wrappers".
- **Cost**: bullets, ≤6 words each. e.g. "7 call sites change", "Rewrite 12 tests", "Touches payment flow".
- **ADR callout** (if applicable): one line in an amber-tinted box.

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagrams

Use a Mermaid `flowchart` when the point is "X calls Y calls Z, and look at the mess." Wrap it in a card so it doesn't feel parachuted in. Colour leakage edges red with `linkStyle`, draw the deep module as a thick-bordered `subgraph` with its now-internal modules faded inside, and dash seams with `stroke-dasharray`. Sequence diagrams work well for "before: 6 round-trips; after: 1."

Before:

```html
<div class="rounded-lg border border-zinc-200 bg-white p-4 dark:border-zinc-800 dark:bg-zinc-900">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C --> D[PricingClient]
      linkStyle 2 stroke:#dc2626,stroke-width:2px;
  </pre>
</div>
```

After:

```html
<div class="rounded-lg border border-zinc-200 bg-white p-4 dark:border-zinc-800 dark:bg-zinc-900">
  <pre class="mermaid">
    flowchart LR
      A[Caller] --> intake
      subgraph intake[Order intake]
        B[validate]
        C[persist]
      end
      intake -.seam.- D[PricingClient]
      style intake stroke-width:4px;
      classDef internal opacity:0.5;
      class B,C internal
      linkStyle 1 stroke-dasharray:4 4;
  </pre>
</div>
```

## Style guidance

- Plain, not corporate-dashboard. Generous whitespace.
- Colour sparingly: one accent (emerald or indigo) plus red for leakage and amber for warnings.
- Keep diagrams ~320px tall so before/after sits comfortably side by side without scrolling.
- The only scripts are the theme switch, the Tailwind CDN and the Mermaid ESM import. The report is otherwise static: no app code, no interactivity beyond Mermaid's own rendering.

## Top recommendation section

One larger card. Candidate name, one sentence on why, anchor link to its card. That's it. Only a `Strong` candidate qualifies; with none, the card reads "No refactor worth doing now."

## Tone

Plain English, concise, but the architectural nouns and verbs come straight from the `/codebase-design` skill. Concision is not an excuse to drift.

**Use exactly:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

**Never substitute:** component, service, unit (for module) · API, signature (for interface) · boundary (for seam) · layer, wrapper (for module, when you mean module).

**Phrasings that fit the style:**

- "Order intake module is shallow: interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Wins bullets** name the gain in glossary terms: *"locality: bugs concentrate in one module"*, *"leverage: one interface, N call sites"*, *"interface shrinks; implementation absorbs the wrappers"*. Don't write *"easier to maintain"* or *"cleaner code"*, because those terms aren't in the glossary and don't earn their place.

No hedging, no throat-clearing, no "it's worth noting that…". If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it. If a term isn't in the `/codebase-design` glossary, reach for one that is before inventing a new one.
