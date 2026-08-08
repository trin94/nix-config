---
name: reporting
description: Report to Elias in scan-first format. Use when writing any answer, summary, findings, status, or review that Elias reads himself, and when he replies with a shortcode asking for a concept expanded. Subagents returning to a parent agent use the parent's requested format instead.
---

# Reporting

Elias **scans**. Every message he reads is skimmed in one pass, in a split second, and acted on. Write for that
read.

Scope: messages Elias reads himself.

* As a subagent, your output is consumed by a parent agent, so return exactly the format that parent asked for.
* Code, commit messages, and files you write keep their own conventions.

## Load-bearing words only

Every word earns its place. Drop articles, hedges, filler verbs, and transitions until only the load-bearing ones
are left.

When they conflict, the order is **meaning > concision > grammar**. Sacrifice grammar freely. Keep every fact
intact and unambiguous.

Write the **directive**: what is true now, what to do. Not a recap of what you just did.

* `Auth broken. Token expires before refresh fires.`
* rather than `I took a look at the auth flow and it seems like there might be an issue where the token...`

## Tables for data

Two or more parallel items with two or more attributes go in a table: files with statuses, options with tradeoffs,
before/after, benchmarks, versions.

| File | State | Why |
| --- | --- | --- |
| `flake.nix` | modified | new input |

One fact stays prose. A flat list stays bullets. The moment it has columns, table it.

## Shortcodes

Tag anything Elias might want opened up with a **shortcode**: a colored dot plus a two-letter code, assigned in
order of appearance, restarting each message. Tag concepts, tradeoffs, non-obvious decisions, anything you
compressed.

The dot carries the color, the letters carry the identity. Cycle the dots in this fixed order so neighbouring
codes never share a hue:

| | | | | | |
| --- | --- | --- | --- | --- | --- |
| 🔴 `AA` | 🟢 `AB` | 🔵 `AC` | 🟡 `AD` | 🟣 `AE` | 🟠 `AF` |

Past six, restart the cycle: `AG` is 🔴 again.

Emoji hold their own color in any theme, unlike bold or inline code, which the theme tints. Keep the backticks
too — the box around the letters is a second contrast channel.

Place a shortcode at the end of the thing it names:

Refresh races the expiry check 🟢 `AB`.

He replies with codes to get them expanded. Answer in exactly this shape, one block per code, in the order he gave
them, carrying the same dot the code had:

**Explaining** 🟢 `AB`: Refresh race

* Refresh fires on a timer, expiry check on request.
* Under load the request wins, so the check sees a dead token.
* Fix is to refresh on the check path.

Every line a bullet, every bullet one sentence.

## DO THIS

Close with a **DO THIS** block: numbered, highest priority first, each line one concrete action Elias performs
himself.

<!-- rumdl-disable-next-line MD036 -->
**DO THIS**

1. Run `nix flake update`.
2. Review `setups/fedora.nix:40`.

Keep it to actions that need him. When the work leaves nothing for him to do, end without the block.
