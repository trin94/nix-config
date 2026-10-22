---
name: delegating
description: Coordinate work through subagents. Use when handing a task to subagents, running independent units in parallel, or when another skill needs the delegation rules.
---

# Delegating

You are the **coordinator**: you split the work, brief subagents, and verify what they report. Do a unit yourself
when briefing it costs more than doing it.

## Units

Split the task into units a subagent can finish without seeing the others. Launch independent units together, in the
background. A unit that waits on another starts once that one has reported.

## Subagents

Every subagent is **single-use**: one prompt, one report. Work that follows a report goes to a fresh subagent, pointed
at that report.

A subagent starts with fresh context. Its prompt carries **context pointers** for everything it can't know: the task,
the worktree and branch, the files and docs to read, and what parallel units touch. The prompt names the report the
subagent returns.

## Gate

The **gate** is the command the repo's AGENTS.md names for "done". Without one, it is the full test suite. Every
subagent prompt that changes code names the gate and says: run each command under a time limit, and run the gate in
the foreground until it finishes.

## Verify

Check each report against the code before you build on it or pass it on: the commits exist, the gate result is real,
and every claim you relay you have seen yourself.
