---
name: commit-conventions
description: Prepare commit messages from a diff. Use when creating a commit, alongside a project commit or committing skill when present.
---

# Commit conventions

Apply these conventions with the project's `commit` or `committing` skill when present. Project rules override these
conventions where they conflict.

1. Give a subagent the diff alone. It must use `ghostwriter` to draft the commit message.
2. Keep the subject to 50 characters and wrap the body at 72 characters where possible.
3. Explain why in the body. Use prose, make the message intelligible without planning context, and match casual
   open-source commit logs.

## Done when

The message was drafted from the diff alone, uses `ghostwriter`, and meets every convention above.
