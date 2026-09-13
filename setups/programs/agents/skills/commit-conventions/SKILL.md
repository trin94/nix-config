---
name: commit-conventions
description: Write commit messages from a diff. Use when committing, amending, or rewording, alongside a project commit or committing skill when present.
---

# Commit conventions

## The log wins

Run `git log -20` before drafting. Types, scope names, subject shape: take them from the log, and where the log and
this file disagree on them, follow the log. The project's own `commit` or `committing` skill beats both.

## Draft blind

The diff is the only input. Not the plan you followed, not the task you were given, not what you know is coming next.
The reader has none of that, so the message gets none of it either. Every claim in the message must trace back to
`git diff --staged`.

Handing the diff to a subagent is the reliable way to hold this, where the harness allows one.

Draft with `ghostwriter`.

## Subject

`type(scope): summary`. Lowercase, imperative, no full stop, 50 characters including the prefix.

- **type**: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `chore`.
- **scope**: the part of the project the change belongs to, spelled the way the log spells it. Drop it when the change
  spans the project instead of one part.

## Body

The subject is the whole message. A body holds only what is **offscreen**: a fact the reader needs that no line of the
diff states. A cause in code the diff leaves untouched, an alternative that was rejected, a bug elsewhere this works
around.

A sentence enters the body only after the test: could the reader rebuild it from the diff alone? Then the diff carries
it and the sentence stays out. The body wraps at 72.

## Done when

The message would pass unnoticed in the log you read: subject shape and scope match those twenty commits, and every
body sentence is offscreen.
